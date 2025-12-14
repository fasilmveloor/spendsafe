

# 📘 SpendSafe — Requirement Specification (v1)

> **App name:** SpendSafe
> **Positioning:** Personal finance assistant for safe spending & planning
> **Platform:** Android (Flutter)
> **Storage:** Local-first (SQLite)
> **Exports:** CSV / Excel
> **Backups:** Google Drive (manual + auto)

---

## 1. Core Principles (Non-negotiable)

1. **Cash-flow first**
2. **Budgets warn, never permit**
3. **Funds reserve money (not virtual)**
4. **No bank sync required**
5. **Local-first, user owns data**
6. **UI reflects consequences, not judgment**

---

## 2. Core Modules (Locked)

1. Home (Safe-to-spend control)
2. Expenses
3. Categories (Advisory)
4. Funds (Sinking funds)
5. Income & Accounts
6. Fixed Expenses
7. Debts & Dues
8. Insights / Reports
9. Alerts
10. Profile & Settings
11. Data Export & Backup

---

## 3. Money Model (Authoritative)

### 3.1 Buckets

```
Income
− Fixed Expenses
− Fund Contributions
= Free To Spend (FTS)
```

FTS is the **only authority** for spending safety.

---

## 4. Database Schema (SQLite)

### 4.1 Users

```sql
users (
  id TEXT PRIMARY KEY,
  name TEXT,
  email TEXT,
  avatar_uri TEXT,
  currency TEXT,
  created_at INTEGER
)
```

---

### 4.2 Accounts (Where money lives)

```sql
accounts (
  id TEXT PRIMARY KEY,
  name TEXT,
  type TEXT, -- bank | cash | wallet | card | other
  balance REAL DEFAULT 0,
  include_in_fts INTEGER DEFAULT 1,
  created_at INTEGER
)
```

> Accounts are **informational**, not bank-synced.

---

### 4.3 Income Sources

```sql
income_sources (
  id TEXT PRIMARY KEY,
  name TEXT,
  account_id TEXT,
  is_active INTEGER,
  created_at INTEGER
)
```

---

### 4.4 Income Records

```sql
income (
  id TEXT PRIMARY KEY,
  source_id TEXT,
  account_id TEXT,
  amount REAL,
  received_date INTEGER,
  note TEXT
)
```

✔ Supports **multiple variable incomes per month**

---

### 4.5 Categories (Advisory)

```sql
categories (
  id TEXT PRIMARY KEY,
  name TEXT,
  monthly_budget REAL,
  warning_threshold REAL DEFAULT 0.8,
  created_at INTEGER
)
```

---

### 4.6 Expenses

```sql
expenses (
  id TEXT PRIMARY KEY,
  amount REAL,
  category_id TEXT,
  account_id TEXT,
  fund_id TEXT NULL,
  expense_date INTEGER,
  note TEXT,
  is_auto_detected INTEGER,
  created_at INTEGER
)
```

✔ Category **mandatory**
✔ Fund optional
✔ Account required

---

### 4.7 Funds (Sinking Funds)

```sql
funds (
  id TEXT PRIMARY KEY,
  name TEXT,
  label TEXT, -- emergency | goal | buffer | other
  storage_type TEXT, -- cash | fd | mf | gold | other
  target_amount REAL,
  target_date INTEGER,
  created_at INTEGER,
  is_active INTEGER
)
```

---

### 4.8 Fund Contributions

```sql
fund_contributions (
  id TEXT PRIMARY KEY,
  fund_id TEXT,
  amount REAL,
  month INTEGER, -- YYYYMM
  created_at INTEGER
)
```

✔ Deducted **before FTS**

---

### 4.9 Fixed Expenses

```sql
fixed_expenses (
  id TEXT PRIMARY KEY,
  name TEXT,
  amount REAL,
  account_id TEXT,
  due_day INTEGER,
  is_active INTEGER,
  created_at INTEGER
)
```

---

### 4.10 Debts & Dues

```sql
dues (
  id TEXT PRIMARY KEY,
  person_name TEXT,
  amount REAL,
  type TEXT, -- owed_to_me | i_owe
  status TEXT, -- open | settled
  account_id TEXT,
  created_at INTEGER
)
```

---

### 4.11 Alerts

```sql
alerts (
  id TEXT PRIMARY KEY,
  type TEXT, -- pace | budget | fund | due | system
  message TEXT,
  severity TEXT, -- info | warning | danger
  created_at INTEGER,
  is_read INTEGER
)
```

---

## 5. Core Calculations (Locked)

### Free To Spend (FTS)

```
FTS =
Total Income Received
− Fixed Expenses
− Fund Contributions (current month)
− Expenses
```

### Safe Daily Pace

```
Safe Pace = FTS / remaining_days
```

---

## 6. User Stories (Condensed but Complete)

### Home

* As a user, I want to see how much I can safely spend now
* As a user, I want to see today’s pace impact instantly

### Expenses

* As a user, I must select a category for every expense
* As a user, I want to optionally pay from a fund
* As a user, I want to choose which account I paid from

### Categories

* As a user, I want category budgets to warn me, not block me
* As a user, I want to see category trends over time

### Funds

* As a user, I want to create funds for future goals
* As a user, I want to reserve money monthly
* As a user, I want to mark an expense as paid from a fund
* As a user, I want to see contribution vs usage analytics

### Income

* As a user, I want multiple income sources
* As a user, I want income to be variable month to month
* As a user, I want income credited to an account

### Fixed Expenses

* As a user, I want fixed expenses deducted automatically
* As a user, I want to edit or disable them anytime

### Debts & Dues

* As a user, I want to track money I owe or am owed
* As a user, I want settlement to affect accounts

### Insights

* As a user, I want charts only in reports
* As a user, I want to understand patterns, not permissions

### Data

* As a user, I want CSV & Excel export
* As a user, I want Google Drive backup
* As a user, I want full data ownership

---

## 7. Export Requirements

### CSV / Excel

* Expenses
* Income
* Funds
* Fixed Expenses
* Dues

Each export:

* ISO dates
* Clear headers
* One entity per sheet/file

---

## 8. Non-Goals (Explicit)

SpendSafe will **NOT**:

* Sync with banks
* Predict investments
* Manage taxes
* Gamify finances

---

## 9. MVP Completion Definition

SpendSafe v1 is complete when:

* All screens map to real data
* FTS is always correct
* Export works
* No screen contradicts philosophy

---

## 10. Next Step (As You Requested)

### ✅ This chat delivered:

* Full **requirement specification**
* **SQLite schema**
* **User stories**
* **System guarantees**

