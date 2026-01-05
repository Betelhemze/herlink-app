import express from "express";
import  pool  from "../config/db.js";
import { authMiddleware } from "../middleware/authmiddleware.js";
const router = express.Router();

router.get("/me", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `
      SELECT 
        u.id,
        u.full_name,
        u.email,
        p.business_name,
        p.role,
        p.industry,
        p.location,
        p.bio,
        p.avatar_url,
        p.rating_avg,
        p.followers_count
      FROM users u
      LEFT JOIN profiles p ON u.id = p.user_id
      WHERE u.id = $1
      `,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

router.get("/me/events", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const hostedEvents = await pool.query(
      `SELECT * FROM events WHERE organizer_id = $1`,
      [userId]
    );

    const joinedEvents = await pool.query(
      `
      SELECT e.*
      FROM events e
      JOIN event_attendees ea ON e.id = ea.event_id
      WHERE ea.user_id = $1
      `,
      [userId]
    );

    res.json({
      hosted: hostedEvents.rows,
      joined: joinedEvents.rows,
    });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `
      SELECT 
        u.id,
        u.full_name,
        u.email,
        p.business_name,
        p.role,
        p.industry,
        p.location,
        p.bio,
        p.avatar_url,
        p.rating_avg,
        p.followers_count
      FROM users u
      LEFT JOIN profiles p ON u.id = p.user_id
      WHERE u.id = $1
      `,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});


router.put("/profile", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { full_name, business_name, role, industry, location, bio, avatar_url } =
      req.body;

    // Update users table for full_name if provided
    if (full_name) {
      await pool.query(
        `UPDATE users SET full_name = $1 WHERE id = $2`,
        [full_name, userId]
      );
    }

    await pool.query(
      `
      INSERT INTO profiles 
      (user_id, business_name, role, industry, location, bio, avatar_url)
      VALUES ($1,$2,$3,$4,$5,$6,$7)
      ON CONFLICT (user_id)
      DO UPDATE SET
        business_name = EXCLUDED.business_name,
        role = EXCLUDED.role,
        industry = EXCLUDED.industry,
        location = EXCLUDED.location,
        bio = EXCLUDED.bio,
        avatar_url = EXCLUDED.avatar_url
      `,
      [userId, business_name, role, industry, location, bio, avatar_url]
    );

    res.json({ success: true, message: "Profile updated" });
  } catch (error) {
    console.error("Profile update error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

router.get("/:id/events", async (req, res) => {
  try {
    const { id } = req.params;

    const hostedEvents = await pool.query(
      `SELECT * FROM events WHERE organizer_id = $1`,
      [id]
    );

    const joinedEvents = await pool.query(
      `
      SELECT e.*
      FROM events e
      JOIN event_attendees ea ON e.id = ea.event_id
      WHERE ea.user_id = $1
      `,
      [id]
    );

    res.json({
      hosted: hostedEvents.rows,
      joined: joinedEvents.rows,
    });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});


export default router;
