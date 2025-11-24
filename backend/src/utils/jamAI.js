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
        text: `Good Night
        World!
        :-)`
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
    console.log("✅ AI Output Text:", aiOutput);


  } catch (err) {
    console.error("❌ JamAI API Message:", err.message);
  }
}

console.log("📌 Running standalone JamAI test…");
addTextRow();