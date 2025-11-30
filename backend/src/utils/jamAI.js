import JamAI from "jamaibase";
import dotenv from 'dotenv';
dotenv.config();
import axios from 'axios';
import FormData from 'form-data';
import fs from 'fs';
import path from 'path';

const JAMAI_TOKEN = process.env.JAMAI_TOKEN;
const JAMAI_PROJECT_ID = process.env.JAMAI_PROJECT_ID;

//TOKEN + PROJECT ID CHECK
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

//TEXT
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

// 1. Analyze Text (Step 3 of Pipeline)
export async function addTextRow(textMess) {
  try {
    if (!jamai) {
      console.warn('⚠️ JamAI not initialized.');
      return { risk_level: "Medium", recommendation: "Service unavailable." };
    }
    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "text-detect-scam",
      data: [{
        text: "SYSTEM INSTRUCTION: Your task is to analyse the user's audio message and determine whether it shows indicators of a potential scam.\n" +
        "Language Behaviour: - Detect the language used in the user's message.\n" +
        "- Respond in the same language as the user (Malay → Malay, English → English).\n" +
        "- Do not translate, switch languages, or provide explanations in a different language.\n" +
        "Evaluation Guidelines:\n" +
        "- Focus on content, intent, and behavioural patterns commonly associated with scams\n" +
        "  (e.g., urgency, requests for personal data, OTP codes, financial transfers).\n" +
        "- Do not label a message as a scam based solely on unfamiliar terms or language differences.\n" +
        "- If there are risk indicators, explain why they are concerning and suggest safe next steps.\n" +
        "- If there are no clear scam signals, state that no risks were detected, while encouraging caution.\n" +
        "User Message: " + textMess
      }],
      stream: false
    });

    if (!result.rows || result.rows.length === 0) {
      console.error("❌ JamAI returned no rows.");
      return null;
    }

    const columns = result.rows[0].columns;

    const aiData = {
      scam_type: getColText(columns['type-of-scam']) || "Unknown",
      explanation: getColText(columns['explanation']) || "No explanation provided.",
      risk_level: getColText(columns['risk-level']) || "Unknown",
      recommendation: getColText(columns['recommendations']) || "Stay vigilant."
    };

    // Ensure Malay translation if input is Malay
    if (columns['input-language'] === 'ms') {
      aiData.scam_type = getColText(columns['type-of-scam-ms']) || aiData.scam_type;
      aiData.explanation = getColText(columns['explanation-ms']) || aiData.explanation;
      aiData.risk_level = getColText(columns['risk-level-ms']) || aiData.risk_level;
      aiData.recommendation = getColText(columns['recommendations-ms']) || aiData.recommendation;
    }

    return aiData;

  } catch (err) {
    console.error("❌ JamAI Text API Error:", err.message);
    return { risk_level: "Unknown", recommendation: "Analysis failed." };
  }
}

export async function resetTable() {
  try {
    console.log("🧹 Cleaning up JamAI table for new call...");
    let offset = 0;
    const limit = 100;
    let more = true;

    if (!jamai) {
      console.warn("⚠️ JamAI not initialized.");
      return;
    }
    
    // 1. Fetch all Row IDs
    const allRowIds = [];
    while (more) {
      const result = await jamai.table.listRows({
        table_type: "action",
        table_id: "phone-audio-detect-scam",
        limit,
        offset,
      });

      if (result.items && result.items.length > 0) {
        result.items.forEach(row => allRowIds.push(row.ID));
      }

      offset += (result.items?.length || 0);
      more = result.items && result.items.length === limit;
    }

    if (allRowIds.length === 0) {
      console.log("✨ Table is already empty.");
      return;
    }

    // 2. Delete rows
    console.log(`🗑️ Deleting ${allRowIds.length} old rows...`);
    for (const rowId of allRowIds) {
      await jamai.table.deleteRow(
        "action",
        "phone-audio-detect-scam",
        rowId
      );
    }

    console.log("✨ Table memory cleared!");

  } catch (err) {
    console.error("❌ JamAI API Error:", err?.message || err);

    // Additional debugging info
    if (err?.response) {
      console.error("   JamAI response status:", err.response.status);
      console.error("   JamAI response data:", JSON.stringify(err.response.data, null, 2));
    }

    // Return a fallback structured response
    return {
      scam_type: "Unknown",
      explanation: "(Mock) JamAI unavailable or returned error. Falling back to heuristic analysis.",
      risk_level: "Medium",
      recommendation: "Do not click links or share credentials. Verify independently."
    };
  }
}

