# CheckKawKaw Frontend - Complete Beginner's Guide

## 📱 What You're Building

**CheckKawKaw** is a scam-detection app that:
1. **Analyzes text messages** → tells user if it's a scam
2. **Analyzes images** → detects phishing UI in screenshots
3. **Records phone calls** → listens for scam patterns in voice conversations
4. **Shows incoming call alerts** → asks user to record unknown callers

**Your role:** Build the Flutter UI that users interact with

---

## 🎯 Your Learning Path (10 Steps)

### **Step 1: Create Android Emulator** ⏱️ ~15 minutes

An **emulator** is a fake Android phone that runs on your Windows computer.

**DO THIS:**
1. Open **Android Studio**
2. Click **Device Manager** (bottom-right)
3. Click **Create device**
4. Choose **Pixel 4**
5. Choose **API 33** (or higher)
6. Click **Finish**
7. Click **Play ▶** button to start emulator
8. Wait 30-60 seconds (it's slow first time!)

**Verify it works:**
```powershell
flutter devices
```

You should see:
```
Pixel 4 API 33 (mobile) • emulator-5554 • android-x86_64
```

---

### **Step 2: Run App on Emulator** ⏱️ ~5 minutes

```powershell
cd c:\Users\xwlim\GitHub\CheckKawKaw\frontend
flutter pub get
flutter run
```

**Expected:**
- App compiles (~1-2 minutes first time)
- App loads on emulator
- You see **CheckKawKaw** home screen with 3 buttons

**What you see on screen:**
```
CheckKawKaw
━━━━━━━━━━━━━━━━━━━

📝 Analyze Text Message
🖼️ Analyze Image
🎤 Record / Upload Audio

✓ Text message analysis
✓ Image scam detection
✓ Voice call scam detection
✓ Incoming call alerts (coming)
```

---

### **Step 3: Test All Mock Screens** ⏱️ ~10 minutes

#### **Test 1: Text Analysis (Should detect "click" as scam)**

1. Tap **📝 Analyze Text Message**
2. Type: `"Click here to verify your account"`
3. Tap **Analyze**

**Expected result:**
```
⚠️ LIKELY SCAM
Confidence: 92.0%

Analysis:
This message contains suspicious keywords 
("click") commonly used in phishing scams. 
Be cautious of clicking unknown links.
```

#### **Test 2: Text Analysis (Safe message)**

1. Go back (Android back button)
2. Tap **📝 Analyze Text Message** again
3. Type: `"Hey, how are you?"`
4. Tap **Analyze**

**Expected result:**
```
✅ APPEARS SAFE
Confidence: 15.0%

Analysis:
This message appears to be legitimate 
based on content analysis.
```

#### **Test 3: Image Analysis**

1. Go back
2. Tap **🖼️ Analyze Image**
3. Tap **Pick Image from Gallery**
4. Choose any image
5. Tap **Analyze Recording**

**Expected result:** (hardcoded for now)
```
⚠️ LIKELY SCAM
Confidence: 87.0%

Analysis:
Image contains text with common phishing 
phrases and suspicious UI elements...
```

#### **Test 4: Audio Analysis**

1. Go back
2. Tap **🎤 Record / Upload Audio**
3. Tap **Start Recording**
4. Tap **Stop Recording**
5. Tap **Analyze Recording**

**Expected result:** (hardcoded for now)
```
✅ NO SCAM DETECTED
Confidence: 73.0%

Analysis:
Conversation appears legitimate. 
No suspicious patterns detected...
```

---

## 📚 Understanding the Code (Beginner Concepts)

### **What is `main.dart`?**

`main.dart` is the **entry point** of your app. It's like the "start" button.

```dart
void main() {
  runApp(const MyApp());
}
```

Translation: "Run my app!"

---

### **What is a Widget?**

A **Widget** is a piece of UI. Everything in Flutter is a widget:
- Text box = `TextField` widget
- Button = `ElevatedButton` widget
- Screen = `Scaffold` widget
- App = `MaterialApp` widget

Think of widgets like LEGO blocks. You stack them together to build screens.

---

### **What is `StatefulWidget`?**

A widget that **can change** (has state that changes).

Example: `TextAnalysisScreen` is stateful because:
- User types text (changes)
- Tap button → loading spinner appears (changes)
- Result appears (changes)

```dart
class TextAnalysisScreen extends StatefulWidget {
  // This widget can have changing data
}

class _TextAnalysisScreenState extends State<TextAnalysisScreen> {
  // This is where the changing data lives
  bool _loading = false;
  Map<String, dynamic>? _result;
}
```

---

### **What is `setState()`?**

When you want to **update the UI**, you use `setState()`.

Example: Show loading spinner while analyzing

```dart
setState(() {
  _loading = true;  // Tell Flutter: update the UI!
});

// Do some work...
await Future.delayed(const Duration(seconds: 1));

setState(() {
  _result = { /* result data */ };
  _loading = false;  // Update UI again
});
```

Without `setState()`, the UI doesn't refresh even though your data changed.

---

### **What is Navigation?**

Moving between screens. In CheckKawKaw:

**Home Screen** → (user taps) → **Text Analysis Screen** → (user presses back) → **Home Screen**

```dart
// Go to another screen
Navigator.pushNamed(context, TextAnalysisScreen.routeName);

// Define route in MyApp
routes: {
  TextAnalysisScreen.routeName: (_) => const TextAnalysisScreen(),
  ImageAnalysisScreen.routeName: (_) => const ImageAnalysisScreen(),
  AudioAnalysisScreen.routeName: (_) => const AudioAnalysisScreen(),
},
```

---

### **What is `TextEditingController`?**

It **captures user input** from a text box.

```dart
final TextEditingController _controller = TextEditingController();

// In UI
TextField(
  controller: _controller,
  // User types here...
);

// Get text user typed
String userText = _controller.text;
```

---

## 🔧 Current App Structure

```
main.dart (464 lines)
│
├─ MyApp (the app itself)
│  └─ routes: TextAnalysis, ImageAnalysis, AudioAnalysis
│
├─ HomeScreen (3 buttons)
│
├─ TextAnalysisScreen (type message → see mock result)
│  ├─ _TextAnalysisScreenState
│  └─ _analyze() (simulates 1 sec delay, returns mock data)
│
├─ ImageAnalysisScreen (pick image → see mock result)
│  ├─ _ImageAnalysisScreenState
│  └─ _pickImage() + _analyze()
│
├─ AudioAnalysisScreen (fake record → see mock result)
│  ├─ _AudioAnalysisScreenState
│  ├─ _toggleRecording()
│  └─ _analyze()
│
└─ ApiService (placeholder for backend calls)
   └─ _base = 'http://10.0.2.2:3000'
```

---

## 💡 Mock Data Explained

Currently, all results are **hardcoded** (fake):

### **Text Analysis Mock Logic:**
```dart
_result = {
  'isScam': text.toLowerCase().contains('click') || text.toLowerCase().contains('verify'),
  'confidence': text.toLowerCase().contains('click') ? 0.92 : 0.15,
  'explanation': text.toLowerCase().contains('click')
      ? 'This message contains suspicious keywords...'
      : 'This message appears to be legitimate...',
};
```

**English:** If the text has the word "click", mark it as scam. Otherwise, mark it safe.

### **Image Analysis Mock:**
```dart
_result = {
  'isScam': true,  // Always returns true (scam)
  'confidence': 0.87,
  'explanation': 'Image contains phishing UI...',
};
```

### **Audio Analysis Mock:**
```dart
_result = {
  'isScam': false,  // Always returns false (not scam)
  'confidence': 0.73,
  'explanation': 'Conversation appears legitimate...',
};
```

---

## 🚀 Next Steps (After Testing)

### **Step 4: Learn Flutter Basics**
- Read the code comments in `main.dart`
- Understand how `_analyze()` works
- Try changing mock data and run `flutter run` (it hot-reloads!)

### **Step 5: Add Real Audio Recording**
- Install `record` package
- Use microphone to actually record audio
- Save to phone storage

### **Step 6: Add Runtime Permissions**
- Ask user for microphone permission
- Ask user for camera permission
- Handle if user denies

### **Step 7: Incoming Call Detection** (Android-specific)
- Detect unknown incoming calls
- Show notification asking "Record this call?"
- If yes, start recording
- After call ends, analyze recording

### **Step 8: Connect to Backend**
- Replace mock `_analyze()` with real API calls
- Send text/image/audio to Node.js backend
- Backend uses Jamaibase AI to analyze
- Display real results

### **Step 9: Build APK**
- `flutter build apk --release`
- Sign APK
- Submit to Google Play Store

---

## 🎓 Learning Resources

**Official Flutter Docs:**
- https://flutter.dev/docs
- https://dart.dev/guides/language/language-tour

**Key Concepts to Learn:**
1. **Widgets** → Everything is a widget
2. **StatelessWidget vs StatefulWidget** → Does it change?
3. **setState()** → Update UI when data changes
4. **Navigation** → Move between screens
5. **Async/Await** → Do things that take time (API calls)
6. **Packages** → Libraries of code (image_picker, permission_handler)

---

## ✅ Beginner Checklist

- [ ] Emulator running and visible on screen
- [ ] `flutter run` works and app appears on emulator
- [ ] Home screen loads with 3 buttons
- [ ] Text analysis works (try "click" → scam, "hello" → safe)
- [ ] Image picker works (can select image)
- [ ] Audio record buttons work (fake recording)
- [ ] Back button navigation works
- [ ] Understand what StatefulWidget does
- [ ] Understand what setState() does
- [ ] Read and understand main.dart comments

---

## 🆘 Common Issues

**Issue:** App crashes on startup
**Solution:** Run `flutter clean && flutter pub get && flutter run`

**Issue:** Emulator super slow
**Solution:** Normal first time. Enable hardware acceleration in BIOS settings.

**Issue:** Can't pick images
**Solution:** This works when backend is ready. For now, it's mock data.

**Issue:** Don't understand a Flutter concept
**Solution:** Ask me! I'll explain with examples.

---

## 🎯 Your First Assignment

1. ✅ Get app running on emulator
2. ✅ Test all 3 mock screens
3. 📖 Read `main.dart` and understand the code structure
4. 💻 Try changing the mock data (e.g., change confidence to 0.50)
5. 🔄 Use hot reload (press `r` in terminal) to see changes instantly

**Then message me and we'll move to Step 4!**

Good luck! 🚀
