//backend/src/controllers/audioController.js
// send alert every 30s of audio sent
import dotenv from 'dotenv';
dotenv.config();
import { addAudioRow } from "../utils/jamAI.js";
import fs from 'fs';
import axios from 'axios';
import FormData from 'form-data';

/**
 * Controller function to detect scam in text
 * @param {string} text - The input text to check
 * @returns {string|null} - AI result or null if error
 */

export async function analyzeAudio(req, res) {
  let filePath = req.file?.path;
  try {
    // 1. Upload file to Jamaibase and analyze
    const result = await addAudioRow(filePath);
    console.log('Jam AI raw response:', response);
    res.json({ result });
  } catch (err) {
    res.status(500).json({ error: err.message });
  } finally {
    // Automatic cleanup: delete the uploaded file
    if (filePath) {
      fs.promises.unlink(filePath).catch(() => {});
    }
  }
}
