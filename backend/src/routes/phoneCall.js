import express from "express";
import multer from 'multer';
import path from "path";
import { analyzePhoneChunk } from '../controllers/phoneChunkController.js';

const router = express.Router();

router.post('/start', (req, res) => {
    res.json({ success: true, message: 'Phone call start endpoint working!' });
});

router.post('/end', (req, res) => {
    res.json({ success: true, message: 'Phone call end endpoint working!' });
});

const storage = multer.diskStorage({
  destination: 'storage/phoneChunks/',
  filename: (req, file, cb) => {
    // Keep original extension
    const ext = path.extname(file.originalname);
    const basename = path.basename(file.originalname, ext);
    cb(null, `${basename}-${Date.now()}${ext}`);
  }
});

const upload = multer({ storage }); // or use memoryStorage for buffer

router.post('/chunk', upload.single('file'), analyzePhoneChunk);


export default router;
