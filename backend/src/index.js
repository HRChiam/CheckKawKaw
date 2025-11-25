import dotenv from 'dotenv';
dotenv.config();

import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';

import textRoutes from './routes/text.js';
import imageRoutes from './routes/Image.js';
import audioRoutes from './routes/audio.js';
import phoneCallRoutes from './routes/phoneCall.js';

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
