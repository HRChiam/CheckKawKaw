# 🔗 Link
1. Demo Video:
2. Presentation Slides:

# 📱 CheckKawKaw – Scam Detection App  
Full-stack mobile app with AI-powered scam detection for text, images, audio, and phone calls.

---

# 🚀 Project Structure

```
CheckKawKaw/
│
├── backend/        # Node.js + Express + JamAI analysis
└── frontend/       # Flutter mobile app
```

---

# ⚙️ Requirements

## Backend
- Node.js 18+
- npm 9+

## Frontend
- Flutter SDK 3.16+
- Android Studio (Pixel 9 emulator API 35+ recommended)

---

# 🔧 Backend Setup

### 1. Install dependencies
```bash
cd backend
npm install
```
### 2. Create Jam AI Base Project
Download CheckKawKaw.parquet
Import Project on Jam AI Base

### 3. Create `.env` file
Inside `backend/.env`:
```
PORT:3000
JAMAI_TOKEN=your_token_here
JAMAI_PROJECT_ID=your_project_id_here
```

### 4. Start backend server
```bash
npm start
```

Backend URL:
```
http://localhost:3000
```

---

# 📱 Frontend Setup (Flutter)

### 1. Install Flutter dependencies
```bash
cd frontend
flutter pub get
```

### 2. Run the Flutter app
```bash
flutter run
```

Make sure:
- Emulator = Pixel 9 / API 35 or API 36
- Permissions for Phone & Notifications are granted
- Backend is running first

---

# 🧪 Key Features

### ✅ Text Scam Detection  
Analyze suspicious text messages.

### ✅ Image Scam Detection  
Detect fake bank UIs, phishing pages, edited receipts.

### ✅ Audio Scam Detection  
Analyze voice recordings for scam patterns.

### ✅ Unknown Caller Alerts  
Warn user before they answer unknown callers.

### ✅ Post-Call Safety Reminder  
Notification after call ends asking if user shared private info.

---

# ▶️ Quick Start (Both Backend + Frontend)

```
# Start backend
cd backend
npm install
npm start

# Start frontend
cd frontend
flutter pub get
flutter run
```

---

# 📞 Call Detection Notes

To enable call detection:

- Use Android emulator API ≥ 35
- Enable these permissions:
  - READ_PHONE_STATE
  - READ_PHONE_NUMBERS
  - READ_CALL_LOG
  - POST_NOTIFICATIONS
  - FOREGROUND_SERVICE

---

# 🛠 Troubleshooting

### Backend errors
```bash
npm install
npm start
```

### Flutter errors
```bash
flutter clean
flutter pub get
flutter run
```

### Notifications not showing
- Ensure Notification permission is ON
- Restart app
- Ensure API 35+ device

### Incoming call detection not working
- Must use emulator API 35 or 36
- All phone permissions must be allowed

---

# 📄 License
This project is for educational and demo purposes only.

---

# 👨‍💻 Developer
Created with ❤️ using Flutter + Node.js + JamAI.
