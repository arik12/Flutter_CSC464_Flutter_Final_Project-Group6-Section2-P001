# AI Language Learning App (P001)

A Flutter app where users select a language and chat with an AI tutor powered by Google's Gemini API. Chat sessions are persisted to Firebase Firestore.

## Tech Stack

- **Flutter** — Cross-platform UI framework
- **Firebase Firestore** — Real-time chat persistence
- **Provider** — State management
- **Google Generative AI (Gemini)** — AI language tutor

## Features

✅ Home screen with 8 languages to choose from
✅ Beautiful chat interface with user/AI message bubbles
✅ Real-time message streaming from Firestore
✅ Loading indicator while AI responds
✅ Full conversation context sent to Gemini (AI remembers history)
✅ Auto-scroll, timestamps, typing indicator
✅ Persistent sessions stored in Firestore

## Project Structure

```
lib/
├── main.dart                       # App entry point
├── firebase_options.dart           # Firebase config (regenerate this!)
├── models/
│   ├── chat_model.dart            # Chat session model
│   └── message_model.dart         # Individual message model
├── providers/
│   └── chat_provider.dart         # State management (Provider)
├── services/
│   ├── gemini_service.dart        # Gemini API wrapper
│   └── firestore_service.dart     # Firestore CRUD operations
├── screens/
│   ├── home_screen.dart           # Language selection
│   └── chat_screen.dart           # Chat interface
└── widgets/
    ├── message_bubble.dart        # Individual chat bubble
    └── chat_input.dart            # Text input + send button
```

## Firestore Schema

```
/chats/{chatId}
  ├── language: string
  ├── createdAt: timestamp
  └── /messages/{messageId}
      ├── sender: "user" | "ai"
      ├── message: string
      └── timestamp: timestamp
```

---

## 🚀 Setup Instructions

### Step 1: Create the Flutter Project

This folder contains the `lib/` code and `pubspec.yaml`. To make it runnable:

```bash
# Create a new Flutter project with the same name
flutter create ai_language_tutor
cd ai_language_tutor

# Replace the default lib/ folder and pubspec.yaml with the ones from this package
# (Copy lib/ and pubspec.yaml from this package INTO your new flutter project)

# Install dependencies
flutter pub get
```

### Step 2: Set Up Firebase

1. **Go to [Firebase Console](https://console.firebase.google.com/)** and create a new project.

2. **Enable Firestore Database**:
   - In the Firebase console, go to **Build → Firestore Database**
   - Click **Create database**
   - Start in **test mode** (for development)
   - Choose a location near you

3. **Install the FlutterFire CLI** (one-time):
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. **Configure Firebase for your Flutter app**:
   ```bash
   # Log in to Firebase first
   firebase login

   # Then from your project root, run:
   flutterfire configure
   ```
   This will automatically generate the real `lib/firebase_options.dart` replacing the placeholder.

5. **Firestore Security Rules** (for development only):
   In Firestore → Rules, paste:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true; // ⚠️ Open rules — only for dev!
       }
     }
   }
   ```

### Step 3: Get a Gemini API Key

1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in and click **Create API key**
3. Copy the key
4. Open `lib/services/gemini_service.dart`
5. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual key:
   ```dart
   static const String _apiKey = 'AIza...your-real-key...';
   ```

### Step 4: Run the App

```bash
flutter pub get
flutter run
```

Pick a device (Android emulator, iOS simulator, Chrome, etc.) and the app launches.

---

## 🧪 How It Works

1. **Home screen** — user picks a language from the grid
2. Tapping **Start Chat** calls `ChatProvider.startNewChat()`, which creates a `/chats/{chatId}` document in Firestore
3. User is navigated to the **Chat screen**
4. When the user sends a message:
   - It's saved to `/chats/{chatId}/messages` with `sender: "user"`
   - The full message history is pulled and formatted for Gemini's context
   - Gemini generates a response (loading indicator shown)
   - The AI response is saved to Firestore with `sender: "ai"`
5. The message list is a `StreamBuilder` listening to Firestore in real time, so new messages appear instantly

## 🔒 Production Considerations

- Move the Gemini API key to a `.env` file or secure backend (don't commit it)
- Add Firebase Authentication before using these apps publicly
- Tighten Firestore security rules to require `request.auth != null`
- Implement rate limiting on API calls
- Handle network errors more gracefully

## 📝 Notes

The `firebase_options.dart` file included here is a **placeholder**. You **must** run `flutterfire configure` to generate your real one — the app will not connect to Firebase otherwise.

---

**Project:** P001 — AI Language Learning App
**Stack:** Flutter + Firebase Firestore + Provider + Gemini API
