// // backend/src/controllers/textController.js
import { addTextRow } from "../utils/jamAI.js";

/**
 * Controller function to detect scam in text
 * @param {string} text - The input text to check
 * @returns {string|null} - AI result or null if error
 */

export async function analyzeText(req,res) {
    try{
        const{textMess}=req.body;

        if(!textMess){
            return res.status(400).json({error:"No text provided"});
        }

        console.log("Processing text:", textMess);
        const aiResult = await addTextRow(textMess);
        console.log("AI Result:", aiResult);

        if (!aiResult) {
            return res.status(502).json({ 
                success: false, 
                error: "AI service failed to return data." 
            });
        }

        console.log("AI Result:", aiResult);
        return res.json({
            success: true,
            result:aiResult
        });

    }catch(err){
        console.error("Error:",err);
        return res.status(500).json({error:"Server error"});
    }
}
