# Financial Command Center (FCC) - System Requirements

This document formalizes the functional and non-functional requirements of the FCC application.

---

## 🧩 1. Functional Requirements

### Module 1: Smart Ledger
* **REQ-1.1**: The system must log transactions containing: Amount, Wallet ID, Type (INCOME / EXPENSE), Category ID, Notes, Date, Priority (LOW, MEDIUM, HIGH), and Tags.
* **REQ-1.2**: Transactions must support multiple categories (Food, Bills, Freelancer, Ads, Client Payment, etc.) linked to either PERSONAL, BUSINESS, or BOTH contexts.
* **REQ-1.3**: The user must be able to filter transactions by type and search by notes/description.

### Module 2: Multi-Wallet System
* **REQ-2.1**: The system must maintain multiple cash, bank, or digital wallet containers (e.g., Cash Wallet, HBL Bank, Easypaisa, Emerge Nexus).
* **REQ-2.2**: The system must support single-action **Internal Transfers**. This must execute a double-entry transaction (Expense in Source wallet, Income in Destination wallet) and balance both wallets accurately.

### Module 3: Loan & Liability Engine (Receivables & Payables)
* **REQ-3.1**: The system must track loans classified into payables (who I owe) and receivables (who owes me).
* **REQ-3.2**: Active loans must track the Principal Amount, Remaining Amount, Due Date, and Status (ACTIVE, PAID, DEFAULTED).
* **REQ-3.3**: Users must be able to pay installments against outstanding loans. An installment must decrease the loan's `remainingAmount` and record a corresponding ledger transaction.
* **REQ-3.4**: The system must calculate a dynamic **Trust Score** (0-100%) for contacts with receivables. Scores must deduct points for passing due dates unpaid and apply progressive penalties for additional days of delay.

### Module 4: Cash Flow & Forecasting
* **REQ-4.1**: The system must calculate an average daily burn rate using expenses from the last 7 days.
* **REQ-4.2**: The system must forecast remaining cash stability (in days) by dividing the total net worth by the daily burn rate.
* **REQ-4.3**: The system must trigger a **Critical Alarm** (visual warnings and indicators) if the remaining cash forecast is equal to or less than 6 days.

### Module 5: Interactive Visualizations
* **REQ-5.1**: The system must display interactive multi-series charts comparing Income vs Expenses over a 7-day period.
* **REQ-5.2**: Charts must be rendered using `graphify` (Apache ECharts bridge) for responsive touch tooltips and smooth transitions.

---

## ⚡ 2. Non-Functional Requirements

* **NREQ-2.1 (Offline-First)**: The app must operate 100% locally. All data must be saved to a local SQLite database (`sqflite`).
* **NREQ-2.2 (Performance)**: App launch, dashboard load, and database updates must take less than 1.5 seconds.
* **NREQ-2.3 (Premium UI/UX)**: The interface must feature a dark theme (deep blue/black), neon cyber accents, glassmorphism card overlays, and fluid micro-animations (Framer Motion equivalent).
* **NREQ-2.4 (Security)**: The local SQLite database file must remain securely sandboxed inside the mobile application storage.
