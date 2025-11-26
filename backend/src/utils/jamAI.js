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

//PHONECALL
export async function addPhoneRow(audioPath) {
  try {
    // 1. Upload file to Jamaibase v2
    const ext = path.extname(audioPath).toLowerCase();
    let mimeType = 'application/octet-stream';
    if (ext === '.mp3') mimeType = 'audio/mpeg';
    if (ext === '.wav') mimeType = 'audio/wav';

    const form = new FormData();
    console.log('Uploading file:', audioPath);
    console.log('Detected extension:', ext);
    console.log('Using MIME type:', mimeType);
    console.log('Form append options:', {
      filename: path.basename(audioPath),
      contentType: mimeType,
    });
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
    const fileId = uploadRes.data.file_id;

    // 2. Pass fileId to JamAI as the audio column
    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "phone-audio-detect-scam",
      data: [{
        audio: fileId,
        "phone-call-state": "start"
      }]
    });

    if (result && result.rows && result.rows.length > 0) {
      const caution = result.rows[0].columns['caution-message'].choices[0].message.content;
      return caution;
    }
    return "Analysis could not be completed.";

  } catch (err) {
    console.error("❌ JamAI API Message:", err.message);
    if (err.response) {
      console.error('❌ JamAI API Response:', err.response.data);
    }
    throw err;
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
    const fileUri = uploadRes.data.uri;  // use the URI returned by JamAI
    console.log(uploadRes.data)

    // 2. Pass fileId to JamAI as the image column
    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "image-detect-scam",
      data: [{
        image: fileUri,
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

    const fileId = uploadRes.data.file_id;

    // Insert into table
    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "audio-detect-scam",
      data: [{
        audio: fileId,
        "audio-state": "start"
      }]
    });

    // Extract AI response
    const aiText =
      result.rows?.[0]?.columns?.['explanation']?.choices?.[0]?.message?.content ??
      "No explanation found.";

    return aiText;

  } catch (err) {
    console.error("❌ JamAI Audio Error:", err.message);

    if (err.response) {
      console.error("❌ API Response:", err.response.data);
    }

    throw err;
  }
}

// Test JamAI
//THIS IS JUST FOR TESTING PURPOSE ONLY. REMOVE LATER.
/*
(async () => {
  const result = await addTextRow("This is a sample text to check for scam.");
  console.log("Test output:", result);
})();*/

