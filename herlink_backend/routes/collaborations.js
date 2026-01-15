import express from "express";
import  pool  from "../config/db.js";
import { authMiddleware } from "../middleware/authmiddleware.js";
const router = express.Router();

router.get("/", async (req, res) => {
  try {
    const { search, category } = req.query;
    let query = `
      SELECT
        id,
        title,
        description,
        type,
        status,
        view_count,
        initiator_id,
        created_at
      FROM collaborations
      WHERE 1=1
    `;
    const params = [];

    if (category) {
      params.push(category);
      query += ` AND type = $${params.length}`;
    }

    if (search) {
      params.push(`%${search}%`);
      query += ` AND (title ILIKE $${params.length} OR description ILIKE $${params.length})`;
    }

    query += ` ORDER BY created_at DESC`;

    const result = await pool.query(query, params);

    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: "Failed to fetch collaborations" });
  }
});


router.post("/", authMiddleware, async (req, res) => {
  try {
    const initiator_id = req.user.userId;
    const { title, description, type } = req.body;

    if (!title || !type) {
      return res.status(400).json({ message: "Title and type are required" });
    }

    const result = await pool.query(
      `
      INSERT INTO collaborations
      (initiator_id, title, description, type)
      VALUES ($1, $2, $3, $4)
      RETURNING *
      `,
      [initiator_id, title, description, type]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ message: "Failed to create collaboration" });
  }
});
router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    // Increment view count
    await pool.query(
      `UPDATE collaborations SET view_count = view_count + 1 WHERE id = $1`,
      [id]
    );

    const result = await pool.query(
      `
      SELECT
        id,
        title,
        description,
        type,
        status,
        view_count,
        initiator_id,
        created_at
      FROM collaborations
      WHERE id = $1
      `,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Collaboration not found" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ message: "Failed to fetch collaboration" });
  }
});
//update collaboration status
router.put("/:id/status", authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const userId = req.user.userId;

    const result = await pool.query(
      `
      UPDATE collaborations
      SET status = $1
      WHERE id = $2 AND initiator_id = $3
      RETURNING *
      `,
      [status, id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(403).json({ message: "Not authorized or not found" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ message: "Failed to update status" });
  }
});


export default router;
