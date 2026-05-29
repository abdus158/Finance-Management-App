import 'package:flutter/material.dart';
import '../features/security/security_lock_screen.dart';
import '../features/main_navigation.dart';
import '../features/ledger/ledger_screen.dart';
import '../features/wallets/wallets_screen.dart';
import '../features/loans/loans_screen.dart';
import '../features/settings/settings_screen.dart';

class AppRoutes {
  static const String lockscreen = '/';
  static const String mainNavigation = '/main';
  static const String ledger = '/ledger';
  static const String wallets = '/wallets';
  static const String loans = '/loans';
  static const String settings = '/settings';

  static final Map<String, WidgetBuilder> routes = {
    lockscreen: (context) => const SecurityLockScreen(),
    mainNavigation: (context) => const MainNavigation(),
    ledger: (context) => const LedgerScreen(),
    wallets: (context) => const WalletsScreen(),
    loans: (context) => const LoansScreen(),
    settings: (context) => const SettingsScreen(),
  };
}
