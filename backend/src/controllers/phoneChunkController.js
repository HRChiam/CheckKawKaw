// send alert every 30s of audio sent
import dotenv from 'dotenv';
dotenv.config();
import { addPhoneRow, addFinalPhoneAnalysis, getMaxPhoneLogId } from "../utils/jamAI.js";
import fs from 'fs';
import axios from 'axios';
import FormData from 'form-data';

/**
 * Controller function to detect scam in text
 * @param {string} text - The input text to check
 * @returns {string|null} - AI result or null if error
 */

function getSafeText(colData) {
  if (!colData) return "";
  if (typeof colData === 'string') return colData;
  if (colData.text) return colData.text;
  if (colData.value) return colData.value;
  return "";
}

// In-memory store for phone call chunks (for demo; use DB for production)
const phoneCallChunks = {};

export async function analyzePhoneChunk(req, res) {
  let filePath = req.file?.path;
  const phoneCallState = req.body['phone-call-state'] || req.body.phone_call_state || 'middle';
  let phoneLogId = req.body['phone-log-id'] || req.body.phone_log_id;
  let generatedNewId = false;
  try {
    // If state is start, generate a new phone-log-id
    if (phoneCallState === 'start' || !phoneLogId || phoneLogId === 'null' || phoneLogId === 'undefined') {
      const maxId = await getMaxPhoneLogId();
      phoneLogId = maxId + 1;
      generatedNewId = true;
      console.log(`🆕 New Call Detected. Generated phone-log-id: ${phoneLogId}`);
    }

    const result = await addPhoneRow(filePath, phoneCallState, phoneLogId);

    const riskRaw = getSafeText(result['risk-level']).toLowerCase();
    const cautionMessage = getSafeText(result['recommendation']) || "Suspicious activity detected.";

    const sendAlert = riskRaw.includes('high');
    // Store chunk result in memory
    if (!phoneCallChunks[phoneLogId]) phoneCallChunks[phoneLogId] = [];
    phoneCallChunks[phoneLogId].push({
      state: phoneCallState,
      result,
    });

    // If this is the end of the call, aggregate and analyze all chunks
    if (phoneCallState === 'end') {
      const allChunks = phoneCallChunks[phoneLogId] || [];
      // Aggregate all transcriptions/results
      const allTranscripts = allChunks.map(c => c.result.transcript || c.result).join(' ');
      // Perform final analysis (implement addFinalPhoneAnalysis in jamAI.js)
      const finalAnalysis = await addFinalPhoneAnalysis(allTranscripts, phoneLogId);
      // Clean up memory
      delete phoneCallChunks[phoneLogId];
      res.json({ phoneLogId, finalAnalysis });
    } else {
      res.json({ phoneLogId, result, generatedNewId });
    }
  } catch (err) {
    console.error("Controller Error:", err);
    res.status(500).json({ error: err.message });
  } finally {
    // Automatic cleanup: delete the uploaded file
    if (filePath) {
      fs.promises.unlink(filePath).catch(() => {});
    }
  }
}
