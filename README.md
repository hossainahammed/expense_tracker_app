# 🪙 Expense Tracker App

A visually stunning, premium, and fully responsive personal finance application built with Flutter. Keep track of your spending habits, set customized budget goals, analyze category distributions with interactive charts, and enjoy a cohesive day/dark theme configuration.

---

## ✨ Features

* **🎨 Premium Aesthetic & Material 3**: Beautifully designed UI focusing on micro-animations, glassmorphic card stylings, and harmonious color schemes:
  * **Light Mode**: Warm cream/off-white background (`#F8FAFC`) with Indigo branding accents.
  * **Dark Mode**: High-contrast midnight-navy background (`#0F172A`) with deep slate-charcoal cards and neon-indigo highlighting.
* **📊 Visual Budget Dashboard**:
  * Displays Available Balance, Total Spent, and Total Budget Limit.
  * Dynamic, color-coded progress indicators (Teal for safe margins, Orange/Amber for >70% warnings, Red/Warning elements for >90% or over-budget).
* **📈 Interactive Donut Charts**: Slim, professional category distribution views powered by `fl_chart`, featuring a scrollable indicator legend displaying category values.
* **🏷️ Compact Head-Level Filters**:
  * Category Filter and Sorting Options sit side-by-side in a single row positioned at the very top of the dashboard.
  * Replaces large UI layouts with compact dropdown selectors to preserve screen space.
* **📝 Intuitive Bottom Sheets**: Modals with top handle indicators, floating inputs, stateful inline calendar pickers, and a visual touch-selection category grid.
* **💾 State Persistence**: Automatically persists transactions, selected currencies, custom budget limits, and dark theme choices locally using `shared_preferences`.
* **📱 Robust Scroll Architecture**: Uses a unified `CustomScrollView` with slivers to ensure smooth scrolling and eliminate layout overflows, even when the software keyboard is open.
* **🚀 Automated CI/CD**: Seamless verification of code quality, widget test passes, and compilation builds via GitHub Actions.

---

## 🛠️ Getting Started

### Prerequisites
* Flutter SDK (Channel `stable`, version `3.22.x` or higher recommended)
* Android Studio / Xcode (for mobile emulators)
* Java JDK 17 (required for Android builds)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/hossainahammed/expense_tracker_app.git
   cd expense_tracker_app
   ```
2. Retrieve dependencies:
   ```bash
   flutter pub get
   ```
3. Generate native Android and iOS launcher icons:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Running the App
Start a emulator or connect a physical device, then run:
```bash
flutter run
```

### Running Local Quality Checks
Before committing code, make sure it passes all linting and test rules:
```bash
flutter analyze
flutter test
```

---

## 🤖 Continuous Integration (CI/CD)

This project has a pre-configured GitHub Actions workflow located at `.github/workflows/flutter_ci.yml`. Whenever code is pushed or a pull request is submitted, it automatically executes the following jobs:
1. **Environment Setup**: Provisions Ubuntu virtual machines, setups JDK 17, and initializes the Flutter environment.
2. **Lint Checks**: Analyzes the codebase via `flutter analyze`.
3. **Widget & Unit Testing**: Verifies application logic via `flutter test`.
4. **Build Verification**: Builds the debug Android APK via `flutter build apk --debug` to guarantee compilation.

---

## 📁 Project Structure

```
expense_tracker_app/
├── .github/workflows/     # CI/CD pipelines (GitHub Actions)
├── android/               # Android native hosting & gradle settings
├── assets/                # Design assets (launcher icon)
├── ios/                   # iOS native project structure
├── lib/
│   ├── widget/
│   │   └── expense_pie_chart.dart  # Donut chart & legend layout
│   ├── expense_modal.dart        # Expense data model & JSON serializers
│   ├── expense_tracker.dart       # Main Dashboard UI & modal sheet forms
│   └── main.dart                 # App initialization, themes, & router
├── test/
│   └── widget_test.dart          # Widget smoke test (with mocked SharedPreferences)
└── pubspec.yaml           # Dependencies, assets, and flutter settings
```