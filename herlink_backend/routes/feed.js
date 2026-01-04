import express from "express";
import  pool  from "../config/db.js";
import { authMiddleware } from "../middleware/authmiddleware.js";
const router = express.Router();

router.get("/", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        p.id,
        p.content,
        p.image_url,
        p.type,
        p.likes_count,
        p.comments_count,
        p.share_count,
        p.created_at,
        u.full_name,
        pr.avatar_url
      FROM posts p
      JOIN users u ON p.author_id = u.id
      LEFT JOIN profiles pr ON u.id = pr.user_id
      ORDER BY p.created_at DESC
    `);

    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: "Failed to fetch feed" });
  }
});


router.post("/", authMiddleware, async (req, res) => {
  try {
    const author_id = req.user.userId;
    const { content, image_url, type } = req.body;

    if (!content) {
      return res.status(400).json({ message: "Content is required" });
    }

    const result = await pool.query(
      `
      INSERT INTO posts (author_id, content, image_url, type)
      VALUES ($1, $2, $3, $4)
      RETURNING *
      `,
      [author_id, content, image_url, type || "Update"]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ message: "Failed to create post" });
  }
});


router.post("/:id/like", authMiddleware, async (req, res) => {
  try {
    const postId = req.params.id;
    const userId = req.user.userId;

    const exists = await pool.query(
      `SELECT 1 FROM post_likes WHERE post_id = $1 AND user_id = $2`,
      [postId, userId]
    );

    if (exists.rows.length > 0) {
      return res.status(400).json({ message: "Already liked" });
    }

    await pool.query(
      `INSERT INTO post_likes (post_id, user_id) VALUES ($1, $2)`,
      [postId, userId]
    );

    await pool.query(
      `UPDATE posts SET likes_count = likes_count + 1 WHERE id = $1`,
      [postId]
    );

    res.json({ message: "Post liked" });
  } catch (err) {
    res.status(500).json({ message: "Failed to like post" });
  }
});
router.get("/:id/comments", async (req, res) => {
  try {
    const postId = req.params.id;

    const result = await pool.query(
      `
      SELECT
        c.id,
        c.content,
        c.created_at,
        u.full_name,
        pr.avatar_url
      FROM comments c
      JOIN users u ON c.author_id = u.id
      LEFT JOIN profiles pr ON u.id = pr.user_id
      WHERE c.post_id = $1
      ORDER BY c.created_at ASC
      `,
      [postId]
    );

    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: "Failed to fetch comments" });
  }
});
router.post("/:id/comments", authMiddleware, async (req, res) => {
  try {
    const postId = req.params.id;
    const authorId = req.user.userId;
    const { content } = req.body;

    if (!content) {
      return res.status(400).json({ message: "Comment is required" });
    }

    await pool.query(
      `
      INSERT INTO comments (post_id, author_id, content)
      VALUES ($1, $2, $3)
      `,
      [postId, authorId, content]
    );

    await pool.query(
      `UPDATE posts SET comments_count = comments_count + 1 WHERE id = $1`,
      [postId]
    );

    res.status(201).json({ message: "Comment added" });
  } catch (err) {
    res.status(500).json({ message: "Failed to add comment" });
  }
});
router.post("/:id/share", authMiddleware, async (req, res) => {
  try {
    const postId = req.params.id;

    await pool.query(
      `UPDATE posts SET share_count = share_count + 1 WHERE id = $1`,
      [postId]
    );

    res.json({ message: "Post shared" });
  } catch (err) {
    res.status(500).json({ message: "Failed to share post" });
  }
});


export default router;
