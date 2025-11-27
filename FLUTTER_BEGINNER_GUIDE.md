# ✅ CheckKawKaw Frontend – Complete Beginner’s Guide

## 📱 What You’re Building

**CheckKawKaw** is a scam-protection mobile app that provides:

- Unknown caller detection → warns user before answering
- Post-call safety reminders → asks if caller requested sensitive info
- Text scam analysis → phishing, OTP scams, impersonation
- Image scam analysis → fake bank UI, fake receipts, phishing screens
- Audio scam analysis → suspicious voice calls or voice notes

Your role:
Run, test, and understand the Flutter frontend that interacts with the backend AI.

---

# 🎯 Your Learning Path (10 Steps)

---

## STEP 1 – Create Android Emulator (≈15 minutes)

You must use **API 35+** for notifications & call detection.

### Do this:
1. Open Android Studio
2. Go to Device Manager
3. Click "Create Device"
4. Select "Pixel 9"
5. Select API 35 or API 36
6. Click Finish
7. Press the ▶ (Play) button to start emulator
8. Wait 30–60 seconds to boot

### Verify the emulator:
```powershell
flutter devices
```

### Expected output:
```
Pixel 9 API 36 (mobile) • emulator-5554 • android-x86_64
Windows (desktop)       • windows       • windows-x64
```

---

## STEP 2 – Run CheckKawKaw App

```powershell
cd C:\Users\xwlim\GitHub\CheckKawKaw\frontend
flutter pub get
flutter run
```

Expected:
- App compiles (1–2 mins)
- App opens on emulator
- “Permissions & Privacy” screen appears

---

## STEP 3 – Approve Required Permissions

On the screen:

Phone Calls  
Notifications  
[ Agree & Continue ]

Tap Agree & Continue  
Allow all permission popups

Without this → call detection WON’T work.

---

## STEP 4 – Test Text Scam Detection

In the app:
1. Tap 📝 Text
2. Enter:
Click here to verify your account
3. Tap Analyze Scam

Expected:
- High Risk
- Type: Phishing
- Explanation: contains “click”, “verify”
- Recommendation shown

---

## STEP 5 – Test Safe Text

1. Tap Scan Another Message
2. Tap 📝 Text
3. Enter:
hello
4. Tap Analyze Scam

Expected:
- Low Risk
- Explanation: short, harmless

---

## STEP 6 – Test Image Analysis

1. Tap 🖼 Image
2. Upload a PNG/JPG
3. Tap Analyze Scam

Expected:
- Real result from JamAI

---

## STEP 7 – Test Audio Analysis

1. Tap 🎤 Audio
2. Upload .mp3 or .wav
3. Tap Analyze Scam

Expected:
- Real audio analysis result

---

## STEP 8 – Test Unknown Caller Detection

In Android Emulator:

1. Click ⋮ (3-dot menu)
2. Select Phone
3. Enter any number
4. Click Call

### Expected Behavior:

### BEFORE answering (RINGING)
Notification:
Unknown Caller Detected  
Be careful. Do not share OTP, bank details…

### AFTER call ends (IDLE)
Notification:
Call Ended – Safety Check  
Did the caller ask for personal or banking info?

---

## STEP 9 – Test Hot Reload

In terminal:
```
r
```

Expected:
- UI refreshes instantly
- App does NOT restart

---

# 📚 Understanding Flutter Code (Beginner Level)

## What is main.dart?

The entry point of your app:

```dart
void main() {
  runApp(const MyApp());
}
```

Means: start the Flutter app.

---

## What is a Widget?

Everything in Flutter is a widget:

- Text
- Buttons
- Screens
- Images
- Entire app

---

## What is a StatefulWidget?

A widget that **changes** during runtime.

Example:  
- User typing text  
- Loading spinner  
- Scam result appears  

---

## What is setState()?

Tells Flutter: “Something changed, update UI!”

---

## App Structure

main.dart  
- PermissionsScreen  
- HomeScreen  
- TextAnalysisScreen  
- ImageAnalysisScreen  
- AudioAnalysisScreen  
- NotificationService  
- CallForegroundService  

---

# 🧪 Verification Checklist

✔ Emulator runs  
✔ App runs  
✔ Permissions granted  
✔ Text analysis works  
✔ Image analysis works  
✔ Audio analysis works  
✔ Incoming call detection works  
✔ Post-call reminder works  
✔ Hot reload works  
✔ You understand StatefulWidget  
✔ You understand setState()  

---

# 🆘 Troubleshooting

App crashes → run:
flutter clean  
flutter pub get  
flutter run

Notifications missing  
→ ensure API 35+ emulator  
→ ensure POST_NOTIFICATIONS permission enabled  

Call detection not working  
→ ensure READ_PHONE_STATE granted  
→ ensure foreground service is running  

---

# 🎯 Final Task

When done, message:

App running on emulator ✅  
Text/Image/Audio working ✅  
Call notifications working ✅  
I understand StatefulWidget & setState() ✅  
