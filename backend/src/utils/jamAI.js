import JamAI from "jamaibase";

const jamai = new JamAI({
  token: "jamai_pat_088e57c5c7582f1b0f819a3df74f3ed844e87044ffc8091d", //removeeeeeeeeeeeeeeeee before commit
  projectId: "proj_1e9d442c28ddd05c8092b95e" //removeeeeeeeeeeeeeeeee before commit
});

export async function addTextRow(textMess) {
  try {
    const result = await jamai.table.addRow({
      table_type: "action",
      table_id: "text-detect-scam",
      data: [{
        text:textMess
      }]
    });

    const aiOutput = result.rows[0].columns['justification-scam'].choices[0].message.content;
    //console.log("✅ AI Output Text:", aiOutput);
    return aiOutput;

  } catch (err) {
    console.error("❌ JamAI API Message:", err.message);
    return null;
  }
}