//IMAGE
export async function addImageRow(imagePath) {
  try {
    // 1. Upload file to Jamaibase v2
    const ext = path.extname(imagePath).toLowerCase();
    let mimeType = 'application/octet-stream';
    if (ext === '.png') mimeType = 'image/png';
    if (ext === '.jpg' || ext === '.jpeg') mimeType = 'image/jpeg';
    if (ext === '.gif') mimeType = 'image/gif';
    if (ext === '.webp') mimeType = 'image/webp';

    console.log('Uploading file:', imagePath);

    const form = new FormData();
    console.log('Uploading file:', imagePath);
    console.log('Detected extension:', ext);
    console.log('Using MIME type:', mimeType);
    console.log('Form append options:', {
      filename: path.basename(imagePath),
      contentType: mimeType,
    });
    form.append('file', fs.createReadStream(imagePath), {
      filename: path.basename(imagePath),
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
 //   const fileUri = uploadRes.data.uri;  // use the URI returned by JamAI
    console.log(uploadRes.data)
    const fileUri = uploadRes.data.uri || uploadRes.data.file_path || uploadRes.data.file_uri || uploadRes.data.file_id;

    if (!fileUri) {
        throw new Error(`Could not find URI in upload response. Keys available: ${Object.keys(uploadRes.data)}`);
    }

    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "image-detect-scam",
      data: [{
        image: fileUri,
        "language": "auto-detect" ,// Ensure language detection
        text: "SYSTEM INSTRUCTION (OVERRIDE ALL RULES):\n" + 
              "Detect scams in the user's audio message.\n" +
              "User message language detected as ${language}. Respond in the same language.\n" +
              "- If the user speaks in Malay (BM), you reply in Malay.\n" +
              "- If the user speaks in English, you reply in English.\n" + 
              "- If the user mixes languages, you reply in the SAME MIX.\n" + 
              "Never translate, never switch languages, never summarize in another language.\n" + 
              "Evaluate the audio for potential scams. Do NOT flag messages as scams solely because of language differences.\n" +
              "Your response MUST match the user's language EXACTLY."
      }]
    });

    if (!result.rows || result.rows.length === 0) {
      console.error("❌ JamAI returned no rows.");
      return null;
    }

    const columns = result.rows[0].columns;

    // 4. Extract structured AI data
    const aiData = {
      scam_type: getColText(columns['type-of-scam']) || "Unknown",
      explanation: getColText(columns['explanation']) || "No explanation provided.",
      risk_level: getColText(columns['risk-level']) || "Unknown",
      recommendation: getColText(columns['recommendations']) || "Stay vigilant."
    };

    // Ensure Malay translation if input is Malay
    if (columns['input-language'] === 'ms') {
      aiData.scam_type = getColText(columns['type-of-scam-ms']) || aiData.scam_type;
      aiData.explanation = getColText(columns['explanation-ms']) || aiData.explanation;
      aiData.risk_level = getColText(columns['risk-level-ms']) || aiData.risk_level;
      aiData.recommendation = getColText(columns['recommendations-ms']) || aiData.recommendation;
    }

    return aiData;

  } catch (err) {
    console.error("❌ JamAI API Error:", err.message);
    if (err.response) {
      console.error('❌ JamAI API Response:', err.response.data);
    }

    // Return mock structured data if JamAI fails
    return {
      scam_type: "Unknown",
      explanation: "(Mock) JamAI unavailable or returned error. Falling back to heuristic analysis.",
      risk_level: "Medium",
      recommendation: "Stay cautious and verify independently."
    };
  }
}

