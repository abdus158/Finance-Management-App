import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphify/graphify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/fcc_provider.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  String _range = '7D'; // 7D | 30D | 3M | 1Y
  final _fmt = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

  static const _ranges = ['7D', '30D', '3M', '1Y'];
  static const _rangeDays = {'7D': 7, '30D': 30, '3M': 90, '1Y': 365};

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<FCCProvider>(context);
    final days = _rangeDays[_range]!;
    final cutoff = DateTime.now().subtract(Duration(days: days));

    final rangedTx = p.transactions
        .where((tx) => tx.date.isAfter(cutoff))
        .toList();

    double totalIncome = 0, totalExpenses = 0;
    for (final tx in rangedTx) {
      if (tx.type == 'INCOME') totalIncome += tx.amount;
      if (tx.type == 'EXPENSE') totalExpenses += tx.amount;
    }
    final net = totalIncome - totalExpenses;

    // Category sums for pie chart
    final Map<String, double> catSums = {};
    for (final tx in rangedTx) {
      if (tx.type == 'EXPENSE') {
        final cat = p.categories.firstWhere(
          (c) => c['id'] == tx.categoryId,
          orElse: () => {'name': 'Other'},
        );
        final n = cat['name'] as String;
        catSums[n] = (catSums[n] ?? 0) + tx.amount;
      }
    }

    // Time series for line chart
    final lineJson = _buildLineChart(rangedTx, days);
    final pieJson = _buildPieChart(catSums);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text('Analytics & Trends',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppTheme.primaryNeon, size: 22),
            onPressed: p.refreshAll,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryNeon,
        backgroundColor: AppTheme.surfaceContainer,
        onRefresh: p.refreshAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Time range selector ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(children: _ranges.map((r) {
                  final sel = _range == r;
                  return GestureDetector(
                    onTap: () => setState(() => _range = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppTheme.primaryNeon
                            : AppTheme.surfaceHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? AppTheme.primaryNeon
                                : Colors.white.withOpacity(0.08)),
                      ),
                      child: Text(r,
                          style: GoogleFonts.inter(
                            color: sel
                                ? const Color(0xFF003824)
                                : AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  );
                }).toList()),
              ),

              // ── Net flow card ────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassDecoration(
                  radius: 20,
                  borderColor: (net >= 0 ? AppTheme.success : AppTheme.danger)
                      .withOpacity(0.25),
                  glowColor: net >= 0 ? AppTheme.success : AppTheme.danger,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NET FLOW — $_range',
                          style: GoogleFonts.inter(
                              color: AppTheme.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      Text(
                        _fmt.format(net),
                        style: GoogleFonts.inter(
                          color: net >= 0 ? AppTheme.success : AppTheme.danger,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: _flowStat('Total Income', totalIncome,
                              AppTheme.success, Icons.arrow_downward_rounded),
                        ),
                        Container(width: 1, height: 36, color: Colors.white10),
                        Expanded(
                          child: _flowStat('Total Expenses', totalExpenses,
                              AppTheme.danger, Icons.arrow_upward_rounded),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      if (totalIncome > 0)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Savings Rate',
                                        style: GoogleFonts.inter(
                                            color: AppTheme.textMuted,
                                            fontSize: 11)),
                                    Text(
                                      '${((net / totalIncome) * 100).clamp(0, 100).toStringAsFixed(1)}%',
                                      style: GoogleFonts.inter(
                                          color: AppTheme.primaryNeon,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ]),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (net / totalIncome).clamp(0.0, 1.0),
                                  minHeight: 6,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.06),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryNeon),
                                ),
                              ),
                            ]),
                    ]),
              ),
              const SizedBox(height: 24),

              // ── Income vs Expense line chart ─────────────────────────────
              _sectionLabel('INCOME VS EXPENSE TREND'),
              const SizedBox(height: 12),
              Container(
                height: 240,
                decoration: AppTheme.glassDecoration(radius: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GraphifyView(
                    key: ValueKey('line-$_range'),
                    controller: GraphifyController(),
                    initialOptions: lineJson,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Category pie chart ───────────────────────────────────────
              _sectionLabel('EXPENSE BY CATEGORY'),
              const SizedBox(height: 12),
              Container(
                height: 260,
                decoration: AppTheme.glassDecoration(radius: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GraphifyView(
                    key: ValueKey('pie-$_range-${catSums.length}'),
                    controller: GraphifyController(),
                    initialOptions: pieJson,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Category breakdown list ──────────────────────────────────
              if (catSums.isNotEmpty) ...[
                _sectionLabel('CATEGORY BREAKDOWN'),
                const SizedBox(height: 12),
                ...catSums.entries
                    .toList()
                    .sorted((a, b) => b.value.compareTo(a.value))
                    .map((e) => _categoryRow(e.key, e.value, totalExpenses)),
              ],

              // ── Transaction count card ────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.surfaceDecoration(radius: 16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _miniStat('Transactions', rangedTx.length.toString()),
                      Container(width: 1, height: 36, color: const Color(0x14FFFFFF)),
                      _miniStat(
                          'Avg/Day',
                          _fmt.format(
                              days > 0 ? totalExpenses / days : 0)),
                      Container(width: 1, height: 36, color: const Color(0x14FFFFFF)),
                      _miniStat('Categories',
                          catSums.keys.length.toString()),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Flow stat ──────────────────────────────────────────────────────────────
  Widget _flowStat(String label, double val, Color color, IconData icon) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 12),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: GoogleFonts.inter(
                    color: AppTheme.textMuted, fontSize: 10)),
            Text(
              _fmt.format(val),
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ]),
        ]),
      );

  // ── Category row ──────────────────────────────────────────────────────────
  Widget _categoryRow(String name, double val, double total) {
    final pct = total > 0 ? val / total : 0.0;
    const colors = [
      Color(0xFF4EDEA3),
      Color(0xFFBD00FF),
      Color(0xFFFF007A),
      Color(0xFF33B5E5),
      Color(0xFFFFBB33),
      Color(0xFFFF4444),
    ];
    final color = colors[name.hashCode.abs() % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppTheme.surfaceDecoration(radius: 14),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Text(name.isNotEmpty ? name[0] : '?',
                style: GoogleFonts.inter(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(name,
                  style: GoogleFonts.inter(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text(
                _fmt.format(val),
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: Colors.white.withOpacity(0.06),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _miniStat(String label, String val) => Column(children: [
        Text(val,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 10)),
      ]);

  Widget _sectionLabel(String t) => Text(t,
      style: GoogleFonts.inter(
          color: AppTheme.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2));

  // ── ECharts builders ──────────────────────────────────────────────────────
  Map<String, dynamic> _buildLineChart(List txList, int totalDays) {
    final now = DateTime.now();
    final bucketCount = totalDays <= 7 ? totalDays : (totalDays <= 30 ? 10 : 12);
    final bucketDays = (totalDays / bucketCount).ceil();

    final incomeData = <double>[];
    final expenseData = <double>[];
    final labels = <String>[];

    for (int i = bucketCount - 1; i >= 0; i--) {
      final end = now.subtract(Duration(days: i * bucketDays));
      final start = end.subtract(Duration(days: bucketDays));
      double inc = 0, exp = 0;
      for (final tx in txList) {
        final d = tx.date as DateTime;
        if (d.isAfter(start) && d.isBefore(end)) {
          if (tx.type == 'INCOME') inc += tx.amount as double;
          if (tx.type == 'EXPENSE') exp += tx.amount as double;
        }
      }
      incomeData.add(inc);
      expenseData.add(exp);
      labels.add(DateFormat('MMM d').format(end));
    }

    return {
      'backgroundColor': 'transparent',
      'tooltip': {'trigger': 'axis'},
      'legend': {
        'data': ['Income', 'Expenses'],
        'textStyle': {'color': '#86948A', 'fontSize': 11},
        'top': 4,
      },
      'grid': {
        'left': '3%', 'right': '3%', 'bottom': '3%',
        'top': '20%', 'containLabel': true,
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
          'type': 'line',
          'smooth': true,
          'showSymbol': false,
          'data': incomeData,
          'lineStyle': {'width': 3, 'color': '#4EDEA3'},
          'areaStyle': {
            'color': {
              'type': 'linear', 'x': 0, 'y': 0, 'x2': 0, 'y2': 1,
              'colorStops': [
                {'offset': 0, 'color': 'rgba(78,222,163,0.25)'},
                {'offset': 1, 'color': 'rgba(78,222,163,0.01)'},
              ],
            },
          },
        },
        {
          'name': 'Expenses',
          'type': 'line',
          'smooth': true,
          'showSymbol': false,
          'data': expenseData,
          'lineStyle': {'width': 3, 'color': '#FFB3AD'},
          'areaStyle': {
            'color': {
              'type': 'linear', 'x': 0, 'y': 0, 'x2': 0, 'y2': 1,
              'colorStops': [
                {'offset': 0, 'color': 'rgba(255,179,173,0.2)'},
                {'offset': 1, 'color': 'rgba(255,179,173,0.01)'},
              ],
            },
          },
        },
      ],
    };
  }

  Map<String, dynamic> _buildPieChart(Map<String, double> catSums) {
    const palette = [
      '#4EDEA3', '#BD00FF', '#FF007A', '#33B5E5', '#FFBB33',
      '#FF4444', '#00C9A7', '#F59E0B', '#8B5CF6', '#EC4899',
    ];

    if (catSums.isEmpty) {
      return {
        'backgroundColor': 'transparent',
        'graphic': [
          {
            'type': 'text', 'left': 'center', 'top': 'middle',
            'style': {'text': 'No expense data', 'fill': '#86948A', 'fontSize': 13},
          }
        ],
      };
    }

    final data = catSums.entries.mapIndexed((i, e) => <String, dynamic>{
      'value': e.value.toInt(),
      'name': e.key,
      'itemStyle': {'color': palette[i % palette.length]},
    }).toList();

    return {
      'backgroundColor': 'transparent',
      'tooltip': {'trigger': 'item', 'formatter': '{b}: Rs. {c} ({d}%)'},
      'legend': {
        'orient': 'horizontal', 'bottom': '2%',
        'textStyle': {'color': '#86948A', 'fontSize': 10},
      },
      'series': [
        {
          'name': 'Expenses',
          'type': 'pie',
          'radius': ['38%', '65%'],
          'center': ['50%', '45%'],
          'avoidLabelOverlap': true,
          'itemStyle': {'borderRadius': 6, 'borderColor': '#0B1326', 'borderWidth': 2},
          'label': {'show': false},
          'emphasis': {
            'label': {'show': true, 'fontSize': 13, 'fontWeight': 'bold', 'color': '#DAE2FD'},
          },
          'labelLine': {'show': false},
          'data': data,
        },
      ],
    };
  }
}

// Extension to mimic Python's enumerate for lists
extension _IndexedIterable<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T item) fn) {
    var i = 0;
    return map((item) => fn(i++, item));
  }

  List<T> sorted(int Function(T a, T b) compare) {
    final list = toList();
    list.sort(compare);
    return list;
  }
}
