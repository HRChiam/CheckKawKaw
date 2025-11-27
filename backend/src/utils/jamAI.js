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
        text: textMess
      }],
      stream: false
    });

    if (!result.rows || result.rows.length === 0) {
      console.error("❌ JamAI returned no rows.");
      return null;
    }

    const columns = result.rows[0].columns;

    return {
      scam_type: getColText(columns['type-of-scam']) || "Unknown",
      explanation: getColText(columns['explanation']) || "No explanation provided.",
      risk_level: getColText(columns['risk-level']) || "Unknown",
      recommendation: getColText(columns['recommendations']) || "Stay vigilant."
    };

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
      
      offset += result.items.length;
      more = (result.items.length === limit);
    }

    if (allRowIds.length === 0) {
      console.log("✨ Table is already empty.");
      return;
    }

    // 2. Delete them
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
    console.error("⚠️ Warning: Failed to reset table (Start might be messy):", err.message);
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

