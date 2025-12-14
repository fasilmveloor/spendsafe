# 🛡️ SpendSafe

**SpendSafe** is a personal finance assistant designed with a **"Cash-Flow First"** philosophy. Unlike traditional expense trackers that focus on categorizing where money *went*, SpendSafe focuses on telling you **how much you can safely spend today** without jeopardizing your upcoming bills or savings goals.

---

## 🌟 Key Philosophy: Safe Pace

The core calculation of SpendSafe is the **Safe Daily Spending Pace**.
It takes your **Current Balance**, subtracts all **Pending Fixed Expenses** (Rent, Bills) and **Fund Contributions** (Savings), and divides the remaining "Flow-to-Spend" (FTS) by the days left in the month.

> **"If you spend less than your Safe Pace today, you are winning."**

---

## 🚀 Features

### 💰 Financial Management
-   **Flow-to-Spend (FTS)**: Live calculation of truly disposable income.
-   **Safe Pace Indicator**: Visual gauge showing your daily spending limit.
-   **Income & Accounts**: Manage multiple sources and accounts (Bank, Cash, Wallet).
-   **Fixed Expenses**: Track recurring bills with due dates.
-   **Sinking Funds**: Set aside money for goals (e.g., Vacation, Emergency Fund).
-   **Debts & Dues**: Track money owed to you or by you.

### 📊 Analytics & Insights
-   **Category Budgets**: Soft limits with visual warnings (Yellow/Red) when approaching thresholds.
-   **Insights Dashboard**: Pie charts and breakdown of spending habits.
-   **Search**: Find transactions by note or amount instantly.

### 🛠️ Utilities
-   **Backup & Restore**: Full Google Drive integration for secure cloud backups.
-   **Dark/Light Mode**: Beautiful Material 3 design with theme switching.
-   **Privacy Focused**: All data is stored locally on your device (SQLite).
-   **Export**: Export your data to CSV/Excel for external analysis.

---

## 🛠️ Tech Stack

-   **Framework**: [Flutter](https://flutter.dev) (Dart)
-   **State Management**: [Riverpod](https://riverpod.dev)
-   **Database**: [sqflite](https://pub.dev/packages/sqflite) (SQLite)
-   **Cloud Integration**: [googleapis](https://pub.dev/packages/googleapis) (Google Drive API)
-   **Architecture**: Feature-based folder structure with Repository pattern.

---

## 🏁 Getting Started

### Prerequisites
-   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
-   Android Studio or VS Code configured.

### 1. Clone the Repository
```bash
git clone https://gitlab.com/yourusername/spendsafe.git
cd spendsafe
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Google Drive Configuration (Crucial!)
To enable Cloud Backup, you must configure the Google Cloud Console:

1.  Go to [Google Cloud Console](https://console.cloud.google.com/).
2.  Create a project and enable the **Google Drive API**.
3.  Create an **OAuth 2.0 Client ID** for **Android**.
4.  Use the package name: `com.fazlab.spendsafe`
5.  Add your SHA-1 Fingerprint. You can get your debug fingerprint via:
    ```bash
    keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
    ```
6.  (Optional) Add your email to "Test Users" in the OAuth Consent Screen.

### 4. Run the App
```bash
flutter run
```

---

## 📦 Building for Release

To build an optimized APK for Android:

1.  Update `key.properties` (secured/ignored) with your release keystore details.
2.  Run the build command:
```bash
flutter build apk --release
```
The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📂 Project Structure

```
lib/
├── app/                 # App entry point and routing
├── core/                # Core services, DB, models, providers
│   ├── db/              # SQLite database helper
│   ├── models/          # Data models (Expense, Income, etc.)
│   └── services/        # Logic services (FTS, Google Drive)
├── features/            # Feature modules (UI + Logic)
│   ├── home/            # Dashboard & Wages
│   ├── transactions/    # Expense logging & Search
│   ├── funds/           # Sinking funds logic
│   └── ...
└── shared/              # Shared widgets, themes, utils
```

---

## 🤝 Contributing

1.  Fork the repository.
2.  Create a feature branch (`git checkout -b feature/amazing-feature`).
3.  Commit your changes (`git commit -m 'Add amazing feature'`).
4.  Push to the branch (`git push origin feature/amazing-feature`).
5.  Open a Merge Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
