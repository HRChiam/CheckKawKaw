# Phone Call Chunk Analysis: Data Flow Documentation

## 1. Overview
This document describes the end-to-end data flow for phone call chunk analysis, from the Flutter frontend, through the Node.js backend, to JamAI (Jamaibase), and back.

---

## 2. Data Flow Steps

### A. Frontend (Flutter)
1. **Call Recording Initiation**
   - User approves call recording via notification.
   - `CallRecorder.startRecording()` starts audio recording and sets `phone_call_state = "start"`.

2. **Chunk Creation and Upload**
   - Every 30 seconds, `CallRecorder.sendChunk()` stops the current recording, saves the chunk, and immediately starts a new one.
   - Each chunk is uploaded using `UploadService.uploadFile`, sending:
     - The audio file (field: `file`)
     - `phone-call-state` ("start", "middle", or "end")
     - `phone-log-id` (empty for the first chunk, then set by backend)

3. **Final Chunk**
   - When the call ends, `CallRecorder.stopAndSendFinal()` sends the last chunk with `phone-call-state = "end"`.

---

### B. Backend (Node.js/Express)
1. **Chunk Reception**
   - `/phone/chunk` endpoint receives the multipart form-data with file, phone-call-state, and phone-log-id.
   - Multer saves the audio file to disk.

2. **phone-log-id Management**
   - If `phone-call-state` is "start" or no phone-log-id is provided, backend queries JamAI for all rows and computes the largest phone-log-id in JavaScript (not relying on JamAI sort).
   - For subsequent chunks, the frontend sends the current phone-log-id.

3. **Chunk Processing**
   - Backend calls `addPhoneRow` (in `jamAI.js`), uploading the audio to Jamaibase and sending metadata (audio, phone-call-state, phone-log-id) to JamAI.
   - The backend stores each chunk's result in memory (by phone-log-id).

4. **Final Analysis**
   - When a chunk arrives with `phone-call-state = "end"`, backend aggregates all transcriptions/results for that phone-log-id.
   - Backend calls `addFinalPhoneAnalysis` (in `jamAI.js`), sending the combined transcript and phone-log-id to JamAI for a comprehensive analysis.
   - The final analysis result is returned to the frontend.

---

### C. JamAI (Jamaibase)
1. **Chunk Analysis**
   - Receives each chunk (audio, phone-call-state, phone-log-id) and processes for risk/scam detection.
   - Returns analysis result (e.g., risk level, caution message, transcript).

2. **Final Analysis**
   - Receives the full transcript and phone-log-id for the call.
   - Returns a comprehensive analysis (e.g., overall risk, summary, recommendations).

---

### D. Data Flow Backwards
1. **Backend to Frontend**
   - For each chunk: returns phone-log-id and chunk analysis result.
   - For final chunk: returns phone-log-id and final analysis result.
2. **Frontend**
   - Updates local phone_log_id as needed.
   - Displays notifications if high risk is detected.
   - Can display or log the final analysis for the user.

---

## 3. Sequence Diagram (Textual)

```
[User]
  |
  | (approves recording)
  v
[Flutter App] ---(audio chunk + state + log-id)---> [Node.js Backend] ---(audio, state, log-id)---> [JamAI]
  ^                                                                                                 |
  |<-------------------(analysis result, log-id)-------------------|<-----------------------------|
  |
  | (repeat for each chunk)
  |
  | (on call end: send final chunk)
  v
[Flutter App] <---(final analysis, log-id)--- [Node.js Backend] <---(final analysis)--- [JamAI]
```

---

## 4. Notes
- All chunk uploads and final analysis are tied together by phone-log-id.
- The backend is responsible for phone-log-id assignment and aggregation.
- The backend now fetches all rows and computes the true max phone-log-id in JavaScript, ensuring correct assignment even if JamAI's sort is unreliable.
- The frontend only needs to track and pass the current phone-log-id.
- For production, backend should use persistent storage instead of in-memory for chunk results.
