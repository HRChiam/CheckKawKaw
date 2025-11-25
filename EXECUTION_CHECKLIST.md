# CheckKawKaw Frontend - Step-by-Step Execution Guide

## 📋 DO THIS NOW (In Order)

### **STEP 1: Create Android Emulator** (15 min)

```
1. Open Android Studio
2. Click "Device Manager" (bottom right or Tools menu)
3. Click "Create device"
4. Select "Pixel 4"
5. Select "API 33" or higher
6. Click "Finish"
7. Click "Play" button to start
8. Wait 30-60 seconds for boot
```

**✅ Done when:** You see Android phone on screen with home screen

---

### **STEP 2: Verify Emulator Works**

Open PowerShell:
```powershell
flutter devices
```

**✅ Expected output:**
```
Found 2 connected devices:

Pixel 4 API 33 (mobile) • emulator-5554 • android-x86_64
Windows (desktop)       • windows       • windows-x64
```

---

### **STEP 3: Run CheckKawKaw App**

```powershell
cd c:\Users\xwlim\GitHub\CheckKawKaw\frontend
flutter pub get
flutter run
```

**⏱️ Wait:** 1-2 minutes while it compiles

**✅ Done when:** App appears on emulator with home screen

---

### **STEP 4: Test Text Analysis (SCAM Detection)**

**On the app:**
1. Tap **📝 Analyze Text Message**
2. Type: `Click here to verify your account`
3. Tap **Analyze**

**✅ Expected result:**
```
⚠️ LIKELY SCAM
Confidence: 92.0%

Analysis:
This message contains suspicious keywords 
("click") commonly used in phishing scams...
```

---

### **STEP 5: Test Text Analysis (SAFE)**

**On the app:**
1. Go back (Android back button)
2. Tap **📝 Analyze Text Message** again
3. Type: `Hey, how are you?`
4. Tap **Analyze**

**✅ Expected result:**
```
✅ APPEARS SAFE
Confidence: 15.0%

Analysis:
This message appears to be legitimate 
based on content analysis.
```

---

### **STEP 6: Test Image Analysis**

**On the app:**
1. Go back
2. Tap **🖼️ Analyze Image**
3. Tap **Pick Image from Gallery**
4. Select any image from gallery
5. Tap **Analyze Recording**

**✅ Expected:** Shows mock scam result

---

### **STEP 7: Test Audio Analysis**

**On the app:**
1. Go back
2. Tap **🎤 Record / Upload Audio**
3. Tap **Start Recording**
4. Tap **Stop Recording**
5. Tap **Analyze Recording**

**✅ Expected:** Shows mock safe result

---

### **STEP 8: Test Hot Reload**

**In the app:**
1. Go back to any screen
2. In PowerShell, press `r` and Enter

**✅ Expected:** App refreshes without restarting

---

## 🎓 After Testing: Learn the Code

Open `c:\Users\xwlim\GitHub\CheckKawKaw\frontend\lib\main.dart` and read:

1. What is `void main()`?
2. What is `MyApp` class?
3. What are the 3 screen classes?
4. How does `_analyze()` work?
5. What is the difference between mock data and real API?

**Key lines to understand:**
- Line 76-125: `TextAnalysisScreen` class (most important)
- Line 101-120: `_analyze()` function (how results are generated)

---

## ❓ When You're Done

Message me and say:
- "App is running on emulator ✅"
- "All 4 tests passed ✅"
- "I understand StatefulWidget ✅"

Then we'll move to **Step 5: Add Real Audio Recording**

---

## 🆘 If Something Goes Wrong

### **App won't run:**
```powershell
flutter clean
flutter pub get
flutter run
```

### **Emulator too slow:**
- Just wait, it's normal
- Or enable hardware acceleration in BIOS

### **Can't see emulator:**
```powershell
flutter emulators
flutter emulators launch Pixel_4_API_33
```

### **Something else:**
- Tell me the error message
- I'll help debug

---

**You've got this! 🚀 Start with STEP 1 and message me when done.**
