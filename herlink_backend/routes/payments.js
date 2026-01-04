import express from "express";
import  pool  from "../config/db.js";
import { v4 as uuidv4 } from "uuid";
import { authMiddleware } from "../middleware/authmiddleware.js";

const router = express.Router();

router.post("/initiate", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { amount, reference_id, type } = req.body;

    if (!amount || !reference_id || !type) {
      return res.status(400).json({ message: "Missing payment fields" });
    }

    const result = await pool.query(
      `
      INSERT INTO transactions
      (user_id, amount, status, reference_id, type, provider)
      VALUES ($1, $2, 'PENDING', $3, $4, 'Telebirr')
      RETURNING id, status
      `,
      [userId, amount, reference_id, type]
    );

    // Mock Telebirr response
    res.status(201).json({
      message: "Telebirr payment initiated",
      transaction_id: result.rows[0].id,
      status: "PENDING",
      instruction: "Simulate Telebirr approval in verify step",
    });
  } catch (err) {
    res.status(500).json({ message: "Payment initiation failed" });
  }
});


router.post("/verify", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { transaction_id, success } = req.body;

    if (!transaction_id) {
      return res.status(400).json({ message: "Transaction ID required" });
    }

    const status = success ? "SUCCESS" : "FAILED";

    const result = await pool.query(
      `
      UPDATE transactions
      SET status = $1
      WHERE id = $2 AND user_id = $3
      RETURNING *
      `,
      [status, transaction_id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Transaction not found" });
    }

    res.json({
      message: `Payment ${status}`,
      transaction: result.rows[0],
    });
  } catch (err) {
    res.status(500).json({ message: "Payment verification failed" });
  }
});


router.get("/history", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `
      SELECT
        id,
        amount,
        currency,
        status,
        type,
        provider,
        created_at
      FROM transactions
      WHERE user_id = $1
      ORDER BY created_at DESC
      `,
      [userId]
    );

    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: "Failed to fetch payment history" });
  }
});


export default router;
