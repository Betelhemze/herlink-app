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


import { Server } from "socket.io";
import http from "http";
import savedRoutes from "./routes/saved.js";

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*", // Allow all connections for now (dev)
    methods: ["GET", "POST"]
  }
});

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
app.use("/api/saved", savedRoutes);

// Socket.io connection
io.on("connection", (socket) => {
  console.log(`User connected: ${socket.id}`);

  socket.on("join_room", (userId) => {
    socket.join(userId);
    console.log(`User ${socket.id} joined room ${userId}`);
  });

  socket.on("send_message", (data) => {
    // data: { receiverId, content, senderId, senderName, ... }
    io.to(data.receiverId).emit("receive_message", data);
  });

  socket.on("disconnect", () => {
    console.log("User disconnected", socket.id);
  });
});

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
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
