import JamAI from "jamaibase";
import 'dotenv/config';


const jamai = new JamAI({
  token: "",
  projectId: ""
});

/*
const jamai = new JamAI({
  token: process.env.token,
  projectId: process.env.projectId
});*/


export async function addTextRow(textMess) {
  try {
    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "text-detect-scam",
      data: [{
        text: textMess
      }]
    });

    const aiResult = result.rows[0].columns['explanation'].choices[0].message.content;
    //console.log("✅ AI Output Text from jamai:", aiResult);
    return aiResult;

  } catch (err) {
    console.error("❌ JamAI API Message:", err.message);
    return null;
  }
}


// Test JamAI
(async () => {
  const result = await addTextRow("This is a sample text to check for scam.");
  console.log("Test output:", result);
})();

