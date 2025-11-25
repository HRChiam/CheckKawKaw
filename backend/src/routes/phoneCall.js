const express = require('express');
const router = express.Router();

router.post('/start', (req, res) => {
    res.json({ success: true, message: 'Phone call start endpoint working!' });
});

router.post('/end', (req, res) => {
    res.json({ success: true, message: 'Phone call end endpoint working!' });
});

module.exports = router;
