import dotenv from 'dotenv';
dotenv.config();
// ✅ Import both Audio and Text functions
import { addPhoneRow, addTextRow, addFinalPhoneAnalysis, getMaxPhoneLogId, resetTable } from "../utils/jamAI.js";
import fs from 'fs';

// Helper to extract string text safely
function getSafeText(colData) {
  if (!colData) return "";
  if (typeof colData === 'string') return colData;
  if (colData.transcription) return getSafeText(colData.transcription);
  if (colData.choices && Array.isArray(colData.choices) && colData.choices.length > 0) {
    return colData.choices[0].message.content;
  }
  if (colData.text) return colData.text;
  if (colData.value) return colData.value;
  try { return JSON.stringify(colData); } catch (e) { return ""; }
}

// In-memory store for conversation history
const phoneCallChunks = {};

export async function analyzePhoneChunk(req, res) {
  let filePath = req.file?.path;
  const phoneCallState = req.body['phone-call-state'] || req.body.phone_call_state || 'middle';
  let phoneLogId = req.body['phone-log-id'] || req.body.phone_log_id;
  let generatedNewId = false;

  try {
    // ---------------------------------------------------------
    // 0. INITIALIZATION (Start of Call)
    // ---------------------------------------------------------
    if (phoneCallState === 'start' || !phoneLogId || phoneLogId === 'null' || phoneLogId === 'undefined') {
      await resetTable(); // Clear JamAI memory to prevent Token Error
      const maxId = await getMaxPhoneLogId();
      phoneLogId = maxId + 1;
      generatedNewId = true;
      console.log(`\n📞 === NEW CALL DETECTED (ID: ${phoneLogId}) ===`);
    }

    // ---------------------------------------------------------
    // STEP 1: AUDIO ANALYSIS (The "Fast Check")
    // Upload 15s chunk -> Get Transcript + Immediate Risk
    // ---------------------------------------------------------
    const audioResult = await addPhoneRow(filePath, phoneCallState, phoneLogId);
    
    const transcriptText = getSafeText(audioResult['transcription'] || audioResult['transcript']);
    const audioRisk = getSafeText(audioResult['risk-level']).toLowerCase();
    const audioCaution = getSafeText(audioResult['caution-message'] || audioResult['recommendation']);
    
    console.log(`🗣️ Transcript (15s): "${transcriptText.substring(0, 50)}..."`);

    // ---------------------------------------------------------
    // STEP 2: MEMORY AGGREGATION
    // Combine this text with previous text
    // ---------------------------------------------------------
    if (!phoneCallChunks[phoneLogId]) phoneCallChunks[phoneLogId] = [];
    
    // Only add to memory if it's actual speech (ignore silence/empty)
    if (transcriptText && transcriptText.length > 2) {
      phoneCallChunks[phoneLogId].push({
        state: phoneCallState,
        transcript: transcriptText
      });
    }

    const allChunks = phoneCallChunks[phoneLogId] || [];
    const fullConversation = allChunks.map(c => c.transcript).join(' ');

    console.log(`📝 Full Context Length: ${fullConversation.length} chars`);

    // ---------------------------------------------------------
    // STEP 3: TEXT ANALYSIS (The "Deep Check")
    // Send full history to Text Table for Contextual Risk
    // ---------------------------------------------------------
    let textResult = {};
    if (fullConversation.length > 5) { // Only analyze if we have enough text
       textResult = await addTextRow(fullConversation); 
    }

    const textRisk = getSafeText(textResult['risk_level'] || textResult['risk-level']).toLowerCase();
    const textCaution = getSafeText(textResult['recommendation'] || textResult['explanation']);

    // ---------------------------------------------------------
    // FINAL DECISION LOGIC
    // Combine alerts from Audio (Fast) and Text (Deep)
    // ---------------------------------------------------------
    
    // 1. Determine Alert Status (True if EITHER is High/Medium)
    const isAudioHigh = audioRisk.includes('high') || audioRisk.includes('medium');
    const isTextHigh  = textRisk.includes('high') || textRisk.includes('medium');
    
    const sendAlert = isAudioHigh || isTextHigh;

    // 2. Determine Message (Prefer Text Analysis as it has more context)
    let finalCaution = "Monitoring call...";
    if (isTextHigh && textCaution) {
        finalCaution = textCaution;
    } else if (isAudioHigh && audioCaution) {
        finalCaution = audioCaution;
    } else if (isTextHigh) {
        finalCaution = "Suspicious patterns detected in conversation history.";
    } else if (isAudioHigh) {
        finalCaution = "Suspicious keywords detected in recent audio.";
    }

    if (sendAlert) {
      console.log(`🚨 ALERT TRIGGERED!`);
      console.log(`   Audio Risk: ${audioRisk}`);
      console.log(`   Text Risk:  ${textRisk}`);
      console.log(`   Message:    ${finalCaution}`);
    }

    // ---------------------------------------------------------
    // CLEANUP & RESPONSE
    // ---------------------------------------------------------
    if (phoneCallState === 'end') {
      console.log(`\n🛑 Call Ended. Memory Cleared.`);
      delete phoneCallChunks[phoneLogId];
    }

    res.json({ 
      phoneLogId, 
      result: { 
        transcript: transcriptText,
        ...textResult 
      }, 
      generatedNewId, 
      send_alert: sendAlert, 
      caution_message: finalCaution 
    });

  } catch (err) {
    console.error("Controller Error:", err);
    res.status(500).json({ error: err.message });
  } finally {
    if (filePath) {
      fs.promises.unlink(filePath).catch(() => {});
    }
  }
}