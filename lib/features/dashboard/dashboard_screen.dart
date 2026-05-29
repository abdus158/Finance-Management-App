import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphify/graphify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/fcc_provider.dart';
import '../../app/routes.dart';
import '../ledger/ledger_screen.dart';
import '../wallets/wallets_screen.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int)? onSwitchTab;
  const DashboardScreen({super.key, this.onSwitchTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _persona = 'ALL'; // ALL | PERSONAL | BUSINESS

  static const _personas = ['ALL', 'PERSONAL', 'BUSINESS'];
  static const _personaLabels = {
    'ALL': 'Command Center',
    'PERSONAL': 'Personal Space',
    'BUSINESS': 'Emerge Nexus',
  };
  static const _personaIcons = {
    'ALL': Icons.all_inclusive_rounded,
    'PERSONAL': Icons.person_rounded,
    'BUSINESS': Icons.business_center_rounded,
  };

  final _fmt = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<FCCProvider>(context);

    // ── Filtered wallets / transactions by persona ─────────────────────────
    final wallets = p.wallets.where((w) {
      if (_persona == 'ALL') return true;
      if (_persona == 'BUSINESS') return w.type == 'BUSINESS';
      return w.type != 'BUSINESS';
    }).toList();

    final allTx = p.transactions.where((tx) {
      if (_persona == 'ALL') return true;
      final cat = p.categories.firstWhere(
        (c) => c['id'] == tx.categoryId,
        orElse: () => {'context': 'BOTH'},
      );
      final ctx = cat['context'] as String;
      if (ctx == 'BOTH') return true;
      if (_persona == 'BUSINESS') return ctx == 'BUSINESS';
      return ctx == 'PERSONAL';
    }).toList();

    double totalBalance = wallets.fold(0, (s, w) => s + w.balance);
    final now = DateTime.now();
    double incomeMonth = 0, expenseMonth = 0;
    for (final tx in allTx) {
      if (tx.date.month == now.month && tx.date.year == now.year) {
        if (tx.type == 'INCOME') incomeMonth += tx.amount;
        if (tx.type == 'EXPENSE') expenseMonth += tx.amount;
      }
    }

    final forecast = p.cashForecast;
    final double burnRate = (forecast['dailyBurnRate'] ?? 0.0) as double;
    final String daysLeft = (forecast['daysRemaining'] ?? '∞') as String;
    final bool critical = (forecast['isCritical'] ?? false) as bool;

    // ── Build last-7-days chart data ───────────────────────────────────────
    final chartJson = _buildChartJson(allTx);

    final recentTx = allTx.take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryNeon,
          backgroundColor: AppTheme.surfaceContainer,
          onRefresh: p.refreshAll,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── App Bar ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back',
                              style: GoogleFonts.inter(
                                  color: AppTheme.textMuted, fontSize: 13)),
                          Text(
                            _personaLabels[_persona]!,
                            style: GoogleFonts.inter(
                              color: AppTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Persona toggle
                      GestureDetector(
                        onTap: _cyclePersona,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.primaryNeon, width: 2),
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.primaryNeon.withOpacity(0.3),
                                  blurRadius: 12)
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppTheme.surfaceContainer,
                            child: Icon(_personaIcons[_persona],
                                color: AppTheme.primaryNeon, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _iconBtn(Icons.settings_outlined,
                          () => Navigator.pushNamed(context, AppRoutes.settings)),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ── Balance Card ───────────────────────────────────────
                    _balanceCard(totalBalance, incomeMonth, expenseMonth),
                    const SizedBox(height: 16),

                    // ── Quick Actions ──────────────────────────────────────
                    _quickActions(context, p),
                    const SizedBox(height: 20),

                    // ── Cash Forecast ──────────────────────────────────────
                    _forecastCard(critical, daysLeft, burnRate),
                    const SizedBox(height: 24),

                    // ── Chart label ────────────────────────────────────────
                    _sectionLabel('ACTIVITY — LAST 7 DAYS'),
                    const SizedBox(height: 12),

                    // ── ECharts Interactive Chart ──────────────────────────
                    Container(
                      height: 220,
                      decoration: AppTheme.glassDecoration(radius: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: GraphifyView(
                          key: ValueKey('chart-${allTx.length}-$_persona'),
                          controller: GraphifyController(),
                          initialOptions: chartJson,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Wallet mini-strip ──────────────────────────────────
                    _sectionHeader('MY WALLETS', 'View All', () {
                      widget.onSwitchTab?.call(1);
                    }),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: wallets.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) => _walletChip(wallets[i]),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Recent Transactions ────────────────────────────────
                    _sectionHeader('RECENT TRANSACTIONS', 'View All', () {
                      Navigator.pushNamed(context, AppRoutes.ledger);
                    }),
                    const SizedBox(height: 12),

                    if (recentTx.isEmpty)
                      _emptyState('No transactions yet.\nTap + to add one.')
                    else
                      ...recentTx.map((tx) {
                        final cat = p.categories.firstWhere(
                          (c) => c['id'] == tx.categoryId,
                          orElse: () =>
                              {'name': 'Other', 'icon': 'category'},
                        );
                        return _txTile(tx, cat);
                      }),

                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Balance Card ──────────────────────────────────────────────────────────
  Widget _balanceCard(double total, double income, double expense) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2B3C), Color(0xFF0D1B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppTheme.primaryNeon.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primaryNeon.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 0),
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL BALANCE / NET WORTH',
              style: GoogleFonts.inter(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Text(
            _fmt.format(total),
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _balanceStat(true, income)),
            Container(width: 1, height: 36, color: Colors.white10),
            Expanded(child: _balanceStat(false, expense)),
          ]),
        ],
      ),
    );
  }

  Widget _balanceStat(bool isIncome, double amount) {
    final color = isIncome ? AppTheme.success : AppTheme.danger;
    return Padding(
      padding: EdgeInsets.only(
          left: isIncome ? 0 : 16, right: isIncome ? 16 : 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
                isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: color,
                size: 14),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isIncome ? 'Income' : 'Expenses',
                  style: GoogleFonts.inter(
                      color: AppTheme.textMuted, fontSize: 11)),
              Text(
                _fmt.format(amount),
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────
  Widget _quickActions(BuildContext ctx, FCCProvider p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionBtn(Icons.add_rounded, 'Add', AppTheme.primaryNeon, () {
          LedgerScreen.showAddTransactionDialog(ctx, p);
        }),
        _actionBtn(Icons.swap_horiz_rounded, 'Transfer', AppTheme.tertiaryNeon, () {
          WalletsScreen.showTransferDialog(ctx, p);
        }),
        _actionBtn(Icons.receipt_long_rounded, 'Ledger', AppTheme.secondaryNeon, () {
          Navigator.pushNamed(ctx, AppRoutes.ledger);
        }),
        _actionBtn(Icons.insights_rounded, 'Trends', const Color(0xFFBD00FF), () {
          widget.onSwitchTab?.call(3);
        }),
      ],
    );
  }

  Widget _actionBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // ── Forecast Card ─────────────────────────────────────────────────────────
  Widget _forecastCard(bool critical, String days, double burnRate) {
    final color = critical ? AppTheme.danger : AppTheme.success;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: color.withOpacity(critical ? 0.4 : 0.2)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(
              critical
                  ? Icons.warning_amber_rounded
                  : Icons.verified_rounded,
              color: color,
              size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              critical ? 'CRITICAL CASH FORECAST' : 'CASH STABILITY',
              style: GoogleFonts.inter(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2),
            ),
            const SizedBox(height: 3),
            Text(
              critical
                  ? 'High burn rate! Runs out in $days days.'
                  : 'Stable. Cash secure for $days days.',
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              'Daily burn: ${_fmt.format(burnRate)}',
              style: GoogleFonts.inter(
                  color: AppTheme.textMuted, fontSize: 11),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Wallet Chip ───────────────────────────────────────────────────────────
  Widget _walletChip(wallet) {
    final grad = AppTheme.walletGradient(wallet.type as String);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: grad,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(wallet.name as String,
              style: GoogleFonts.inter(
                  color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(
            _fmt.format(wallet.balance),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  // ── Transaction Tile ──────────────────────────────────────────────────────
  Widget _txTile(tx, Map<String, dynamic> cat) {
    final isIncome = tx.type == 'INCOME';
    final isTransfer = tx.type == 'TRANSFER';
    final color = isIncome
        ? AppTheme.success
        : isTransfer
            ? AppTheme.tertiaryNeon
            : AppTheme.danger;
    final sign = isIncome ? '+' : isTransfer ? '↔' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppTheme.surfaceDecoration(radius: 14),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(_categoryIcon(cat['icon'] as String? ?? 'category'),
              color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              tx.notes.isEmpty ? cat['name'] as String : tx.notes as String,
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${cat['name']} · ${DateFormat('dd MMM, hh:mm a').format(tx.date as DateTime)}',
              style: GoogleFonts.inter(
                  color: AppTheme.textMuted, fontSize: 11),
            ),
          ]),
        ),
        Text(
          '$sign${_fmt.format(tx.amount)}',
          style: GoogleFonts.inter(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ]),
    );
  }

  // ── ECharts options ───────────────────────────────────────────────────────
  Map<String, dynamic> _buildChartJson(List txList) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    final incomeData = <double>[];
    final expenseData = <double>[];
    final labels = <String>[];

    for (final day in days) {
      double inc = 0, exp = 0;
      for (final tx in txList) {
        final d = tx.date as DateTime;
        if (d.day == day.day && d.month == day.month && d.year == day.year) {
          if (tx.type == 'INCOME') inc += tx.amount as double;
          if (tx.type == 'EXPENSE') exp += tx.amount as double;
        }
      }
      incomeData.add(inc);
      expenseData.add(exp);
      labels.add(DateFormat('MMM d').format(day));
    }

    return {
      'backgroundColor': 'transparent',
      'tooltip': {'trigger': 'axis', 'axisPointer': {'type': 'shadow'}},
      'legend': {
        'data': ['Income', 'Expenses'],
        'textStyle': {'color': '#8E929F', 'fontSize': 11},
        'top': 4,
      },
      'grid': {
        'left': '2%', 'right': '2%', 'bottom': '3%',
        'top': '18%', 'containLabel': true,
      },
      'xAxis': {
        'type': 'category',
        'data': labels,
        'axisLine': {'lineStyle': {'color': '#3C4A42'}},
        'axisLabel': {'color': '#86948A', 'fontSize': 10},
      },
      'yAxis': {
        'type': 'value',
        'splitLine': {'lineStyle': {'color': 'rgba(255,255,255,0.04)'}},
        'axisLabel': {'color': '#86948A', 'fontSize': 10},
      },
      'series': [
        {
          'name': 'Income',
          'type': 'bar',
          'stack': 'total',
          'barMaxWidth': 18,
          'data': incomeData,
          'itemStyle': {'color': '#4EDEA3', 'borderRadius': [4, 4, 0, 0]},
        },
        {
          'name': 'Expenses',
          'type': 'bar',
          'stack': 'total',
          'barMaxWidth': 18,
          'data': expenseData,
          'itemStyle': {'color': '#FFB3AD', 'borderRadius': [4, 4, 0, 0]},
        },
      ],
    };
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _cyclePersona() {
    final i = _personas.indexOf(_persona);
    setState(() => _persona = _personas[(i + 1) % _personas.length]);
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.surfaceHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 20),
        ),
      );

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2),
      );

  Widget _sectionHeader(String label, String action, VoidCallback onTap) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionLabel(label),
          GestureDetector(
            onTap: onTap,
            child: Text(action,
                style: GoogleFonts.inter(
                    color: AppTheme.primaryNeon,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      );

  Widget _emptyState(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(msg,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: AppTheme.textMuted, fontSize: 13, height: 1.6)),
        ),
      );

  IconData _categoryIcon(String name) {
    const map = {
      'fastfood': Icons.fastfood_rounded,
      'home': Icons.home_rounded,
      'work': Icons.work_rounded,
      'shopping_bag': Icons.shopping_bag_rounded,
      'payments': Icons.payments_rounded,
      'campaign': Icons.campaign_rounded,
      'dns': Icons.dns_rounded,
      'people': Icons.people_rounded,
      'category': Icons.category_rounded,
    };
    return map[name] ?? Icons.receipt_rounded;
  }
}
