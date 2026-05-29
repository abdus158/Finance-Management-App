import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../providers/fcc_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'wallets/wallets_screen.dart';
import 'loans/loans_screen.dart';
import 'trends/trends_screen.dart';
import 'ledger/ledger_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _index = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(onSwitchTab: (i) => setState(() => _index = i)),
      const WalletsScreen(),
      const LoansScreen(),
      const TrendsScreen(),
    ];
  }

  static const _labels = ['Home', 'Wallets', 'Loans', 'Trends'];
  static const _outlineIcons = [
    Icons.dashboard_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.handshake_outlined,
    Icons.trending_up_outlined,
  ];
  static const _solidIcons = [
    Icons.dashboard_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.handshake_rounded,
    Icons.trending_up_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<FCCProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: _index, children: _screens),

      // ── Floating Action Button ─────────────────────────────────────────
      floatingActionButton: _FAB(onTap: () {
        LedgerScreen.showAddTransactionDialog(context, p);
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom Navigation Bar ──────────────────────────────────────────
      bottomNavigationBar: _BottomBar(
        selectedIndex: _index,
        onTap: (i) => setState(() => _index = i),
        labels: _labels,
        outlineIcons: _outlineIcons,
        solidIcons: _solidIcons,
      ),
    );
  }
}

// ── FAB ────────────────────────────────────────────────────────────────────
class _FAB extends StatelessWidget {
  final VoidCallback onTap;
  const _FAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: AppTheme.primaryNeon.withOpacity(0.45),
                blurRadius: 20,
                spreadRadius: 0),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

// ── Bottom Bar ─────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;
  final List<IconData> outlineIcons;
  final List<IconData> solidIcons;

  const _BottomBar({
    required this.selectedIndex,
    required this.onTap,
    required this.labels,
    required this.outlineIcons,
    required this.solidIcons,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer.withOpacity(0.92),
            border:
                Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
          ),
          child: Row(children: [
            // Left two items
            Expanded(child: _navItem(0)),
            Expanded(child: _navItem(1)),
            // FAB space
            const SizedBox(width: 64),
            // Right two items
            Expanded(child: _navItem(2)),
            Expanded(child: _navItem(3)),
          ]),
        ),
      ),
    );
  }

  Widget _navItem(int index) {
    final sel = selectedIndex == index;
    final color = sel ? AppTheme.primaryNeon : AppTheme.textMuted;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: sel
                  ? BoxDecoration(
                      color: AppTheme.primaryNeon.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    )
                  : null,
              child: Icon(
                sel ? solidIcons[index] : outlineIcons[index],
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              labels[index],
              style: GoogleFonts.inter(
                color: color,
                fontSize: 10,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
