import dotenv from "dotenv";
import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth.js";
import userRoutes from "./routes/users.js";
import productRoutes from "./routes/products.js";
import eventRoutes from "./routes/events.js";
import collaborationRoutes from "./routes/collaborations.js";
import collaborationRequestsRoutes from "./routes/collaboration_requests.js";
import messageRoutes from "./routes/messages.js";
import feedRoutes from "./routes/feed.js";
import paymentRoutes from "./routes/payments.js";
import uploadRoutes from "./routes/upload.js";
import postsRoutes from "./routes/posts.js";
import path from "path";
import { fileURLToPath } from 'url';

dotenv.config();

import pool from "./config/db.js";


const app = express();
app.use(express.json());

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/products", productRoutes);
app.use("/api/events", eventRoutes);
app.use("/api/collaborations", collaborationRoutes);
app.use("/api/collaboration-requests", collaborationRequestsRoutes);
app.use("/api/messages", messageRoutes);
app.use("/api/feed", feedRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/upload", uploadRoutes);
app.use("/api/posts", postsRoutes);

// Example route
app.get("/health", (req, res) => {
  res.json({ status: "OK", service: "HerLink Backend" });
});

pool.query("SELECT NOW()", (err, res) => {
  if (err) {
    console.error("Database connection failed:", err);
  } else {
    console.log("Database connected at:", res.rows[0].now);
  }
});


// Port setup
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
