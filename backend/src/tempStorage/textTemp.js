// backend/src/tempStorage/textTemp.js
import { detectScam } from "../controllers/textController.js";

async function test() {
  const textMessage = `
    Dear Customer, your bank account has been temporarily suspended due to suspicious activity.
    To avoid permanent closure, please verify your identity within 30 minutes.
    Click the link below to reactivate your account:
    👉 http://secure-bank-verification-update.com/login
  `;

  const result = await detectScam(textMessage);
  console.log("Text Scam Result:", result);
}

test();
