# FCC - Engineering Decisions Log

This document records the architectural and technology selection choices made during the FCC development, including their context, rationale, and impact.

---

### DEC-001: Mobile Application built on Flutter
* **Date**: 2026-05-17
* **Status**: Approved
* **Context**: The user currently tracks complex financial items (cash flow, personal accounts, and corporate business like Emerge Nexus) using pen and paper and requested a mobile interface.
* **Decision**: Target a native mobile application using **Flutter (Dart)** instead of a Progressive Web App (PWA).
* **Rationale**: Offers native cross-platform performance (Android/iOS), beautiful pixel-level graphic control, smooth high-performance custom transitions, and completely sandboxed offline file storage.
* **Impact**: The codebase is configured as a Flutter mobile-first architecture.

---

### DEC-002: Offline-First Local Database via `sqflite`
* **Date**: 2026-05-17
* **Status**: Approved
* **Context**: User needs absolute offline access to replace their notebook tracker. Cloud features are secondary (syncing later).
* **Decision**: Implement a local relational schema via **SQLite (`sqflite` plugin)**.
* **Rationale**: Strong transactional support (`db.transaction()`) is essential for maintaining double-entry ledger transfers and loan installments without introducing structural data corruption.
* **Impact**: The app executes 100% locally and stores data in a sandboxed `fcc_database.db` SQL file.

---

### DEC-003: Central State Management via `provider`
* **Date**: 2026-05-17
* **Status**: Approved
* **Context**: State updates (such as recording an installment or making an internal wallet transfer) must propagate instantly across multiple tabs (Dashboard net worth updates, Ledger entries, Wallet list, and Loan balances).
* **Decision**: Utilize Flutter's **`provider`** state management package.
* **Rationale**: Exposes reactive ViewModels via `ChangeNotifierProvider` and supports clean updates across all screens with minimal boilerplate.
* **Impact**: Central state is managed in `FCCProvider`.

---

### DEC-004: Interactive Visualization via `graphify` (ECharts)
* **Date**: 2026-05-17
* **Status**: Approved
* **Context**: Financial trends need highly customizable, sleek, neon-style lines and touch-interactive tooltips to convey a premium cyber-theme.
* **Decision**: Integrate the **`graphify`** package.
* **Rationale**: Serves as a direct bridge to **Apache ECharts** which allows declarative, incredibly rich chart configurations (lines, bars, WebGL, networks) loaded easily from simple JSON configurations.
* **Impact**: The dashboard displays a stunning interactive multi-series chart comparing Weekly Income and Expenses.
