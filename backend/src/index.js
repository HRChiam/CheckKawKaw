require('dotenv').config(); // Load .env
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const textRoutes = require('./routes/text');
const imageRoutes = require('./routes/image');
const audioRoutes = require('./routes/audio');
const phoneCallRoutes = require('./routes/phoneCall');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use('/detect/text', textRoutes);
app.use('/detect/image', imageRoutes);
app.use('/detect/audio', audioRoutes);
app.use('/phone', phoneCallRoutes);

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
