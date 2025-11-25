import JamAI from "jamaibase";

const jamai = new JamAI({
  token: "", //removeeeeeeeeeeeeeeeee before commit
  projectId: "" //removeeeeeeeeeeeeeeeee before commit
});

export async function addTextRow() {
  try {
    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "text-detect-scam",
      data: [{
        text:textMess
      }]
    });

    const aiOutput = result.rows[0].columns['justification-scam'].choices[0].message.content;
    console.log("✅ AI Output Text:", aiOutput);


  } catch (err) {
    console.error("❌ JamAI API Message:", err.message);
    return null;
  }
}
