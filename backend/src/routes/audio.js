import express from "express";
import multer from 'multer';
import path from "path";
import fs from 'fs';
import { analyzeAudio } from '../controllers/audioController.js';

const router = express.Router();

// Test endpoints
router.post('/start', (req, res) => {
    res.json({ success: true, message: 'Audio start endpoint working!' });
});
router.post('/end', (req, res) => {
    res.json({ success: true, message: 'Audio end endpoint working!' });
});

// Ensure upload directory exists
const uploadDir = path.join('storage', 'Audio');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });

// Multer setup
const storage = multer.diskStorage({
  destination: uploadDir,
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const basename = path.basename(file.originalname, ext);
    cb(null, `${basename}-${Date.now()}${ext}`);
  }
});
const upload = multer({ storage });

// Audio upload + analyze
router.post('/chunk', upload.single('file'), async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ error: 'No file uploaded' });
    }

    try {
        const result = await analyzeAudio(req.file.path);
        if (!result) {
            return res.status(500).json({ error: 'Audio processing returned undefined' });
        }
        res.json(result);
    } catch (err) {
        console.error('Error in analyzeAudio:', err);
        res.status(500).json({ error: err.message });
    }
});

export default router;
