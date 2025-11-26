import JamAI from "jamaibase";
import dotenv from 'dotenv';
dotenv.config();
import axios from 'axios';
import FormData from 'form-data';
import fs from 'fs';
import path from 'path';

const JAMAI_TOKEN = process.env.JAMAI_TOKEN;
const JAMAI_PROJECT_ID = process.env.JAMAI_PROJECT_ID;

let jamai = null;
if (!JAMAI_TOKEN) {
  console.warn('JAMAI_TOKEN is not set. JamAI calls will be skipped and a heuristic fallback will be used.');
} else {
  try {
    jamai = new JamAI({ 
      token: JAMAI_TOKEN, 
      projectId: JAMAI_PROJECT_ID 
    });
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

// Add phone chunk row with state and log id
export async function addPhoneRow(audioPath, phoneCallState, phoneLogId) {
  try {
    // 1. Check if file exists locally
    if (!fs.existsSync(audioPath)) {
      console.error(`❌ File not found locally: ${audioPath}`);
      return { transcript: "Error: Audio file missing on server." };
    }

    // 2. Upload file to Jamaibase v2
    const ext = path.extname(audioPath).toLowerCase();
    
    // Explicit MIME type mapping
    let mimeType = 'application/octet-stream'; 
    if (ext === '.wav') mimeType = 'audio/wav';
    if (ext === '.mp3') mimeType = 'audio/mpeg';
    if (ext === '.m4a') mimeType = 'audio/mp4';

    console.log(`📤 Uploading to JamAI: ${path.basename(audioPath)} (${mimeType})`);

    const form = new FormData();
    form.append('file', fs.createReadStream(audioPath), {
      filename: path.basename(audioPath),
      contentType: mimeType,
    });

    const uploadRes = await axios.post(
      'https://api.jamaibase.com/api/v2/files/upload',
      form,
      {
        headers: {
          ...form.getHeaders(),
          Authorization: `Bearer ${process.env.JAMAI_TOKEN}`,
          'X-PROJECT-ID': process.env.JAMAI_PROJECT_ID,
        },
      }
    );

    // 🔍 DEBUG: Log the entire response to see what JamAI gives us
    // console.log("JamAI Upload Response:", uploadRes.data);

    // ✅ FIX: Use 'uri' (or file_uri/url). This is what the Table needs.
    const fileUri = uploadRes.data.uri || uploadRes.data.file_uri || uploadRes.data.url;

    if (!fileUri) {
      console.error("❌ Upload successful but NO URI returned. Response keys:", Object.keys(uploadRes.data));
      throw new Error("File upload returned no URI");
    }

    console.log(`🔗 File URI obtained: ${fileUri}`);

    // 3. Pass the URI to the JamAI Table
    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "phone-audio-detect-scam",
      data: [{
        "audio": fileUri,  // <--- IMPORTANT: Sending the Link, not just ID
        "phone-call-state": phoneCallState,
        "phone-log-id": phoneLogId
      }]
    });

    if (result && result.rows && result.rows.length > 0) {
      return result.rows[0].columns;
    }
    return { transcript: "Analysis could not be completed." };

  } catch (err) {
    console.error("❌ JamAI API Error:", err.message);
    if (err.response) {
      console.error('❌ JamAI Response Data:', JSON.stringify(err.response.data, null, 2));
    }
    throw err;
  }
}

// Get the max phone-log-id from JamAI table (fetch all rows and compute max in JS)
export async function getMaxPhoneLogId() {
  try {
    let maxId = 0;
    let offset = 0;
    const limit = 100;
    let more = true;
    while (more) {
      //list ALL rows in the table
      const result = await jamai.table.listRows({
        table_type: "action",
        table_id: "phone-audio-detect-scam",
        limit,
        offset,
      });
      const items = result.items || [];
      for (const item of items) {
        let val = 0;
        if (item['phone-log-id']) {
          if (typeof item['phone-log-id'] === 'object') {
            val = parseInt(item['phone-log-id'].value || item['phone-log-id'].text || item['phone-log-id'], 10);
          } else {
            val = parseInt(item['phone-log-id'], 10);
          }
        }
        if (!isNaN(val) && val > maxId) maxId = val;
      }
      offset += items.length;
      more = items.length === limit;
    }
    return maxId;
  } catch (err) {
    console.error("❌ Error getting max phone-log-id:", err.message);
    return 0;
  }
}

// Final analysis for all transcripts of a phone-log-id
export async function addFinalPhoneAnalysis(fullTranscript, phoneLogId) {
  try {
    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "text-detect-scam",
      data: [{
        text: fullTranscript,
      }]
    });
    if (result && result.rows && result.rows.length > 0) {
      return result.rows[0].columns;
    }
    return { analysis: "Final analysis could not be completed." };
  } catch (err) {
    console.error("❌ JamAI Final Analysis Error:", err.message);
    return { analysis: "Final analysis error." };
  }
}

//testing only
// (async () => {
//   try {
//     console.log("max phone log id: ",await getMaxPhoneLogId());
//   } catch (e) {
//     console.error(e);
//   }
// })();

// export function isJamaiReady() {
//   return !!jamai;
// }

// export function getJamaiStatus() {
//   return {
//     tokenPresent: !!JAMAI_TOKEN,
//     projectIdPresent: !!JAMAI_PROJECT_ID,
//     initialized: !!jamai
//   };
// }

