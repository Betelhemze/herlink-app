import express from "express";
import pool from "../config/db.js";
import { v4 as uuidv4 } from "uuid";
import { authMiddleware } from "../middleware/authmiddleware.js";

const router = express.Router();

router.post("/initiate", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { amount, reference_id, type } = req.body;

    console.log("[payments:initiate] userId=", userId, "body=", req.body);

    // Validate amount
    const amt = Number(amount);
    if (!amt || isNaN(amt) || amt <= 0) {
      console.warn("[payments:initiate] Invalid amount:", amount);
      return res.status(400).json({ message: "Invalid amount" });
    }

    // Determine a UUID-safe reference id. If client provided a composite id like "prd_<uuid>_<ts>",
    // extract the UUID part; otherwise generate a new uuid.
    let refIdToStore;
    if (reference_id && typeof reference_id === "string") {
      const match = reference_id.match(
        /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/
      );
      if (match) {
        refIdToStore = match[0];
      }
    }
    if (!refIdToStore) {
      refIdToStore = uuidv4();
      console.log("[payments:initiate] generated refId=", refIdToStore);
    }

    const result = await pool.query(
      `
      INSERT INTO transactions
      (user_id, amount, status, reference_id, type, provider)
      VALUES ($1, $2, 'PENDING', $3, $4, 'Telebirr')
      RETURNING id, status
      `,
      [userId, amt, refIdToStore, type]
    );

    console.log(
      "[payments:initiate] created transaction id=",
      result.rows[0].id,
      "reference_id=",
      refIdToStore
    );

    // Mock Telebirr response
    res.status(201).json({
      message: "Telebirr payment initiated",
      transaction_id: result.rows[0].id,
      reference_id: refIdToStore,
      status: "PENDING",
      instruction: "Simulate Telebirr approval in verify step",
    });
  } catch (err) {
    console.error("[payments:initiate] error:", err);
    res
      .status(500)
      .json({ message: "Payment initiation failed", error: err.message });
  }
});

router.post("/verify", authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { transaction_id, success } = req.body;

    console.log("[payments:verify] userId=", userId, "body=", req.body);

    if (!transaction_id) {
      console.warn("[payments:verify] Missing transaction_id");
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
      console.warn("[payments:verify] transaction not found or wrong user", {
        transaction_id,
        userId,
      });
      return res.status(404).json({ message: "Transaction not found" });
    }

    console.log(
      "[payments:verify] updated transaction",
      result.rows[0].id,
      "status=",
      status
    );

    res.json({
      message: `Payment ${status}`,
      transaction: result.rows[0],
    });
  } catch (err) {
    console.error("[payments:verify] error:", err);
    res
      .status(500)
      .json({ message: "Payment verification failed", error: err.message });
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
