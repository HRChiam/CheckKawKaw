import JamAI from "jamaibase";

const jamai = new JamAI({
  token: "", //removeeeeeeeeeeee before commit
  projectId: "" //removeeeeeeeeeeeeeee before commit
});

export async function addTextRow() {
  try {
    const result = await jamai.table.addRowStream({
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

  } catch (err) {
    console.error("❌ JamAI API Message:", err.message);
  }
}

console.log("📌 Running standalone JamAI test…");
addTextRow();