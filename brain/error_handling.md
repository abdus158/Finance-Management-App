# Global Error & Crash Handling Strategy

To prevent user frustration and keep the application state resilient during unexpected exceptions, FinTrack employs a tiered fail-closed and fallback architecture.

## UI Exception Handling

1. **Global Error Widget**:
   * Implement a fallback visual UI using `MaterialApp.builder` that intercepts visual failures and shows a clean, glassmorphic error card: "Something went wrong. The command center has recovered safely." instead of a red screen of death.
2. **Toast Feedback**:
   * Show subtle bottom snackbars/toasts for non-critical errors (e.g. "Failed to record transfer: Insufficient funds").

## Data & Cryptography Fallbacks

1. **Decryption Fail-safe**:
   * In `SecurityHelper.decryptField()`, if decryption fails due to a key mismatch, return the ciphertext rather than crashing. This prevents complete app-wide database load failure.
2. **Closed Transactions**:
   * If a transaction insert fails, utilize SQLite/Isar's native transaction rollback mechanism to guarantee database consistency.
