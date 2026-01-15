import express from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import  pool  from "../config/db.js";
import { authMiddleware } from "../middleware/authmiddleware.js";

const router = express.Router();

router.post("/register", async (req, res) => {
  try {
    const { email, password, full_name } = req.body;

    if (!email || !password || !full_name) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `INSERT INTO users (email, password_hash, full_name)
       VALUES ($1, $2, $3)
       RETURNING id, email, full_name`,
      [email, hashedPassword, full_name]
    );

    res.status(201).json({
      success: true,
      user: result.rows[0],
    });
  } catch (error) {
    if (error.code === "23505") {
      return res.status(400).json({ message: "Email already exists" });
    }
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
});

/* =========================
   LOGIN
========================= */
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "Email and password required" });
    }

    const userResult = await pool.query(
      `SELECT id, email, password_hash FROM users WHERE email = $1`,
      [email]
    );

    if (userResult.rows.length === 0) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const user = userResult.rows[0];

    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, {
      expiresIn: "1d",
    });

    res.json({
      success: true,
      token,
      user: {
        id: user.id,
        email: user.email,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
});
// logout private
router.post("/logout", authMiddleware, async (req, res) => {
  // JWT logout is client-side (delete token)
  res.json({
    success: true,
    message: "Logged out successfully",
  });
});

/* =========================
   FORGOT PASSWORD (MOCK)
========================= */
router.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ message: "Email required" });

    // Check if user exists
    const userResult = await pool.query("SELECT id FROM users WHERE email = $1", [email]);
    if (userResult.rows.length === 0) {
      // Security: return OK even if email doesn't exist
      return res.json({ message: "If account exists, reset link sent." });
    }

    // Mock sending email
    console.log(`[MOCK] Sending reset email to ${email}`);
    
    // In real app: generate token, save to DB with expiry, send email
    res.json({ message: "Reset link sent to your email." });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

/* =========================
   RESET PASSWORD (MOCK)
========================= */
router.post("/reset-password", async (req, res) => {
    try {
        const { email, newPassword, token } = req.body; // In real app, validate token
        if (!email || !newPassword) return res.status(400).json({ message: "Invalid data" });

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        await pool.query("UPDATE users SET password_hash = $1 WHERE email = $2", [hashedPassword, email]);

        res.json({ message: "Password reset successfully" });
    } catch (error) {
         res.status(500).json({ message: "Server error" });
    }
});

export default router;