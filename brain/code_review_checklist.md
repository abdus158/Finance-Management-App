# Code Review Checklist

This checklist is used by engineering agents and peer reviewers before merging any changes to the core `fcc_app` codebase.

## 1. Architecture Standards
- [ ] **Layer Boundaries**: UI code has no direct imports from the `data` layer or `DBHelper`. All UI interactions go through Use Cases or dedicated State Providers.
- [ ] **ChangeNotifier/Riverpod Boundaries**: Business logic is separated from visual layout. No business calculations are executed inside the `build()` methods.

## 2. Security Standards
- [ ] **Cryptographic Compliance**: Sensitive fields (names, transaction notes) are passed through `SecureRepository` for AES-256 encryption.
- [ ] **Input Sanitization**: User-facing text inputs are sanitized via `SecurityHelper.sanitizeString()` before writing to DB.
- [ ] **Sensitive Logs**: No encryption keys, salts, raw PINs, or raw transaction notes are printed in `print()` or `debugPrint()`.

## 3. Database Standards
- [ ] **Non-blocking Operations**: Extensive writes/reads use asynchronous calls.
- [ ] **Relations**: Linked keys (e.g. transfers, installments) are fully validated to prevent dangling references.

## 4. UI Quality
- [ ] **Glassmorphic Aesthetic**: All card containers use `AppTheme.glassDecoration()` or the `GlassPanel` widget. No plain flat surfaces.
- [ ] **Visual Performance**: Static elements use `const` constructors to prevent unnecessary rebuilds.
