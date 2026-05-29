# Financial Command Center (FCC)

Offline-first personal & business finance manager built with Flutter.

## Overview

This repository contains the FCC (Financial Command Center) Flutter app —
an offline-first expense, wallet, ledger and loans manager targeting
mobile, desktop and web platforms.

## Quickstart

Prerequisites:
- Flutter 3.10+
- A supported device (Chrome for web, a desktop target, or an emulator)

To fetch dependencies and run in debug mode on Chrome:

```bash
flutter pub get
flutter run -d chrome
```

To build a web release and serve locally:

```bash
flutter build web
cd build/web
python -m http.server 5001
# open http://localhost:5001/
```

Run tests:

```bash
flutter test
```

## Project structure

- `lib/` — application source (entry: `lib/main.dart`, app bootstrap at `lib/app/app.dart`)
- `modules/` — feature modules (ledger, wallet, loans, ...)
- `brain/` — design docs and architecture notes
- `graphify-out/` — codebase knowledge graph and reports

## Known issues

- Web runtime shows `DatabaseException(getDatabasesPath is null)` when using
	native sqflite APIs; project includes `sqflite_common_ffi_web` to help with
	web/database compatibility. See `lib/main.dart` for the web shim.
- The provided widget test `test/widget_test.dart` may need adjustment if
	app startup flow (initial route) is changed.

## Contributing

Open an issue or submit a pull request. For significant changes, open an
issue first to discuss the change.

## License

This repository is licensed under the MIT License. See `LICENSE`.
