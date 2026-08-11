# Numonics

**Master math, beautifully.** Numonics is a clean, minimal Flutter learning app:
daily math challenges, a multiple-choice quiz flow with instant feedback and
step-by-step explanations, and **Mathy** — an AI math tutor powered by Groq.

## Features

1. **Onboarding & auth** — a 3-slide intro plus real **Firebase email/password**
   sign-up / sign-in. New accounts get a profile document in Cloud Firestore.
2. **Home dashboard** — a personalized greeting, a weekly streak strip, a hero
   "Challenge your skills" card, and a grid of **Daily Challenges** with progress
   bars and difficulty tags.
3. **Quiz flow** — a progress bar, the Mathy question bubble (with an optional
   geometry diagram), tappable A/B/C/D options that turn green/coral on answer,
   a Correct / Not-quite feedback bar, and a slide-up **Explanation** sheet.
4. **Mathy (AI tutor)** — a chat screen that streams answers from Groq. The
   **API key and model name are read from Firestore** (`config/groq`), so no
   secrets live in the app bundle.
5. **Solve & Draw** (signature creative tool) — pick a formula (`a²+b²`,
   `a²−b²`, `a×b+c`, `(a+b)²`), enter values, and the parsed answer both
   *selects* and *sizes* one of 12 procedural ASCII patterns. The result screen
   shows the value, a step-by-step breakdown, and a swipeable pattern gallery.
6. **Lessons** — bite-size refreshers behind each formula, plus the full
   pattern gallery. Reached from **Home → Explore**.
7. **Progress & Profile** — XP, level, streak and per-challenge progress backed
   by the Firestore profile; Profile links to Privacy, Help and About pages.

## Architecture

```
lib/
  main.dart                     # entry: init Firebase, splash, top-level flow
  theme.dart                    # mint/teal design tokens + text styles
  models/
    user_profile.dart           # users/{uid} model (xp, streak, level…)
    challenge.dart              # Challenge / Question / Difficulty
  data/challenges.dart          # local seed catalog of challenges + questions
  math/
    parser.dart                 # tokenizer → shunting-yard → RPN evaluator
    formulas.dart               # formula catalog + step breakdowns
  art/pattern_engine.dart       # 12 scalable procedural ASCII patterns
  services/
    firebase_service.dart       # auth + Firestore profile + config/groq
    groq_service.dart           # streaming chat completions (SSE)
  state/app_state.dart          # ChangeNotifier bridging auth/profile → UI
  widgets/                      # common UI + ASCII viewer
  screens/                      # splash, onboarding, auth, home shell, home
                                #   tab, courses, quiz, explanation, mathy,
                                #   progress, profile, solve, results, learn,
                                #   info (privacy/help/about)
```

## Firebase setup

The project is already wired for the `numonics-226e1` Firebase project
(`firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`).
In the Firebase console make sure you have:

1. **Authentication → Sign-in method →** enable **Email/Password**.
2. **Firestore Database** created. Documents used:
   - `users/{uid}` — created automatically on sign-up:
     `{ name, email, xp, streak, solved, createdAt, lastActive }`
   - `config/groq` — **create this yourself** with your Groq credentials:
     ```
     apiKey: "gsk_..."                    // your Groq API key
     model:  "llama-3.3-70b-versatile"    // any Groq chat model id
     ```

### Suggested Firestore security rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    // A user can read/write only their own profile.
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    // Signed-in users can read the Groq config, but not modify it.
    match /config/{doc} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

> Note: reading the Groq key from a client means any signed-in user's device can
> obtain it. For production, proxy Groq through a Cloud Function / backend and
> keep the key server-side. The Firestore approach here matches the requested
> setup and is fine for prototypes and internal builds.

## Run it

```bash
flutter pub get
flutter run            # pick an iOS/Android device or simulator
flutter test           # data-model + boot smoke tests
flutter build web      # also compiles cleanly for web
```
