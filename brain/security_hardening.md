# Security Hardening

## Threat Model

Potential threats:
- Reverse engineering
- Data tampering
- Injection attacks
- Unauthorized access
- APK modification

---

## Mandatory Security Rules

### Input Validation
- Validate every user input
- No direct interpolation in queries
- Strict type checking

### Storage Security
- Use encrypted storage for secrets
- No hardcoded API keys
- PIN must be hashed

### Application Lock
- Biometric support
- Auto-lock after inactivity

### Logging
- Never log sensitive data
- Never expose stack traces in production

### Build Security
- Obfuscate release builds
- Disable debug logs in production

### API Security (Future)
- HTTPS only
- Token validation
- Request throttling
