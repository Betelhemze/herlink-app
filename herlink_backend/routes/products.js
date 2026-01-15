import express from "express";
import  pool  from "../config/db.js";
import { authMiddleware } from "../middleware/authmiddleware.js";

const router = express.Router();

// Example filters: category, minPrice, maxPrice
// Example filters: category, minPrice, maxPrice, search, seller_id
// Example filters: category, minPrice, maxPrice, search, seller_id
router.get("/", async (req, res) => {
  try {
    const { category, minPrice, maxPrice, search, seller_id } = req.query;

    let query = `
      SELECT p.*, u.full_name as seller_name,
      COALESCE(ROUND(AVG(r.rating)::numeric, 1), 0)::float as avg_rating,
      COUNT(r.id)::int as review_count
      FROM products p
      LEFT JOIN users u ON p.seller_id = u.id
      LEFT JOIN reviews r ON p.id = r.target_id AND r.target_type = 'Product'
      WHERE 1=1
    `;
    const params = [];
    let paramIndex = 1;

    if (category) {
      params.push(category);
      query += ` AND p.category = $${paramIndex++}`;
    }

    if (minPrice) {
      params.push(minPrice);
      query += ` AND p.price >= $${paramIndex++}`;
    }

    if (maxPrice) {
      params.push(maxPrice);
      query += ` AND p.price <= $${paramIndex++}`;
    }

    if (search) {
      params.push(`%${search}%`);
      const searchTerm = params.length; // Correct logical index if strict parsing required, but simplest is just bind
      query += ` AND (p.title ILIKE $${paramIndex++} OR p.description ILIKE $${paramIndex - 1})`;
    }

    if (seller_id) {
      params.push(seller_id);
      query += ` AND p.seller_id = $${paramIndex++}`;
    }

    query += ` GROUP BY p.id, u.full_name ORDER BY p.created_at DESC`;

    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
});


router.post("/", authMiddleware, async (req, res) => {
  try {
    const seller_id = req.user.userId;
    const { title, description, price, category, image_url } = req.body;

    if (!title || !price) {
      return res.status(400).json({ message: "Title and price are required" });
    }

    const result = await pool.query(
      `
      INSERT INTO products (seller_id, title, description, price, category, image_url)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
      `,
      [seller_id, title, description, price, category, image_url]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
});


router.get("/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `
      SELECT p.*, u.full_name as seller_name,
      COALESCE(ROUND(AVG(r.rating)::numeric, 1), 0)::float as avg_rating,
      COUNT(r.id)::int as review_count
      FROM products p
      LEFT JOIN users u ON p.seller_id = u.id
      LEFT JOIN reviews r ON p.id = r.target_id AND r.target_type = 'Product'
      WHERE p.id=$1
      GROUP BY p.id, u.full_name
      `, 
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Product not found" });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

router.get("/:id/reviews", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      `SELECT r.*, u.full_name, u.avatar_url, r.created_at
       FROM reviews r
       JOIN users u ON r.author_id = u.id
       WHERE r.target_id = $1 AND r.target_type = 'Product'
       ORDER BY r.created_at DESC`,
      [id]
    );
    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error fetching reviews" });
  }
});

router.put("/:id", authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const seller_id = req.user.userId;
    const { title, description, price, category, image_url } = req.body;

    // Ensure the user is the owner
    const check = await pool.query(
      `SELECT * FROM products WHERE id=$1 AND seller_id=$2`,
      [id, seller_id]
    );

    if (check.rows.length === 0) {
      return res
        .status(403)
        .json({ message: "Not authorized or product not found" });
    }

    const result = await pool.query(
      `
      UPDATE products
      SET title=$1, description=$2, price=$3, category=$4, image_url=$5
      WHERE id=$6
      RETURNING *
      `,
      [title, description, price, category, image_url, id]
    );

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});
router.delete("/:id", authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const seller_id = req.user.userId;

    const check = await pool.query(
      `SELECT * FROM products WHERE id=$1 AND seller_id=$2`,
      [id, seller_id]
    );

    if (check.rows.length === 0) {
      return res
        .status(403)
        .json({ message: "Not authorized or product not found" });
    }

    await pool.query(`DELETE FROM products WHERE id=$1`, [id]);
    res.json({ success: true, message: "Product deleted" });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});
router.post("/:id/reviews", authMiddleware, async (req, res) => {
  try {
    const author_id = req.user.userId;
    const { id } = req.params; // product_id
    const { rating, comment } = req.body;

    if (!rating) {
      return res.status(400).json({ message: "Rating is required" });
    }

    // 🔍 Check if product exists
    const productCheck = await pool.query(
      `SELECT id FROM products WHERE id = $1`,
      [id]
    );

    if (productCheck.rows.length === 0) {
      return res.status(404).json({ message: "Product not found" });
    }

    const result = await pool.query(
      `
      INSERT INTO reviews (author_id, target_id, target_type, rating, comment)
      VALUES ($1, $2, 'Product', $3, $4)
      RETURNING *
      `,
      [author_id, id, rating, comment]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});



export default router;
