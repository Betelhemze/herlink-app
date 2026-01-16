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

/* =========================
   GOOGLE LOGIN
========================= */
import { OAuth2Client } from 'google-auth-library';
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID || "MOCK_CLIENT_ID");

router.post("/google", async (req, res) => {
    try {
        const { token, mock_email, mock_name, mock_avatar } = req.body;
        
        let email, name, picture;

        if (token) {
            // Real verification flow
            try {
                 const ticket = await client.verifyIdToken({
                    idToken: token,
                    audience: process.env.GOOGLE_CLIENT_ID, 
                });
                const payload = ticket.getPayload();
                email = payload.email;
                name = payload.name;
                picture = payload.picture;
            } catch(e) {
                // If verify fails (dev mode without real keys), fallback if mocks provided or error
                 console.log("Google verify failed (expected in dev without valid token/id):", e.message);
                 if (mock_email) {
                     email = mock_email;
                     name = mock_name;
                     picture = mock_avatar;
                 } else {
                     return res.status(401).json({ message: "Invalid Google Token" });
                 }
            }
        } else if (mock_email) {
             // Direct mock for testing
             email = mock_email;
             name = mock_name;
             picture = mock_avatar;
        } else {
            return res.status(400).json({message: "Token required"});
        }

        // Check if user exists
        const userResult = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
        let user;

        if (userResult.rows.length === 0) {
            // Create user
             // Password is not applicable, generate a random hash or mark as google-auth
             const randomPass = await bcrypt.hash(Math.random().toString(36), 10);
             const newUser = await pool.query(
                `INSERT INTO users (email, password_hash, full_name, avatar_url)
                 VALUES ($1, $2, $3, $4)
                 RETURNING id, email, full_name, avatar_url`,
                [email, randomPass, name, picture]
            );
            user = newUser.rows[0];
            
            // Also create profile entry
             await pool.query(
                `INSERT INTO profiles (user_id, avatar_url) VALUES ($1, $2)`,
                [user.id, picture]
            );

        } else {
            user = userResult.rows[0];
        }

        const jwtToken = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: "1d" });

        res.json({
            success: true,
            token: jwtToken,
            user: {
                id: user.id,
                email: user.email,
                fullName: user.full_name,
                avatarUrl: user.avatar_url // return avatar if needed
            }
        });

    } catch (error) {
        console.error("Google auth error:", error);
        res.status(500).json({ message: "Server error" });
    }
});

export default router;