import { addAudioRow } from "../utils/jamAI.js";
import fs from 'fs';

/**
 * Controller function to detect scam in audio
 * @param {string} text - The input text to check
 * @returns {string|null} - AI result or null if error
 */

export async function analyzeAudio(filePath) {
  try {
    console.log("Analyzing:", filePath);

    const aiResponse = await addAudioRow(filePath);
    return aiResponse;

  } catch (err) {
    throw err;

  } finally {
    if (filePath) {
      fs.promises.unlink(filePath).catch(() => {});
    }
  }
}
