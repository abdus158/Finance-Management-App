# Agent Rules (STRICT)

## 1. Architecture Boundaries
- Follow Clean Architecture strictly (Entity -> Model -> Repository -> Use Case -> State -> UI).
- No direct database (DBHelper) references from UI screens. Use the `SecureRepository` or modular use cases.

## 2. Coding Standards
- Strong typing only. Avoid dynamic data bindings.
- Keep components small, modular, and reusable.

## 3. Modification Restrictions
- Do NOT alter database structures or seed data without writing SQL migrations.
- Maintain existing encryption models and security filters.

## 4. Verification Checklists
- Agents must update `/brain/tasks.json` and mark items as "completed" or "in-progress" before ending their sessions.
- Run `python -m graphify update .` to keep the code graph perfectly indexed.
