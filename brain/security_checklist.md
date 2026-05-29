# FCC - Security & Testing Hardening Checklist

This document details the checklist required to verify the safety, reliability, and cryptographic integrity of the FCC mobile application before staging or production builds. It is structured around the **OWASP Mobile Application Security Verification Standard (MASVS)**.

---

## 🔐 1. Cryptography & Storage Hardening (MASVS-STORAGE)

* [ ] **Local SQLite DB Encryption (SQLCipher)**:
  * *Requirement*: Encrypt the database at rest using 256-bit AES encryption.
  * *Implementation*: Switch the standard `sqflite` dependency to `sqflite_sqlcipher` and generate a cryptographically secure key derived from the user's master biometric PIN.
* [ ] **Secure Storage for Keys (Keychain/Keystore)**:
  * *Requirement*: Never store master secrets, encryption keys, or biometric hashes in plain text inside shared preferences.
  * *Implementation*: Use `flutter_secure_storage` to write keys securely to iOS Keychain and Android Keystore.
* [ ] **Zero Residual Data in Memory**:
  * *Requirement*: Ensure sensitive variables (like biometrics pin hashes or temporary decryption keys) are cleared from memory immediately after usage.
  * *Implementation*: Set key variables to `null` or overwrite byte buffers after completing auth checks.

---

## 💉 2. Code Tampering & Injection Protection (MASVS-CODE)

* [ ] **100% Parameterized SQLite Queries**:
  * *Requirement*: Eliminate SQL injection entry points.
  * *Implementation*: Verify that every SQLite query in `db_helper.dart` uses parameterized variables (`?` placeholder) rather than raw string interpolation for user-entered input.
* [ ] **Strict Input Sanitization & Caps**:
  * *Requirement*: Prevent memory bloat and malformed data in fields.
  * *Implementation*: Apply input formatters on all transaction text fields, enforce strict caps (e.g. `double.tryParse` only, maximum length bounds), and sanitize escape characters.
* [ ] **Biometric App Lock Layer**:
  * *Requirement*: Enforce localized authentication when the app is brought to the foreground or resumes from a background state.
  * *Implementation*: Implement a Flutter `WidgetsBindingObserver` that triggers `local_auth` (FaceID / Fingerprint) check whenever the app state shifts to `AppLifecycleState.resumed`.

---

## 🧪 3. Complete Quality Assurance (QA) Testing Strategy

* [ ] **Unit Tests (Business Logic)**:
  * *Goal*: Verify core calculations under extreme values.
  * *Scenarios to test*:
    * Loan default trust score subtraction (overdue loans vs on-time payments).
    * Forecast burn rate calculations with zero expenditures (avoid divide-by-zero errors).
    * Form input parser boundary tests (negative numbers, overflow amounts).
* [ ] **Integration Tests (Double-Entry Workflows)**:
  * *Goal*: Assert wallet ledger data integrity during complex flows.
  * *Scenarios to test*:
    * Dual transaction balance transfer (confirm source decrements and destination increments).
    * Installment deductions (ensure transaction is added, loan remaining decreases, and wallet decrements inside an atomic transaction).
* [ ] **Security Attack Fuzzing (Red Teaming)**:
  * *Goal*: Try breaking the app's inputs using automated scripting or manual boundary entry.
  * *Scenarios to test*:
    * Malicious strings containing SQL commands (`' OR 1=1 --`) in transaction note inputs.
    * Extremely large balances (e.g., trillions) to ensure numerical boundaries do not throw unhandled exceptions or overflow SQLite REAL capacities.
