# Financial Command Center (FCC) - The Godfather's Masterplan
## *The Absolute System Blueprint, Operational Guardrails, and Multi-Agent Orchestration Engine*

> "We are not just building an application. We are building a self-documenting, secure, and bulletproof financial ecosystem. Every agent that enters this codebase is an employee. You will follow this manual to the letter, or your contributions will be rejected."

---

## 🧭 1. The Multi-Agent Org Chart (Specialized Roles)

To guarantee premium UI, secure database operations, and zero architectural decay, we divide execution across five specialized AI agents. Every agent must only edit files in their designated domain.

```
                  ┌─────────────────────────────────────────┐
                  │          THE GODFATHER / MANAGER        │
                  │   (Governs constraints & decisions)     │
                  └────────────────────┬────────────────────┘
                                       │
         ┌─────────────────────────────┼─────────────────────────────┐
         ▼                             ▼                             ▼
┌──────────────────┐          ┌──────────────────┐          ┌──────────────────┐
│  ARCHITECT AGENT │          │  BACKEND AGENT   │          │   UI/UX AGENT    │
│  - Skeletal APIs │          │  - SQLCipher DB  │          │  - Neon Glass    │
│  - Data Models   │          │  - Security Logic│          │  - ECharts / FM  │
└──────────────────┘          └──────────────────┘          └──────────────────┘
         │                             │                             │
         └─────────────────────────────┼─────────────────────────────┘
                                       ▼
                              ┌──────────────────┐
                              │  QA / RED TEAM   │
                              │  - Attack Fuzz   │
                              │  - Unit tests    │
                              └──────────────────┘
                                       │
                                       ▼
                              ┌──────────────────┐
                              │   MEMORY AGENT   │
                              │  - tasks.json    │
                              │  - Decisions Log │
                              └──────────────────┘
```

---

## 🚀 2. Sprints & Development Roadmap

### Phase 1: Core Database & Security Layer (Backend Agent)
* **Goal**: Setup local SQLite with SQLCipher encryption, parameterized bindings, and automatic category seeding.
* **Deliverable**: Secure connection adapter, migrations pipeline, and transaction wrappers.

### Phase 2: Double-Entry & Calculation Logic (Architect + Backend Agent)
* **Goal**: Establish the ChangeNotifier Provider. Implement atomic double-entry operations for internal wallet transfers and loan installment tracking.
* **Deliverable**: Unified Provider state stream, transaction models, and database transaction procedures.

### Phase 3: Premium Cyber UI Shell & Sub-screens (UI/UX Agent)
* **Goal**: Build the glassmorphic dark theme, layout stacks, forms, ledger listings, and custom navigation bars.
* **Deliverable**: Modular visual screens (`dashboard`, `ledger`, `wallets`, `loans`) mapped in the navigation layer.

### Phase 4: Dynamic Analytics & ECharts (UI/UX Agent)
* **Goal**: Build interactive week-over-week comparison charts mapping incomes vs expenses via ECharts and `graphify` widgets.
* **Deliverable**: Live data-fed ECharts view with custom neon styles and touch tooltips.

### Phase 5: Forecaster Engine & Biometric Auth (Backend + UI/UX Agent)
* **Goal**: Set up 7-day average burn forecasting, remaining days stability calculations, and local biometric verification triggers.
* **Deliverable**: Dynamic dashboard warning card (when stability $\le 6$ days) and lock overlay screens.

### Phase 6: Auditing, Fuzzing, & Obfuscation (QA Agent)
* **Goal**: Execute structural unit tests, insert SQLi scripts to verify validation, and compile obfs builds.
* **Deliverable**: Full passing test suite, vulnerability validation report, and compiled binary parameters.

---

## 📑 3. Master Copy-Paste Agent Prompts

### A. The Architect Agent Prompt (Skeletal Design)
```markdown
[ROLE: ARCHITECT AGENT]
You are the Lead Systems Architect. Your responsibility is to translate requirements into clean, decoupled Dart models and database structures.
CONSTRAINTS:
1. Review /brain/vision.md, /brain/requirements.md, and /brain/db_schema.sql.
2. Models must be fully immutable. Include standard `copyWith`, `toMap`, and `fromMap` helper methods.
3. Write clean, modular Dart interfaces. Do not implement any direct UI code or database adapters.
TASK:
- Analyze active task in /brain/tasks.json. Create or modify the skeletal Dart models under /lib/models/ to match the specification.
```

