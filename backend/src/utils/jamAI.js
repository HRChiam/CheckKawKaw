// jamAI.js
import dotenv from 'dotenv';
dotenv.config();
import JamAI from "jamaibase";

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


// Test JamAI 
//THIS IS JUST FOR TESTING PURPOSE ONLY. REMOVE LATER.
/*
(async () => {
  const result = await addTextRow("This is a sample text to check for scam.");
  console.log("Test output:", result);
})();*/

