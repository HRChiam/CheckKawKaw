import express from "express";
const router = express.Router();

router.post('/', (req, res) => {
    res.json({ success: true, message: 'Image scam detection endpoint working!' });
});

export default router;
