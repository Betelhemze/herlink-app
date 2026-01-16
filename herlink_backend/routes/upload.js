import express from "express";
import multer from "multer";
import path from "path";
import { authMiddleware } from "../middleware/authmiddleware.js";

const router = express.Router();

// Configure storage
import fs from "fs";

const uploadDir = "uploads/";
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png|webp|gif|bmp|heic|heif/;
    const mimetype = filetypes.test(file.mimetype) || file.mimetype.startsWith('image/');
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());

    if (mimetype || extname) {
      return cb(null, true);
    }
    cb(new Error("Only common image files are allowed"));
  },
}).single("image");

// POST /api/upload
router.post("/", authMiddleware, (req, res) => {
  upload(req, res, function (err) {
    if (err instanceof multer.MulterError) {
      // A Multer error occurred when uploading.
      return res.status(400).json({ message: `Upload error: ${err.message}` });
    } else if (err) {
      // An unknown error occurred when uploading.
      return res.status(400).json({ message: err.message });
    }

    // Everything went fine.
    try {
      if (!req.file) {
        return res.status(400).json({ message: "Please upload a file" });
      }

      const host = req.get("host");
      const protocol = req.protocol;
      const imageUrl = `${protocol}://${host}/uploads/${req.file.filename}`;

      res.json({
        success: true,
        imageUrl: imageUrl,
        filename: req.file.filename,
      });
    } catch (error) {
      res.status(500).json({ message: "Server error during upload" });
    }
  });
});

export default router;
