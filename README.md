# MemoZen

**Learn faster. Remember longer.**

MemoZen is a premium, offline-first spaced-repetition study app built with Flutter. It helps you organize topics, schedule revisions, track study time, and retain knowledge using proven spaced repetition techniques.

## Features

- **Spaced Repetition Engine** — Auto-generates revision schedules using 1-7-30-90 day cycles with custom cycle support
- **Topic Management** — Organize topics by subject groups, track progress, and manage revision events
- **Home Dashboard** — See due revisions, study streak, completion stats, and quick actions
- **Calendar View** — Browse months, select dates, and view revision events
- **Time Logging** — Log study sessions with quick buttons (15m, 30m, 1h, 2h) or manual entry
- **Analytics** — Charts for daily trends, subject distribution, top topics, and revision progress
- **Multiple Themes** — 6 color themes (Teal, Ocean, Sunset, Lavender, Emerald, Dark) with light/dark/auto mode
- **Notifications** — Local reminders for upcoming revisions, missed events, and daily study prompts
- **Local Storage** — Fully offline with Isar database — no account required
- **Backup & Restore** — Export and import your data
- **100% Free** — All features unlocked, no subscriptions, no paywalls

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (stable) |
| Language | Dart 3 |
| State Management | Riverpod |
| Navigation | go_router |
| Database | Isar v2 |
| Charts | fl_chart |
| Notifications | flutter_local_notifications |
| Local Storage | shared_preferences |
| CI/CD | GitHub Actions |

## Project Structure

```
lib/
├── core/
│   ├── constants/        # App constants, default values
│   ├── services/         # Isar, Notifications
│   ├── theme/            # Color themes, theme provider
│   ├── utils/            # Helpers, formatting
│   └── widgets/          # Reusable UI components
├── features/
│   ├── add_topic/        # Add/Edit topic screen
│   ├── analytics/        # Analytics dashboard
│   ├── auth/             # Welcome/onboarding screen
│   ├── calendar/         # Calendar with revision events
│   ├── home/             # Home dashboard
│   ├── settings/         # Account & settings
│   ├── time_logging/     # Study time logging
│   └── topics/           # Topics list & management
├── models/               # Data models (Isar collections)
├── repositories/         # Data access layer
├── state/                # App shell with bottom nav
└── main.dart             # App entry point & routing
```

## Getting Started

### Prerequisites

- Flutter SDK 3.19+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Android SDK (for APK builds)
- Java 17 (for Android builds)

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/memozen.git
cd memozen

# Install dependencies
flutter pub get

# Generate Isar model files
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (split by ABI)
flutter build apk --release --split-per-abi

# Release AAB (for Play Store)
flutter build appbundle --release
```

## GitHub Actions

The project includes a complete CI/CD workflow (`.github/workflows/build.yml`) that:

1. Runs on push to `main` and manual dispatch
2. Sets up Flutter stable and Java 17
3. Caches dependencies for faster builds
4. Runs `flutter pub get` + `build_runner` + `flutter analyze` + `flutter test`
5. Builds release APK (split by ABI) and AAB
6. Uploads both as build artifacts (retained for 30 days)

### Manual Trigger

Go to **Actions** → **Build MemoZen APK** → **Run workflow** → select branch → **Run**

Download artifacts from the completed workflow run.

## Android Requirements

- **minSdk**: 21 (Android 5.0)
- **targetSdk**: 34 (Android 14)
- **compileSdk**: 34

## License

This project is for educational purposes. The code is original and does not contain copyrighted assets from any reference application.

---

Built with Flutter. Powered by spaced repetition.
