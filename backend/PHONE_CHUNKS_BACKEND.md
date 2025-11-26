# Phone Chunks Backend Documentation
shinshin note:
- To test the `/phone/chunk` endpoint using curl, you can use the following command in powershell:
```bash
curl.exe -X POST http://localhost:3000/phone/chunk `
  -H "Content-Type: multipart/form-data" `
  -F "audio=@C:/Users/ShinYeong/Downloads/ai voice 2.mp3"
```
## Overview
This backend handles phone call audio analysis by accepting audio chunks (e.g., mp3/wav files) from the frontend, uploading them to Jamaibase, and then analyzing them using the JamAI API. The system is designed to process audio in real time (chunk by chunk) and also supports final analysis after the call ends.

---

## Data Flow

1. **Frontend Uploads Audio Chunk**
   - The frontend sends a POST request to `/phone/chunk` with an audio file (field name: `file`, e.g., `audio.mp3` or `audio.wav`).

2. **Multer Handles File Upload**
   - The backend uses the `multer` middleware to receive and store the uploaded file in `storage/phoneChunks/`, preserving the original file extension for MIME type detection.
   - Responsible file: `src/routes/phoneCall.js`

3. **Controller Processes the Chunk**
   - The controller function `analyzePhoneChunk` (in `src/controllers/phoneChunkController.js`) receives the uploaded file's path and passes it to the JamAI utility.
   - Responsible file: `src/controllers/phoneChunkController.js`

4. **JamAI Utility Uploads to Jamaibase**
   - The utility function `addPhoneRow` (in `src/utils/jamAI.js`) uploads the audio file to Jamaibase using the `/api/v2/files/upload` endpoint.
   - The correct MIME type is set based on the file extension (using `path` and optionally `mime` packages).
   - Jamaibase returns a `file_id`.
   - Responsible file: `src/utils/jamAI.js`

5. **JamAI Utility Calls Table Row API**
   - `addPhoneRow` then calls the JamAI table row API, passing the `file_id` as the value for the `audio` column (and any other required columns, e.g., `phone-call-state`).
   - The JamAI API analyzes the audio and returns the result.
   - Responsible file: `src/utils/jamAI.js`

6. **Controller Returns Result and Cleans Up**
   - The controller sends the analysis result back to the frontend as a JSON response.
   - **Automatic Cleanup:** After processing (success or error), the uploaded audio file is automatically deleted from storage to save disk space and keep the server clean.

---

## Dependencies Used

- **express**: Web framework for Node.js, handles routing and middleware.
- **multer**: Middleware for handling `multipart/form-data` (file uploads).
- **axios**: Promise-based HTTP client for making requests to Jamaibase APIs.
- **form-data**: Used to construct multipart form data for file uploads to Jamaibase.
- **fs**: Node.js built-in module for file system operations (reading uploaded files).
- **path**: Node.js built-in module for handling file paths and extensions.
- **dotenv**: Loads environment variables from `.env` file.
- **jamaibase**: JamAI SDK for interacting with JamAI table APIs.

---

## Key Files and Their Responsibilities

- `src/routes/phoneCall.js`: Defines the `/phone/chunk` endpoint and configures multer to store files with their original extension.
- `src/controllers/phoneChunkController.js`: Handles the logic for processing each audio chunk, calling the JamAI utility, returning the result, and automatically deleting the uploaded file after processing.
- `src/utils/jamAI.js`: Contains the logic for uploading files to Jamaibase, calling the JamAI table API, and formatting the result.
- `storage/phoneChunks/`: Directory where uploaded audio chunks are temporarily stored before being sent to Jamaibase.

---

## Example Data Flow

1. **Frontend:**
   - Sends: `POST /phone/chunk` with `file=@audio.mp3`
2. **Backend Route:**
   - `multer` saves as `storage/phoneChunks/audio-<timestamp>.mp3`
3. **Controller:**
   - Calls `addPhoneRow('storage/phoneChunks/audio-<timestamp>.mp3')`
4. **JamAI Utility:**
   - Uploads file to Jamaibase, gets `file_id`
   - Calls JamAI table API with `{ audio: file_id, ... }`
   - Returns analysis result
5. **Controller:**
   - Sends result to frontend

---

## Notes
- The field name for the file upload from the frontend must match the one expected by multer (currently `file`).
- The audio file must have a valid extension (`.mp3` or `.wav`) for correct MIME type detection.
- Uploaded audio files are automatically deleted from storage after processing is complete.
- Environment variables `JAMAI_TOKEN` and `JAMAI_PROJECT_ID` must be set in `.env` for authentication with Jamaibase.

---

For further details, see the code in the referenced files or ask for a specific flow or code sample.
