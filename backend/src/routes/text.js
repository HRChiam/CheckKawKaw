const express = require('express');
const router = express.Router();

// Placeholder controller function
router.post('/', (req, res) => {
    res.json({ success: true, message: 'Text scam detection endpoint working!' });
});

module.exports = router;
