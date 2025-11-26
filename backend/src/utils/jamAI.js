import JamAI from "jamaibase";
import dotenv from 'dotenv';
dotenv.config();

const JAMAI_TOKEN = process.env.token;
const JAMAI_PROJECT_ID = process.env.projectId;

let jamai = null;
if (!JAMAI_TOKEN) {
  console.warn('JAMAI_TOKEN is not set. JamAI calls will be skipped and a heuristic fallback will be used.');
} else {
  try {
    jamai = new JamAI({ token: JAMAI_TOKEN, projectId: JAMAI_PROJECT_ID });
  } catch (e) {
    console.error('Failed to initialize JamAI client:', e && e.message ? e.message : e);
    jamai = null;
  }
}

function getColText(columnData) {
  if (!columnData) return null;
  if (columnData.text) return columnData.text;
  if (columnData.value) return columnData.value;
  if (columnData.choices && columnData.choices.length > 0) {
      return columnData.choices[0].message.content;
  }
  if (typeof columnData === 'string') return columnData;

  return null;
}

export async function addTextRow(textMess) {
  try {
    if (!jamai) {
      console.warn('⚠️  Skipping JamAI call because client is not initialized. Returning mock heuristic result.');
      const mockAiData = {
        scam_type: "Unknown",
        explanation: "(Mock) JamAI unavailable or missing credentials. Falling back to heuristic analysis.",
        risk_level: "Medium",
        recommendation: "Do not click links or share credentials. Verify sender independently."
      };
      return mockAiData;
    }
    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "text-detect-scam",
      data: [{
        text: textMess
      }],
      stream: false
    });

    if (!result.rows || result.rows.length === 0) {
      console.error("❌ JamAI returned no rows.");
      return null;
    }

    const columns = result.rows[0].columns;

    // Extract the 4 specific columns from your CSV
    const aiData = {
      scam_type: getColText(columns['type-of-scam']) || "Unknown",
      explanation: getColText(columns['explanation']) || "No explanation provided.",
      risk_level: getColText(columns['risk-level']) || "Unknown",
      recommendation: getColText(columns['recommendations']) || "Stay vigilant."
    };

    return aiData;

  } catch (err) {
    console.error("❌ JamAI API Error:", err && err.message ? err.message : err);
    // If the API returned a response body, log it for debugging
    if (err && err.response) {
      try {
        console.error('   JamAI response status:', err.response.status);
        console.error('   JamAI response data:', JSON.stringify(err.response.data, null, 2));
      } catch (e) {
        console.error('   Could not serialize err.response');
      }
    }

    // Return a mock structured aiData so callers get a consistent object
    const mockAiData = {
      scam_type: "Unknown",
      explanation: "(Mock) JamAI unavailable or returned error 422. Falling back to heuristic analysis.",
      risk_level: "Medium",
      recommendation: "Do not click links or share credentials. Verify sender independently."
    };

    return mockAiData;
  }
}

export function isJamaiReady() {
  return !!jamai;
}

export function getJamaiStatus() {
  return {
    tokenPresent: !!JAMAI_TOKEN,
    projectIdPresent: !!JAMAI_PROJECT_ID,
    initialized: !!jamai
  };
}