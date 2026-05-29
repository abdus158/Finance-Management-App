# FCC - AI Agent Constraints & Guardrails

To prevent AI agents (Antigravity, Claude Code, Codex, Cursor) from introducing architectural decay, spaghetti code, or security vulnerabilities, all agents must strictly adhere to the following rules.

---

## 🚫 1. Absolute Prohibitions (Immediate Rejection)

* **NO Direct UI to DB Queries**: Code under `lib/features/*` (Views) MUST NEVER import `db_helper.dart` or invoke raw database commands. All data access must pass through `FCCProvider` (ViewModel) or a dedicated service layer.
* **NO Raw SQL Concatenation**: When writing database operations in `db_helper.dart` or related files, agents MUST NEVER use string interpolation to inject user-provided text directly into SQL statements (e.g., `db.rawQuery("SELECT * FROM transactions WHERE notes = '$notes'")`). Parameters must **always** be bound via parameterized arguments `?` to prevent SQL Injection.
* **NO Unapproved Schema Modifications**: Agents are strictly forbidden from executing `ALTER TABLE` or adding new tables to `db_helper.dart` without first updating [db_schema.sql](file:///c:/New%20Drive%20Data/Project%20Tester%20-%20Cost%20Manager%20&%20Expenser/brain/db_schema.sql) and logging the revision in [decisions_log.md](file:///c:/New%20Drive%20Data/Project%20Tester%20-%20Cost%20Manager%20&%20Expenser/brain/decisions_log.md).

---

## 🏗️ 2. Structural Separation (MVVM Compliance)

When modifying or adding new features:
1. **Views (`lib/features/...`)**:
   * Keep widgets entirely focused on layout, style (glassmorphism theme), user input validation, and rendering state.
   * State and mutations must be requested from the provider: `Provider.of<FCCProvider>(context, listen: false).someAction(...)`.
2. **Provider (`lib/providers/...`)**:
   * Responsible for loading data asynchronously from SQLite, holding the active data lists in-memory, calculating view-specific statistics, and calling `notifyListeners()`.
3. **Core Database Helper (`lib/core/database/...`)**:
   * Encapsulates all raw queries, index modifications, seeds, and local SQLite data transactions.

---

## 🔐 3. Security & Validation Rules

* **Input Sanitization**: Ensure all text controllers check for empty entries, invalid double parses, or malicious characters. Text fields must enforce length caps (e.g., maximum 200 characters for notes) to prevent buffer or memory overflow issues in SQLite views.
* **Sensitive Data Sandbox**: Never write secrets (API keys, encryption passwords) as plain strings in code. If writing integrations, utilize environmental variables or mock configurations.
* **Failure Boundaries**: Database modifications inside the DB helper must wrap dynamic multi-table updates (such as transfers or installments) inside `db.transaction()` blocks. If any step fails, the operation must immediately throw and rollback all changes to ensure data consistency.
