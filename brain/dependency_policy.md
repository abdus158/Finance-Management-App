# Dependency Control Policy

This policy governs the inclusion of external packages in the FinTrack project to prevent security vulnerabilities, performance regressions, and "vibe-code" dependencies.

## Allowed Packages

### State Management
- `flutter_riverpod` (v2.x or latest stable)
- `riverpod_annotation`

### Database
- `isar` (v3.x or latest stable)
- `isar_flutter_libs`

### Cryptography & Security
- `encrypt` (AES-256 wrapping)
- `crypto` (SHA-256/SHA-512)
- `local_auth` (Biometrics)

### Utilities
- `uuid`
- `intl`

### UI & Charts
- `graphify` (High-fidelity interactive ECharts bridge)

---

## Forbidden Packages

- **Abandoned Libraries**: Any package not updated in the last 12 months.
- **Unverified Crypto**: Custom or obscure cryptography packages. Only use standard `encrypt` and `crypto` libraries.
- **Excessive UI packages**: Do not install heavy UI styling libraries (e.g., ad-hoc card packages). Hand-craft glassmorphic cards using the native `Container`, `BackdropFilter`, and the established `AppTheme` parameters.
