# Sentiment Motivator

A Flutter mobile application that performs AI-powered sentiment analysis on user text and provides motivational feedback. Built for Android and iOS using Clean Architecture and the Claude AI API.

---

## Screenshots

> Add screenshots / screen recording here before submission.

---

## Getting Started

### Prerequisites

| Tool | Minimum version |
|------|----------------|
| Flutter SDK | 3.22.0 |
| Dart SDK | 3.1.0 |
| Android Studio / Xcode | Latest stable |

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/sentiment-motivator.git
cd sentiment-motivator
```

### 2. Configure your API key

Copy the example env file and add your Groq API key:

```bash
cp .env.example .env
```

Open `.env` and replace the placeholder:

```
GROQ_API_KEY=your_groq_api_key_here
GROQ_MODEL=llama-3.1-8b-instant
```

> **Important:** Never commit `.env` to version control. It is listed in `.gitignore`.

Get your **free** API key at [console.groq.com](https://console.groq.com) — no billing required.

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Generate mock files (required for tests)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the app

#### On Windows (with Android emulator)

> **Note:** Flutter and the Android SDK are not on the system PATH on this machine. Use the full paths below.

**Step 1 — Start the emulator** (run once, leave the window open):

```cmd
mkdir D:\Android\tmp
set TEMP=D:\Android\tmp
set TMP=D:\Android\tmp
set ANDROID_SDK_ROOT=D:\Android\sdk
set ANDROID_AVD_HOME=D:\Android\avd
D:\Android\sdk\emulator\emulator.exe -avd Pixel_6_API_36 -no-snapshot-load -no-boot-anim -gpu swiftshader_indirect -no-audio -memory 3072
```

> **Note:** `set TEMP` and `set TMP` redirect emulator temp files to D: drive. Required if C: drive has low free space.

Wait ~2–3 minutes for the emulator to fully boot (Android home screen visible), then:

```powershell
# Confirm the device is ready
D:\Android\sdk\platform-tools\adb.exe devices
# Expected: emulator-5554   device
```

**Step 2 — Run the app:**

```powershell
set PUB_CACHE=D:\pub_cache
set ANDROID_SDK_ROOT=D:\Android\sdk
cd D:\Projects\jordan
D:\flutter\bin\flutter.bat run -d emulator-5554

```

The first build takes ~8–10 minutes (Gradle downloads dependencies). Subsequent builds are much faster.

#### On other platforms

```bash
# Android (device or emulator already running)
flutter run -d android

# iOS (macOS required)
flutter run -d ios
```

### 6. Run tests

```bash
flutter test --coverage
```

### 7. Static analysis

```bash
flutter analyze
```

---

## API / Model Used

**Provider:** [Groq](https://groq.com/) — **free tier available**  
**Model:** `llama-3.1-8b-instant` (configurable via `.env`)

Get a free API key at [console.groq.com](https://console.groq.com) — no billing required.  
Free tier: **30 requests/minute**, 14,400 requests/day.

The app sends a structured prompt asking the model to return JSON with:
- `sentiment` — `positive`, `negative`, or `neutral`
- `confidence` — decimal 0.0–1.0
- `motivation` — a 2–3 sentence motivational message

You can swap the model to `llama3-70b-8192` in `.env` for higher accuracy.

---

## Architecture

The project follows **Clean Architecture** with three distinct layers:

```
lib/
├── core/                  # Shared utilities (errors, theme, constants, usecase base)
├── domain/                # Business logic — pure Dart, no Flutter dependencies
│   ├── entities/          # SentimentAnalysis entity + SentimentType enum
│   ├── repositories/      # Abstract contracts (interfaces)
│   └── usecases/          # AnalyzeSentiment, GetHistory, ClearHistory, Delete, Export
├── data/                  # Concrete implementations
│   ├── models/            # SentimentModel (extends entity, adds serialization)
│   ├── datasources/
│   │   ├── remote/        # Anthropic Claude API via Dio
│   │   └── local/         # SQLite via sqflite
│   └── repositories/      # SentimentRepositoryImpl
└── presentation/
    ├── bloc/              # SentimentBloc, HistoryBloc, ThemeCubit
    ├── pages/             # HomePage, HistoryPage
    └── widgets/           # Reusable UI components
