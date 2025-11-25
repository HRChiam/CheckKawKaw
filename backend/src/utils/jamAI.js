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
    /*
        const reader = result.getReader();

    while (true) {
        const { done, value } = await reader.read();
        if (done) {
            console.log("Done");
            break;
        }
        console.log(value);
        if (value) {
            console.log("abc",value?.choices[0]?.message.content);
        }
    }*/
    /*// Access the first row
    const firstRow = result.rows[0];

    // Replace 'justification-scam' with the actual column name where AI output is stored
    const aiOutput = firstRow.columns["scam-percentage"];

    console.log("✅ Final Row Output:", firstRow);
    console.log("📝 Justification / Scam Detection:", aiOutput);*/
    const aiOutput = result.rows[0].columns['justification-scam'].choices[0].message.content;
    //console.log("✅ AI Output Text:", aiOutput);
    return aiOutput;

  } catch (err) {
    console.error("❌ JamAI API Message:", err.message);
    return null;
  }
}

// console.log("📌 Running standalone JamAI test…");
// addTextRow();