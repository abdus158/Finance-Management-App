# FCC - Specialized Agent Roles & Handoff Protocols

To ensure frictionless development and zero context decay when switching agents, this project defines strict roles and permissions for any active LLM agent.

---

## 🤖 1. Specialized Agent Roles

### Role A: Architect Agent
* **Domain**: High-level system structure, tech stack integration, and system boundaries.
* **Input Files**: `brain/vision.md`, `brain/requirements.md`
* **Output Files**: Updates `brain/architecture.md`, specifies database structural plans in `brain/db_schema.sql`.

### Role B: Backend Agent
* **Domain**: SQLite operations, transactional integrity, local business formulas (burn rate, trust score), sync engine, and state machine transitions.
* **Input Files**: `brain/db_schema.sql`, `brain/architecture.md`, `lib/core/database/*`
* **Output Files**: Write backend code, implements database adapters, manages tests under `test/*`.

### Role C: UI/UX Agent
* **Domain**: Flutter views, glassmorphic themes, animations (Frame Motion style), layout grids, and interactive charting using Graphify ECharts configurations.
* **Input Files**: `brain/vision.md`, `lib/core/theme/*`, `lib/features/*`
* **Output Files**: Visual widgets, screen layouts, chart configurations, and transition controller files.

### Role D: Memory Agent (The Handoff Controller)
* **Domain**: Enforcing handoff constraints and updating working files to preserve state.
* **Input Files**: Current codebase changes, Git commit logs.
* **Output Files**: Updates `brain/tasks.json` and logs critical architectural revisions under `brain/decisions_log.md`.

---

## 🔄 2. Strict Handoff Protocol

When you switch agents (e.g., from Antigravity to Codex or Claude Code):

1. **The Handoff Prompt**: Give the new agent the following strict markdown directive as their first message:
   ```markdown
   SYSTEM INSTRUCTION:
   You are entering a structured, multi-agent project environment. Before executing any code changes or answering design questions, you MUST:
   1. Read the Project Memory:
      - /brain/vision.md
      - /brain/requirements.md
      - /brain/architecture.md
      - /brain/decisions_log.md
      - /brain/tasks.json
   2. Understand your role using:
      - /agents/agent_roles.md
   3. Identify the current active task:
      - Look at tasks.json where "status" is "in-progress" or identify the next "pending" task in order.
   4. Constraints:
      - Strictly follow architecture.md.
      - Log any major system decision (like modifying SQLite schemas or using new plugins) into /brain/decisions_log.md upon task completion.
   ```
2. **AST Code Graph Rebuild**:
   * The new agent can query the Graphify indexing at any time to traverse dependencies.
   * After writing code, the agent must run `python -m graphify update .` to keep the AST map current.
