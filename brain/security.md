# Security Guidelines

## 1. Input Validation
- No null values allowed in ledger inputs.
- Amount must be strictly greater than 0.
- All transaction notes and tags must be truncated and sanitized.
- Special character escaping and regular expressions must filter out SQL symbols.

## 2. Data Protection
- PIN must be hashed using SHA-512 with a dynamic salt.
- Sensitive financial data (transaction notes, loan contact PII) must be encrypted using 256-bit AES.

## 3. Storage Rules
- No plain text passwords, biometric hashes, or encryption keys in source files.
- Access tokens or master encryption keys must reside strictly in iOS Keychain or Android Keystore sandboxes.

## 4. Local Protections
- Local biometric / PIN app lock triggered immediately when application transitions out of foreground state.
- Compile and build releases using `--obfuscate` compiler parameters.
