# FCC - Threat Model & Vulnerability Analysis

This document provides a red-team threat model analyzing the primary attack vectors for the FCC mobile application and defining concrete, defensive mitigations.

---

## 🗺️ 1. Threat Landscape & Attack Surface

```
                                  🚨 ATTACK VECTORS 🚨
                                           │
         ┌─────────────────────────────────┼─────────────────────────────────┐
         ▼                                 ▼                                 ▼
┌──────────────────┐             ┌──────────────────┐             ┌──────────────────┐
│  PHYSICAL THEFT  │             │ LOGICAL ATTACKS  │             │ DYNAMIC ANALYSIS │
│ - DB Extraction  │             │ - SQL Injection  │             │ - Runtime Hooks  │
│ - Shared Prefs   │             │ - Input Overflows│             │ - Root Bypass    │
└──────────────────┘             └──────────────────┘             └──────────────────┘
```

---

## 🎯 2. Attack Vector Analysis & Mitigations

### Attack Vector A: Physical Device Theft & Database Extraction
* **Description**: An attacker gains physical possession of an unlocked mobile device, connects it via Android Debug Bridge (ADB) or Xcode, extracts the application sandbox files, and reads the local `fcc_database.db` SQLite database containing personal/business balance statements.
* **Risk Level**: HIGH
* **Defensive Mitigation**:
  1. Switch local storage engine to **SQLCipher** to encrypt SQLite files using 256-bit AES.
  2. Derive the database password key dynamically from a random salt and the user's secure biometric authentication payload.
  3. Store the master encryption key using the **iOS Keychain** and **Android Keystore** services via the secure-hardware enclave, preventing extraction.

---

### Attack Vector B: Input Injection & Database Manipulation (SQLi)
* **Description**: A malicious local entry (e.g. adding a transaction or contact name with SQL control strings like `' UNION SELECT...`) targets input forms to manipulate query logic, bypass balances, or delete entries.
* **Risk Level**: MEDIUM
* **Defensive Mitigation**:
  1. **Strict Parameterized Queries**: Every database access statement in `db_helper.dart` MUST use placeholder arguments (`?`) rather than interpolating strings directly into queries.
  2. **Regular Expression Filters**: Enforce alphanumeric limitations on contact and category names at the presentation layer using custom input formatters.

---

### Attack Vector C: Reverse Engineering & Decompilation
* **Description**: An attacker extracts the compiled APK (Android) or IPA (iOS) package, decompiles the bytecode, reviews the SQLite scheme details, and uncovers hardcoded keys or logic flaws in the forecasting model.
* **Risk Level**: LOW (since it is a local-only app, there are no proprietary cloud API endpoints to compromise)
* **Defensive Mitigation**:
  1. Compile release builds with compiler-level optimization and symbol stripping:
     ```bash
     flutter build apk --obfuscate --split-debug-info=/<directory>
     ```
  2. Implement root detection hooks (`flutter_jailbreak_detection`) to prevent execution on compromised, rooted, or jailbroken mobile environments.