```

### Key decisions

| Decision | Rationale |
|----------|-----------|
| **BLoC** for state management | Predictable, testable, scales beyond simple setState; events/states are explicit contracts |
| **Clean Architecture** | Separates concerns so the domain layer has zero Flutter or third-party dependencies — easily unit-tested |
| **Repository pattern** | All data access goes through an abstract interface; data sources are swappable without touching business logic |
| **Dio** over http | Rich interceptor support, structured error types, and timeout configuration |
| **sqflite** for history | Reliable, performant local persistence; survives app restarts and offline use |
| **GetIt** for DI | Lightweight service locator — avoids constructor-drilling without a code-gen requirement |
| **flutter_dotenv** for secrets | API keys live in `.env`, excluded from Git via `.gitignore` |
| **flutter_animate** | Declarative, chainable animations with minimal boilerplate |

---

## Features

### Core
- [x] Text input with configurable real-time (debounced) or on-demand analysis
- [x] Sentiment result: Positive / Negative / Neutral with confidence score bar
- [x] Motivational message generated by Claude alongside every analysis
- [x] Local history persisted in SQLite — survives app restart
- [x] Swipe-to-delete individual history items
- [x] Full history clear with confirmation dialog
- [x] Loading, error, and empty states for every screen

### Error handling
- [x] No internet — `NoInternetFailure` with user-friendly message
- [x] API timeout — `TimeoutFailure`
- [x] Rate limit (HTTP 429) — `RateLimitFailure`
- [x] Malformed JSON response — `MalformedResponseFailure`
- [x] Invalid API key (HTTP 401) — `InvalidApiKeyFailure`
- [x] Local storage failure — `CacheFailure`

### Bonus features
- [x] Dark / Light / System theme with one-tap toggle
- [x] Arabic / English localization (ARB files, RTL-ready)
- [x] Smooth animations with `flutter_animate`
- [x] CSV export with share sheet
- [x] Pull-to-refresh on history screen
- [x] Detail bottom sheet for full analysis view
- [x] Docker multi-stage build (CI + Android APK stages)

---

## CI/CD Pipeline

GitHub Actions runs on every push and pull request to `main` / `develop`:

| Job | What it does |
|-----|-------------|
| **test** | `flutter analyze` (zero warnings), `flutter test --coverage` |
| **build-android** | `flutter build apk --debug` → uploads artifact |
| **build-ios** | `flutter build ios --no-codesign --debug` (macOS runner) |

Set the `GROQ_API_KEY` repository secret in **Settings → Secrets and variables → Actions**.

---

## Docker

Run analyze + tests inside a container:

```bash
# Build CI stage
docker build --target ci -t sentiment-motivator-ci .
docker run --rm -e ANTHROPIC_API_KEY=your_key sentiment-motivator-ci

# Build Android APK
docker build --target android-build -t sentiment-motivator-android .
docker run --rm -e ANTHROPIC_API_KEY=your_key \
  -v $(pwd)/build:/app/build \
  sentiment-motivator-android \
  flutter build apk --debug
```

---

## Project Structure

```
sentiment_motivator/
├── .env.example                  ← copy to .env, add your key
├── .github/workflows/ci.yml      ← GitHub Actions pipeline
├── Dockerfile                    ← Multi-stage Docker build
├── analysis_options.yaml         ← Lint rules
├── l10n.yaml                     ← Flutter i18n config
├── pubspec.yaml
├── lib/
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── errors/{exceptions,failures}.dart
│   │   ├── network/network_info.dart
│   │   ├── theme/app_theme.dart
│   │   └── usecases/usecase.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/history_local_datasource.dart
│   │   │   └── remote/sentiment_remote_datasource.dart
│   │   ├── models/sentiment_model.dart
│   │   └── repositories/sentiment_repository_impl.dart
│   ├── domain/
│   │   ├── entities/sentiment_analysis.dart
│   │   ├── repositories/sentiment_repository.dart
│   │   └── usecases/{analyze,get_history,clear_history,delete,export}.dart
│   ├── l10n/{app_en,app_ar}.arb
│   ├── presentation/
│   │   ├── bloc/{sentiment,history,theme}/
│   │   ├── pages/{home,history}_page.dart
│   │   └── widgets/
│   ├── injection_container.dart
│   └── main.dart
└── test/
    ├── data/{models,repositories}/
    ├── domain/usecases/
    ├── helpers/{test_helpers,test_data}.dart
    └── presentation/bloc/
```

---

## License

MIT
