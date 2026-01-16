import express from "express";
import pool from "../config/db.js";
import { authMiddleware } from "../middleware/authmiddleware.js";

const router = express.Router();

// Get saved items for user (enriched)
router.get("/", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const result = await pool.query(
      `
      SELECT s.entity_type, s.entity_id, s.created_at,
             p.title as title, p.image_url as image_url, p.price::text as price, p.description as description,
             COALESCE(ROUND(AVG(r.rating)::numeric, 1), 0)::float as avg_rating,
             NULL as start_time
      FROM saved_items s
      JOIN products p ON s.entity_id = p.id::text
      LEFT JOIN reviews r ON p.id = r.target_id AND r.target_type = 'Product'
      WHERE s.user_id = $1 AND s.entity_type = 'product'
      GROUP BY s.entity_type, s.entity_id, s.created_at, p.id
      UNION ALL
      SELECT s.entity_type, s.entity_id, s.created_at,
             e.title as title, e.banner_url as image_url, NULL as price, e.description as description,
             0 as avg_rating,
             e.start_time::text as start_time
      FROM saved_items s
      JOIN events e ON s.entity_id = e.id::text
      WHERE s.user_id = $1 AND s.entity_type = 'event'
      ORDER BY created_at DESC
      `,
      [userId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching saved items:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// Save an item
router.post("/", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { entity_type, entity_id } = req.body; // entity_type: 'product' | 'event'

    if (!entity_type || !entity_id) {
        return res.status(400).json({message: "Invalid data"});
    }

    // Check if duplicate
    const check = await pool.query(
        "SELECT 1 FROM saved_items WHERE user_id = $1 AND entity_type = $2 AND entity_id = $3",
        [userId, entity_type, entity_id]
    );
    if(check.rows.length > 0) {
        return res.json({message: "Already saved"});
    }

    await pool.query(
      `INSERT INTO saved_items (user_id, entity_type, entity_id) VALUES ($1, $2, $3)`,
      [userId, entity_type, entity_id]
    );
    res.status(201).json({ message: "Item saved" });
  } catch (err) {
    res.status(500).json({ message: "Server error" });
  }
});

// Unsave an item
router.delete("/:type/:id", authMiddleware, async (req, res) => {
    try {
      const userId = req.user.userId;
      const { type, id } = req.params;
  
      await pool.query(
        `DELETE FROM saved_items WHERE user_id = $1 AND entity_type = $2 AND entity_id = $3`,
        [userId, type, id]
      );
      res.json({ message: "Item removed" });
    } catch (err) {
      res.status(500).json({ message: "Server error" });
    }
  });

export default router;
