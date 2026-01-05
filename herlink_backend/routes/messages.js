import express from "express";
import pool from "../config/db.js";
import { authMiddleware } from "../middleware/authmiddleware.js";

const router = express.Router();

// Initialize table
const initTable = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        sender_id UUID REFERENCES users(id) NOT NULL,
        receiver_id UUID REFERENCES users(id) NOT NULL,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
  } catch (err) {
    console.error("Error creating messages table:", err);
  }
};
initTable();

// Send message
router.post("/", authMiddleware, async (req, res) => {
  try {
    const sender_id = req.user.userId;
    const { receiver_id, content } = req.body;

    if (!receiver_id || !content) {
      return res.status(400).json({ message: "Receiver and content are required" });
    }

    const result = await pool.query(
      `
      INSERT INTO messages (sender_id, receiver_id, content)
      VALUES ($1, $2, $3)
      RETURNING *
      `,
      [sender_id, receiver_id, content]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("Error sending message:", err);
    res.status(500).json({ message: "Failed to send message" });
  }
});

// Get conversation with a specific user
router.get("/chat/:otherUserId", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { otherUserId } = req.params;

    const result = await pool.query(
      `
      SELECT * FROM messages 
      WHERE (sender_id = $1 AND receiver_id = $2)
         OR (sender_id = $2 AND receiver_id = $1)
      ORDER BY created_at ASC
      `,
      [userId, otherUserId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching chat:", err);
    res.status(500).json({ message: "Failed to fetch chat" });
  }
});

// Get all conversations (latest message from each unique pair)
router.get("/conversations", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `
      SELECT DISTINCT ON (other_id)
        id,
        content,
        created_at,
        CASE 
          WHEN sender_id = $1 THEN receiver_id 
          ELSE sender_id 
        END as other_id,
        u.full_name as other_name,
        p.avatar_url as other_avatar
      FROM messages m
      JOIN users u ON u.id = (CASE WHEN m.sender_id = $1 THEN m.receiver_id ELSE m.sender_id END)
      LEFT JOIN profiles p ON u.id = p.user_id
      WHERE sender_id = $1 OR receiver_id = $1
      ORDER BY other_id, created_at DESC
      `,
      [userId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching conversations:", err);
    res.status(500).json({ message: "Failed to fetch conversations" });
  }
});

export default router;
