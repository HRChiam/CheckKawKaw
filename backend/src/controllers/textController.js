// // backend/src/controllers/textController.js
import { addTextRow } from "../utils/jamAI.js";

/**
 * Controller function to detect scam in text
 * @param {string} text - The input text to check
 * @returns {string|null} - AI result or null if error
 */
export async function detectScam(text) {
  try {
    const result = await addTextRow(text); 
    return result;
  } catch (err) {
    console.error("TextController Error:", err.message);
    return null;
  }
}

export async function analyzeText(req,res) {
    try{
        const{text}=req.body;

        if(!text){
            return res.status(400).json({error:"No text provided"});
        }

        const aiResult = await addTextRow(text);

        return res.json({
            success: true,
            result:aiResult
        });

    }catch(err){
        console.error("Error:",err);
        return res.status(500).json({error:"Server error"});
    }
}

// // backend/src/controllers/textController.js
// import axios from "axios";
// import dotenv from "dotenv";
// dotenv.config();

// const JAMAI_API_URL = "https://api.jam.ai/v1/table/add"; // replace with the correct JamAI endpoint if different

// export async function detectScam(text) {
//   try {
//     const response = await axios.post(
//       JAMAI_API_URL,
//       {
//         table_type: "action",
//         table_id: "text-detect-scam",
//         data: [{ content: text }]
//       },
//       {
//         headers: {
//           Authorization: `Bearer ${process.env.JAMAI_API_KEY}`,
//           "Content-Type": "application/json"
//         }
//       }
//     );

//     // Adjust depending on API response structure
//     const result = response.data?.rows?.[0]?.output || "No response from JamAI";
//     return result;
//   } catch (err) {
//     console.error("JamAI HTTP Error:", err.response?.data || err.message);
//     return null;
//   }
// }
