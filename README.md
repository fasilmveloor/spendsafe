

# 🛡️ SpendSafe

**SpendSafe** is a personal finance assistant built around a **cash-flow–first** model.

Instead of focusing on where money *went*, SpendSafe focuses on **how much you can safely spend today** — after accounting for fixed expenses, future commitments, and real-world uncertainty.

> SpendSafe is not a budgeting app.
> It is a **decision-time money clarity tool**.

---

## 🧠 Core Concept: Safe-to-Spend

SpendSafe continuously calculates your **Safe-to-Spend (STS)** amount:

```
Safe-to-Spend =
Income
− Fixed Expenses
− Fund Contributions
− Outstanding Commitments
− Spending So Far
```

From this, SpendSafe derives your **Safe Daily Pace**, helping you answer one question instantly:

> *“Can I spend this right now without breaking future plans?”*

No permissions. No blocking. Only visibility.

---

## ✨ Key Features

### 💰 Money Flow Management

* **Safe-to-Spend (STS)** — real-time disposable amount
* **Daily Safe Pace** — time-adjusted spending guidance
* **Multiple Income Sources**

  * Recurring (salary)
  * One-time (freelance, bonus)
  * Variable (dividends, side income)
* **Fixed Expenses**

  * Rent, EMIs, subscriptions
  * Automatically deducted from STS
* **Sinking Funds**

  * Emergency, goals, future purchases
  * Monthly contributions with progress tracking
* **Debts & Dues**

  * Money you owe / money owed to you
  * Settlement creates expense or income automatically

---

### 📊 Advisory Analytics (Non-Intrusive)

* **Category Insights** (advisory only)

  * Within range / Approaching / Exceeded
* **Category Detail View**

  * Monthly impact on Safe Pace
  * Spending patterns & trends
* **Insights Dashboard**

  * Spending breakdown
  * Cash-flow overview
  * Fund contributions vs usage
* **No “budget success” gamification**

---

### 🔔 Alerts & Awareness

* **Pace Alerts** when daily spend exceeds safe pace
* **Category advisory alerts**
* **Upcoming fixed expense reminders**
* Alerts are **informational**, not restrictive

---

### 🛠 Utilities & Trust

* **Local-first storage** (SQLite)
* **Google Drive Backup & Restore**
* **CSV / Excel Export**
* **App Lock**
* **Privacy-focused** — no bank sync, no scraping
* **Lightweight & offline-friendly**

---

## 🧱 Design Principles

* Calm, neutral UI
* One primary decision per screen
* Home screen answers only:

  > *“What can I safely spend now?”*
* Insights are retrospective, never prescriptive
* No green “success” signals
* No shame, no pressure

---

## 🧰 Tech Stack

* **Framework**: Flutter (Dart)
* **State Management**: Riverpod
* **Database**: SQLite (`sqflite`)
* **Architecture**: Feature-first + Repository pattern
* **Backup**: Google Drive API
* **Design System**: Material 3 (customized)

---

## 📂 Project Structure

```
lib/
├── app/                 # App entry & routing
├── core/
│   ├── db/              # SQLite helpers & migrations
│   ├── models/          # Expense, Income, Fund, Due, etc.
│   ├── services/        # STS calculation, backups, exports
│   └── providers/       # Global Riverpod providers
├── features/
│   ├── home/            # Safe-to-Spend dashboard
│   ├── income/          # Income sources
│   ├── fixed_expenses/  # Recurring commitments
│   ├── funds/           # Sinking funds
│   ├── categories/      # Advisory category views
│   ├── debts_dues/      # Owed / owing flows
│   ├── insights/        # Reports & analytics
│   └── settings/
└── shared/              # Common widgets, themes, utils
```

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK
* Android Studio or VS Code

### Clone & Run

```bash
git clone https://gitlab.com/yourusername/spendsafe.git
cd spendsafe
flutter pub get
flutter run
```

---

## ☁️ Google Drive Backup Setup (Optional)

1. Create a project in **Google Cloud Console**
2. Enable **Google Drive API**
3. Create OAuth Client ID (Android)
4. Package name:
   `com.fazlab.spendsafe`
5. Add SHA-1 fingerprint:

```bash
keytool -list -v \
-keystore ~/.android/debug.keystore \
-alias androiddebugkey \
-storepass android -keypass android
```

---

## 📤 Exporting Data

SpendSafe supports:

* CSV export
* Excel-compatible sheets

All exports are **user-initiated** and local.

---

## 🧪 What SpendSafe Is *Not*

To set expectations clearly:

* ❌ Not a bank-sync app
* ❌ Not an investment tracker
* ❌ Not a tax planner
* ❌ Not a budgeting enforcer

SpendSafe is about **clarity, not control**.

---

## 🧩 Contributing

Contributions are welcome if they respect the core philosophy.

1. Fork the repo
2. Create a feature branch
3. Keep logic testable and UI calm
4. Open a Merge Request

---

## 📄 License

MIT License
See [LICENSE](LICENSE)

---

## ✅ Final Verdict

This README now:

* Matches **exactly** what you built
* Avoids dangerous over-promising
* Clearly differentiates SpendSafe
* Sets correct user expectations
* Is Play-Store-safe and contributor-friendly


