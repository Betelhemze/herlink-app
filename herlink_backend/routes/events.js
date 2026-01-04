import express from "express";
import  pool  from "../config/db.js";
import { authMiddleware } from "../middleware/authmiddleware.js";

const router = express.Router();

router.get("/", async (req, res) => {
  try {
    const result = await pool.query(
      `
      SELECT *
      FROM events
      WHERE start_time >= NOW()
      ORDER BY start_time ASC
      `
    );

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});


router.post("/", authMiddleware, async (req, res) => {
  try {
    const organizer_id = req.user.userId;
    const {
      title,
      description,
      category,
      start_time,
      end_time,
      location_mode,
      location_details,
      banner_url,
    } = req.body;

    if (!title || !start_time || !end_time) {
      return res.status(400).json({ message: "Required fields missing" });
    }

    const result = await pool.query(
      `
      INSERT INTO events
      (organizer_id, title, description, category, start_time, end_time, location_mode, location_details, banner_url)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
      RETURNING *
      `,
      [
        organizer_id,
        title,
        description,
        category,
        start_time,
        end_time,
        location_mode,
        location_details,
        banner_url,
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});


router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const event = await pool.query(`SELECT * FROM events WHERE id = $1`, [id]);

    if (event.rows.length === 0) {
      return res.status(404).json({ message: "Event not found" });
    }

    res.json(event.rows[0]);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});
router.post("/:id/register", authMiddleware, async (req, res) => {
  try {
    const user_id = req.user.userId;
    const event_id = req.params.id;

    // Prevent duplicate registration
    const exists = await pool.query(
      `
      SELECT * FROM event_attendees
      WHERE event_id=$1 AND user_id=$2
      `,
      [event_id, user_id]
    );

    if (exists.rows.length > 0) {
      return res.status(400).json({ message: "Already registered" });
    }

    await pool.query(
      `
      INSERT INTO event_attendees (event_id, user_id)
      VALUES ($1, $2)
      `,
      [event_id, user_id]
    );

    res.json({ success: true, message: "Registered for event" });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});


export default router;
