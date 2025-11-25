import express from "express";
const router = express.Router();

router.post('/', (req, res) => {
    res.json({ success: true, message: 'Audio detection endpoint working!' });
});

export default router;