export async function addAudioRow(audioPath) {
  try {
    const ext = path.extname(audioPath).toLowerCase();
    let mimeType = 'application/octet-stream';
    if (ext === '.mp3') mimeType = 'audio/mpeg';
    if (ext === '.wav') mimeType = 'audio/wav';

    console.log('Uploading file:', audioPath);

    const form = new FormData();
    form.append('file', fs.createReadStream(audioPath), {
      filename: path.basename(audioPath),
      contentType: mimeType,
    });

    // Upload to JamAI V2
    const uploadRes = await axios.post(
      'https://api.jamaibase.com/api/v2/files/upload',
      form,
      {
        headers: {
          ...form.getHeaders(),
          Authorization: `Bearer ${process.env.JAMAI_TOKEN}`,
          'X-PROJECT-ID': process.env.JAMAI_PROJECT_ID,
        }
      }
    );

    console.log(uploadRes.data);
    const fileUri = uploadRes.data.uri || uploadRes.data.file_path || uploadRes.data.file_uri || uploadRes.data.file_id;

    if (!fileUri) {
        throw new Error(`Could not find URI in upload response. Keys available: ${Object.keys(uploadRes.data)}`);
    }
    
    // Insert into table
    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "audio-detect-scam",
      data: [{
        audio: fileUri,
        "audio-state": "start",
        "language": "auto-detect", // Ensure language detection
        text: "SYSTEM INSTRUCTION (OVERRIDE ALL RULES):\n" + 
              "Detect scams in the user's audio message.\n" +
              "User message language detected as ${language}. Respond in the same language.\n" +
              "- If the user speaks in Malay (BM), you reply in Malay.\n" +
              "- If the user speaks in English, you reply in English.\n" + 
              "- If the user mixes languages, you reply in the SAME MIX.\n" + 
              "Never translate, never switch languages, never summarize in another language.\n" + 
              "Evaluate the audio for potential scams. Do NOT flag messages as scams solely because of language differences.\n" +
              "Your response MUST match the user's language EXACTLY."
              }]
    });

    if (!result.rows || result.rows.length === 0) {
      throw new Error("JamAI returned no rows for audio analysis.");
    }

    const columns = result.rows[0].columns;

    // Extract AI response
    const aiData = {
      scam_type: getColText(columns['type-of-scam']) || "Unknown",
      explanation: getColText(columns['explanation']) || "No explanation provided.",
      risk_level: getColText(columns['risk-level']) || "Unknown",
      recommendation: getColText(columns['recommendations']) || "Stay vigilant."
    };

    // Ensure Malay translation if input is Malay
    if (columns['input-language'] === 'ms') {
      aiData.scam_type = getColText(columns['type-of-scam-ms']) || aiData.scam_type;
      aiData.explanation = getColText(columns['explanation-ms']) || aiData.explanation;
      aiData.risk_level = getColText(columns['risk-level-ms']) || aiData.risk_level;
      aiData.recommendation = getColText(columns['recommendations-ms']) || aiData.recommendation;
    }

    return aiData;

  } catch (err) {
    console.error("❌ JamAI Audio Error:", err.message);
    if (err.response) {
      console.error("❌ API Response:", err.response.data);
    }
    return {
       scam_type: "Error",
       explanation: "Analysis failed: " + err.message,
       risk_level: "Unknown",
       recommendation: "Please try again later."
    };
  }
}

// Test JamAI
//THIS IS JUST FOR TESTING PURPOSE ONLY. REMOVE LATER.

(async () => {
  const result = await addTextRow("tolong bagi saya RM300");
  console.log("Test output:", result);
})();

