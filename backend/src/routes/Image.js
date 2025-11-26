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
  destination: 'storage/image/',
  filename: (req, file, cb) => {
    // Keep original extension
    const ext = path.extname(file.originalname);
    const basename = path.basename(file.originalname, ext);
    cb(null, `${basename}-${Date.now()}${ext}`);
  }
});

const upload = multer({ storage }); // or use memoryStorage for buffer

router.post('/chunk', upload.single('file'), (req, res, next) => {
    console.log("Reached /chunk route!", req.file);
    next();
}, analyzeImage);



export default router;