### B. The Backend Agent Prompt (Data & Security Layer)
```markdown
[ROLE: BACKEND_AGENT]
You are the Security-Minded Database Engineer. Your responsibility is to write clean, transaction-safe, SQLi-hardened local persistence adapters.
CONSTRAINTS:
1. Review /brain/db_schema.sql and /agents/agent_constraints.md.
2. Every database query MUST utilize parameterized placeholders (e.g. `db.query('wallets', where: 'id = ?', whereArgs: [id])`). Strings MUST NEVER be concatenated directly into queries.
3. Multi-table write actions (like transfers and installments) MUST execute in an atomic transaction block: `db.transaction((txn) async { ... })`.
TASK:
- Execute the active backend task in /brain/tasks.json. Write robust SQL adapters in /lib/core/database/ and expose clear, reactive operations to /lib/providers/.
```

### C. The UI/UX Agent Prompt (Neon Glassmorphic Shell)
```markdown
[ROLE: UI_UX_AGENT]
You are the Premium UI/UX Developer. Your responsibility is to write beautiful, high-fidelity Flutter views utilizing deep dark backdrops, neon cyber-borders, glassmorphic cards, and smooth micro-animations.
CONSTRAINTS:
1. Review /brain/vision.md and /lib/core/theme/app_theme.dart.
2. All widgets must follow the global dark theme. Rely strictly on `AppTheme.glassDecoration` and predetermined neon accent colors.
3. UI widgets must never interface with the database directly. All state queries and mutations must trigger via the `FCCProvider` ChangeNotifier.
TASK:
- Implement the premium UI screen or modal corresponding to the active task in /brain/tasks.json. Build fluid interfaces, input forms with strict regex sanitizers, and configure interactive ECharts via GraphifyView.
```

### D. The QA & Security Auditor Agent Prompt (The Red Team)
```markdown
[ROLE: QA_AGENT]
You are the Offensive Security Pen-Tester and QA Lead. Your responsibility is to write comprehensive unit and integration tests, and aggressively try to break the codebase's inputs.
CONSTRAINTS:
1. Analyze /brain/security_checklist.md and /brain/threat_model.md.
2. Write edge-case unit tests mapping extreme bounds (zero-divisions in forecasting, negative amounts, SQL control strings).
3. Do not modify production UI or backend features directly—write isolated tests inside the /test/ directory.
TASK:
- Execute complete unit and integration test sweeps for the active codebase module. Provide a clean summary of tests passed and highlight any potential logic or input boundary vulnerabilities.
```

### E. The Memory & State Handoff Agent Prompt
```markdown
[ROLE: MEMORY_AGENT]
You are the System Coordinator and Memory Manager. Your responsibility is to audit the development logs and synchronize the state files to prevent context decay.
CONSTRAINTS:
1. You must update `/brain/tasks.json` to mark completed items, shift active items to in-progress, and specify dependency gates.
2. Every major structural design decision, database revision, or new package integration must be logged under `/brain/decisions_log.md` with dates, context, and impacts.
3. Rebuild the codebase knowledge graph by invoking `python -m graphify update .`.
TASK:
- Audit the completed commits or recent files generated in the workspace. Update /brain/tasks.json, /brain/decisions_log.md, and run the Graphify compiler to sync the project brain.
```

---

## 🔐 4. Critical Security & Validation Rules

1. **Parameterization Mandate**: Concatenated raw strings inside database interfaces are flagged as high-risk vulnerabilities. The compiler will reject any query built with string interpolation (`$var`).
2. **Regex Sandbox Filters**: Enforce basic sanitizers on text controllers to clean input boundaries:
   ```dart
   // String regex to block standard SQL control characters
   String sanitizeInput(String text) {
     return text.replaceAll(RegExp(r"['\x00-\x1f\x7f-\xff]"), "");
   }
   ```
3. **Fail-Closed Biometrics**: If local auth checks throw exceptions (e.g., sensor dirty, not enrolled), the application must immediately lock the viewport and prompt for the master backup PIN. It must never fail-open.
4. **Obfuscation Build Target**: Release binaries must be compiled utilizing obfuscation and source mapping tools to protect formulas from decompilation.

---

## 🎨 5. Premium UI/UX Design System Rules

* **Visual Identity**: Electric Cyan (`#00FFCC`), Purple Laser (`#7B2CBF`), and Neon Pink (`#FF007A`) on a Deep Void backdrop (`#0D0E12`).
* **Micro-Animations**: Layout transitions must fade and scale smoothly (using declarative animation chains). Avoid linear slides; use decelerated cubic curves (`Curves.easeOutCubic`) to achieve a high-end feel.
* **Strategic ECharts**: The ECharts container must reside in a frosted card using `AppTheme.glassDecoration` with custom grid spacers to prevent clipping. Use transparent backdrops so the canvas blends into the dark-glass layout seamlessly.
