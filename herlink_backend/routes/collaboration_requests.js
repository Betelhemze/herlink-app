import express from "express";
import pool from "../config/db.js";
import { authMiddleware } from "../middleware/authmiddleware.js";

const router = express.Router();

// Initialize table if not exists (In a real app, use migrations)
const initTable = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS collaboration_requests (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        collaboration_id UUID REFERENCES collaborations(id),
        sender_id UUID REFERENCES users(id) NOT NULL,
        receiver_id UUID REFERENCES users(id) NOT NULL,
        message TEXT NOT NULL,
        status VARCHAR(20) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
  } catch (err) {
    console.error("Error creating collaboration_requests table:", err);
  }
};
initTable();

// Send an interest message (Connect)
router.post("/", authMiddleware, async (req, res) => {
  try {
    const sender_id = req.user.userId;
    const { receiver_id, collaboration_id, message } = req.body;

    if (!receiver_id || !message) {
      return res.status(400).json({ message: "Receiver and message are required" });
    }

    const result = await pool.query(
      `
      INSERT INTO collaboration_requests (sender_id, receiver_id, collaboration_id, message)
      VALUES ($1, $2, $3, $4)
      RETURNING *
      `,
      [sender_id, receiver_id, collaboration_id || null, message]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("Error sending collaboration request:", err);
    res.status(500).json({ message: "Failed to send request" });
  }
});

// Get my inbox (received requests)
router.get("/me", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `
      SELECT 
        cr.*, 
        u.full_name as sender_name,
        p.avatar_url as sender_avatar,
        c.title as collaboration_title
      FROM collaboration_requests cr
      JOIN users u ON cr.sender_id = u.id
      LEFT JOIN profiles p ON u.id = p.user_id
      LEFT JOIN collaborations c ON cr.collaboration_id = c.id
      WHERE cr.receiver_id = $1
      ORDER BY cr.created_at DESC
      `,
      [userId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching collaboration inbox:", err);
    res.status(500).json({ message: "Failed to fetch inbox" });
  }
});

// Update request status (accept/reject)
router.put("/:id/status", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;
    const { status } = req.body;

    if (!['accepted', 'rejected'].includes(status)) {
      return res.status(400).json({ message: "Invalid status" });
    }

    const result = await pool.query(
      `
      UPDATE collaboration_requests 
      SET status = $1 
      WHERE id = $2 AND receiver_id = $3
      RETURNING *
      `,
      [status, id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Request not found or not authorized" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error("Error updating request status:", err);
    res.status(500).json({ message: "Failed to update status" });
  }
});

export default router;
