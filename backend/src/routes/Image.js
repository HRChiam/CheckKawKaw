import express from "express";
import multer from 'multer';
import path from "path";
import fs from 'fs';
import { analyzeImage } from '../controllers/ImageController.js';

const router = express.Router();

// Ensure upload directory exists
const uploadDir = path.join('storage', 'image');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });


const storage = multer.diskStorage({
  destination: uploadDir,
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const basename = path.basename(file.originalname, ext);
    cb(null, `${basename}-${Date.now()}${ext}`);
  }
});

const upload = multer({ storage }); // or use memoryStorage for buffer

router.post('/chunk', upload.single('file'), async (req, res, next) => {
    if (!req.file) {
        return res.status(400).json({ error: 'No file uploaded' });
    }

    try {
        const result = await analyzeImage(req.file.path);
        return res.json({ result });
    } catch (err) {
        console.error('Error in analyzeImage:', err);
        return res.status(500).json({ error: err.message });
    }
});

export default router;
