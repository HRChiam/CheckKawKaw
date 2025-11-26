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

app.get('/debug/jamai', async (req, res) => {
    try {
        const mod = await import('./utils/jamAI.js');
        const getJamaiStatus = mod.getJamaiStatus || (() => ({ tokenPresent: false, projectIdPresent: false, initialized: false }));
        const status = getJamaiStatus();
        res.json({ success: true, jamai: status });
    } catch (e) {
        console.error('Error loading jamAI diagnostics:', e && e.message ? e.message : e);
        res.status(500).json({ success: false, error: 'Could not retrieve JamAI status' });
    }
});

const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, '0.0.0.0', (err) => {
    if (err) {
        console.error("❌ Error starting server:", err);
        return;
    }
    console.log(`✅ Server running on port ${PORT}`);
    console.log(`   Accessible locally at http://localhost:${PORT}`);
});

server.on('error', (e) => {
    if (e.code === 'EADDRINUSE') {
        console.log('❌ Port 3000 is already in use!');
    } else {
        console.log('❌ Server error:', e);
    }
});