# Financial Command Center (FCC) - System Architecture

This document describes the structural design, data flow, and layers of the FCC application.

---

## 🏗️ 1. Architectural Layers

The application follows a modular, feature-based **Model-View-ViewModel (MVVM)** pattern, leveraging standard Flutter architecture.

```
┌─────────────────────────────────────────────────────────┐
│                       VIEW LAYER                        │
│   (dashboard_screen.dart, ledger_screen.dart, etc.)     │
└────────────────────────────┬────────────────────────────┘
                             │ Observes State & Triggers
                             ▼
┌─────────────────────────────────────────────────────────┐
│                    VIEWMODEL / STATE                    │
│                  (fcc_provider.dart)                    │
└────────────────────────────┬────────────────────────────┘
                             │ Fetches / Dispatches
                             ▼
┌─────────────────────────────────────────────────────────┐
│                    PERSISTENCE LAYER                    │
│            (db_helper.dart - SQLite sqflite)            │
└────────────────────────────┬────────────────────────────┘
                             │ Local Sandbox Storage
                             ▼
┌─────────────────────────────────────────────────────────┐
│                      DATABASE (DB)                      │
│                  (fcc_database.db)                      │
└─────────────────────────────────────────────────────────┘
```

### 1. View Layer (`/lib/features`)
Contains the UI widgets, layouts, and modals.
* Displays state reactively.
* Directly uses custom glassmorphism styles and interactive ECharts through the `graphify` package.
* Tab-based shell (`main_navigation.dart`) coordinates screens.

### 2. ViewModel / Provider Layer (`/lib/providers`)
Acts as the central state engine (`fcc_provider.dart`).
* Exposes lists (`wallets`, `transactions`, `loans`, `categories`) and metrics (`trustScores`, `cashForecast`).
* Automatically triggers asynchronous DB re-fetch operations and calls `notifyListeners()` on write actions.

### 3. Model Layer (`/lib/models`)
Defines immutable data objects mapping database rows to Dart types:
* `Wallet`: Tracks money containers.
* `TransactionModel`: Ledger entries, tagged with priorities.
* `Loan` & `LoanInstallment`: Payables, receivables, and repayment records.

### 4. Persistence Layer (`/lib/core/database`)
Encapsulates all local interactions using `sqflite`.
* Coordinates schemas creation, migrations, and seeds defaults.
* Contains advanced SQL queries (e.g., aggregating weekly expenses, forecasting daily burn rates).

---

## 🔄 2. Core Data Flow & Transactions

### A. Internal Fund Transfers (Double Entry)
To ensure absolute accounting integrity when moving money between wallets, the system enforces a strict transactional boundary:
1. One **Expense** transaction is recorded for the source wallet.
2. One **Income** transaction is recorded for the destination wallet.
3. Both transactions are written to the database in a single `db.transaction()` block.
4. Source wallet balance is decremented and destination wallet balance is incremented within the same database transaction.
5. If any write or balance adjustment fails, the entire transaction is rolled back.

### B. Loan Installments
1. Remaining loan balance is calculated: `remainingAmount - installmentAmount`.
2. An installment record is written to `loan_installments`.
3. A ledger transaction is registered (reducing bank/cash balance for payables, or increasing it for receivables).
4. Wallet balance is adjusted.
5. All operations run inside an atomic database transaction.

---

## 📊 3. Graphify & ECharts Integration
* Data visualization is managed by passing ECharts configuration strings as JSON into the `GraphifyView` widget.
* The chart automatically parses coordinates, sets line styling (glows, electric cyan, and neon pink gradients), and handles high-end interactive tooltips smoothly inside a custom webview container.
