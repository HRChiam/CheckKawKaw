// jamAI.js
import dotenv from 'dotenv';
dotenv.config();
import JamAI from "jamaibase";
import axios from 'axios';
import FormData from 'form-data';
import fs from 'fs';
import path from 'path';

const jamai = new JamAI({
  token: process.env.JAMAI_TOKEN,
  projectId: process.env.JAMAI_PROJECT_ID
});

export async function addTextRow(textMess) {
  try {
    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "text-detect-scam",
      data: [{
        text: textMess
      }]
    });

    // Ensure the path to the response exists based on JamAI SDK response structure
    if (result && result.rows && result.rows.length > 0) {
      const aiResult = result.rows[0].columns['explanation'].choices[0].message.content;
      return aiResult;
    }
    return "Analysis could not be completed.";

  } catch (err) {
    console.error("❌ JamAI API Message:", err.message);
    throw err; // Throw error so controller handles it
  }
}

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

