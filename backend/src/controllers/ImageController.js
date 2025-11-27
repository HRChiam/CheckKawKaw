// IMAGE Controller
import dotenv from 'dotenv';
dotenv.config();
import { addImageRow } from "../utils/jamAI.js";
import fs from 'fs';


/**
 * Controller function to detect scam in images
 * @param {string} text - The input text to check
 * @returns {string|null} - AI result or null if error
 */

/*export async function analyzeImage(req, res) {
    if (!req.file) return res.status(400).json({ error: 'No file uploaded' });

    console.log("analyzeImage called with file:", req.file.originalname);

  let filePath = req.file?.path;
    if (!filePath) return res.status(400).json({ error: 'No file uploaded' });
  try {
    const result = await addImageRow(filePath);
    res.json({ result });

  } catch (err) {
    res.status(500).json({ error: err.message });
*/

export async function analyzeImage(filePath) {
  try {
    console.log("Analyzing:", filePath);

    const aiResponse = await addImageRow(filePath);
    return aiResponse;

  } catch (err) {
    throw err;

  } finally {
    if (filePath) {
      fs.promises.unlink(filePath).catch(() => {});
    }
  }
}
