import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transaction.dart';
import '../../providers/fcc_provider.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();

  // â”€â”€ Add Transaction Modal â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static void showAddTransactionDialog(
      BuildContext context, FCCProvider provider) {
    if (provider.wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add a wallet first.',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppTheme.dangerBright,
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final tagsCtrl = TextEditingController();
    String walletId = provider.wallets.first.id;
    String catId = provider.categories.isNotEmpty
        ? provider.categories.first['id'] as String
        : '';
    String txType = 'EXPENSE';
    String priority = 'LOW';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('New Transaction',
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),

                  // Type toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(children: [
                      _typeBtn(ctx, setS, 'EXPENSE', txType, 'Cash Out',
                          AppTheme.danger, (v) => txType = v),
                      _typeBtn(ctx, setS, 'INCOME', txType, 'Cash In',
                          AppTheme.success, (v) => txType = v),
                    ]),
                  ),
                  const SizedBox(height: 18),

                  // Amount
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'Rs. ',
                      prefixStyle: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: 15),
                    ),
                    validator: (v) =>
                        (v == null || double.tryParse(v) == null || double.parse(v) <= 0)
                            ? 'Enter valid amount'
                            : null,
                  ),
                  const SizedBox(height: 14),

                  // Wallet
                  DropdownButtonFormField<String>(
                    value: walletId,
                    dropdownColor: AppTheme.surfaceHighest,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 14),
                    decoration:
                        const InputDecoration(labelText: 'Wallet'),
                    items: provider.wallets
                        .map((w) => DropdownMenuItem(
                            value: w.id,
                            child: Text(w.name,
                                style: GoogleFonts.inter(
                                    color: AppTheme.textPrimary))))
                        .toList(),
                    onChanged: (v) => setS(() => walletId = v!),
                  ),
                  const SizedBox(height: 14),

                  // Category
                  DropdownButtonFormField<String>(
                    value: catId.isEmpty ? null : catId,
                    dropdownColor: AppTheme.surfaceHighest,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 14),
                    decoration:
                        const InputDecoration(labelText: 'Category'),
                    items: provider.categories
                        .map((c) => DropdownMenuItem(
                            value: c['id'] as String,
                            child: Text(c['name'] as String,
                                style: GoogleFonts.inter(
                                    color: AppTheme.textPrimary))))
                        .toList(),
                    onChanged: (v) => setS(() => catId = v!),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Select category' : null,
                  ),
                  const SizedBox(height: 14),

                  // Notes
                  TextFormField(
                    controller: notesCtrl,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 14),
                    decoration:
                        const InputDecoration(labelText: 'Notes / Description'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Add a description'
                            : null,
                  ),
                  const SizedBox(height: 14),

                  // Tags
                  TextFormField(
                    controller: tagsCtrl,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Tags (optional)',
                      hintText: 'e.g. nexus, dinner, rent',
                      hintStyle: GoogleFonts.inter(
                          color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Priority
                  Row(children: [
                    Text('Priority:',
                        style: GoogleFonts.inter(
                            color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(width: 12),
                    ...['LOW', 'MEDIUM', 'HIGH'].map((pr) {
                      final sel = priority == pr;
                      final col = pr == 'HIGH'
                          ? AppTheme.danger
                          : pr == 'MEDIUM'
                              ? AppTheme.warning
                              : AppTheme.textMuted;
                      return GestureDetector(
                        onTap: () => setS(() => priority = pr),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? col.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: sel ? col : Colors.white12),
                          ),
                          child: Text(pr,
                              style: GoogleFonts.inter(
                                  color: sel ? col : AppTheme.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ),
                      );
                    }),
                  ]),
                  const SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final tx = TransactionModel(
                            id: const Uuid().v4(),
                            walletId: walletId,
                            type: txType,
                            amount: double.parse(amountCtrl.text.trim()),
                            categoryId: catId,
                            tags: tagsCtrl.text.trim(),
                            priority: priority,
                            date: DateTime.now(),
                            notes: notesCtrl.text.trim(),
                          );
                          provider.addNewTransaction(tx);
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNeon,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text('Record Transaction',
                          style: GoogleFonts.inter(
                              color: const Color(0xFF003824),
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _typeBtn(
    BuildContext ctx,
    StateSetter setS,
    String type,
    String current,
    String label,
    Color color,
    Function(String) onChange,
  ) {
    final sel = current == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setS(() => onChange(type)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: sel ? color : Colors.transparent, width: 1),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: sel ? color : AppTheme.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LedgerScreenState extends State<LedgerScreen> {
  String _type = 'ALL';
  String _search = '';
  final _fmt = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<FCCProvider>(context);

    final txs = p.transactions.where((tx) {
      if (_type != 'ALL' && tx.type != _type) return false;
      if (_search.isNotEmpty &&
          !tx.notes.toLowerCase().contains(_search.toLowerCase())) return false;
      return true;
    }).toList();

    // Group by date
    final Map<String, List> grouped = {};
    for (final tx in txs) {
      final key = DateFormat('dd MMM yyyy').format(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }
    final keys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text('Smart Ledger',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.primaryNeon, size: 26),
            onPressed: () => LedgerScreen.showAddTransactionDialog(context, p),
          ),
        ],
      ),
      body: Column(
        children: [
          // â”€â”€ Search + Filter bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(children: [
              TextField(
                onChanged: (v) => setState(() => _search = v),
                style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search transactionsâ€¦',
                  hintStyle: GoogleFonts.inter(color: AppTheme.textMuted),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: AppTheme.textMuted, size: 18),
                          onPressed: () => setState(() => _search = ''),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                _chip('ALL', 'All'),
                const SizedBox(width: 8),
                _chip('INCOME', 'Cash In'),
                const SizedBox(width: 8),
                _chip('EXPENSE', 'Cash Out'),
                const SizedBox(width: 8),
                _chip('TRANSFER', 'Transfer'),
              ]),
            ]),
          ),

          // â”€â”€ Summary strip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (txs.isNotEmpty) _summaryStrip(txs),

          // â”€â”€ Transaction list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            child: txs.isEmpty
                ? _empty()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                    itemCount: keys.length,
                    itemBuilder: (_, gi) {
                      final dateKey = keys[gi];
                      final dayTxs = grouped[dateKey]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 6),
                            child: Text(dateKey,
                                style: GoogleFonts.inter(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8)),
                          ),
                          ...dayTxs.map((tx) {
                            final cat = p.categories.firstWhere(
                              (c) => c['id'] == tx.categoryId,
                              orElse: () =>
                                  {'name': 'Other', 'icon': 'category'},
                            );
                            return Dismissible(
                              key: Key(tx.id as String),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.danger.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: AppTheme.danger.withValues(alpha: 0.4)),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: Icon(Icons.delete_outline_rounded,
                                    color: AppTheme.danger, size: 22),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (dCtx) => AlertDialog(
                                    backgroundColor: AppTheme.surfaceContainer,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    title: Text('Delete Transaction?',
                                        style: GoogleFonts.inter(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.w700)),
                                    content: Text(
                                      'This will reverse the wallet balance. Cannot be undone.',
                                      style: GoogleFonts.inter(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dCtx, false),
                                        child: Text('Cancel',
                                            style: GoogleFonts.inter(
                                                color: AppTheme.textMuted)),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(dCtx, true),
                                        child: Text('Delete',
                                            style: GoogleFonts.inter(
                                                color: AppTheme.danger,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                ) ?? false;
                              },
                              onDismissed: (_) => p.deleteTransaction(tx.id as String),
                              child: _txTile(tx, cat, p),
                            );
                          }),
                          const SizedBox(height: 4),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStrip(List txs) {
    double inc = 0, exp = 0;
    for (final tx in txs) {
      if (tx.type == 'INCOME') inc += tx.amount as double;
      if (tx.type == 'EXPENSE') exp += tx.amount as double;
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.surfaceDecoration(radius: 14),
      child: Row(children: [
        _stripStat('IN', inc, AppTheme.success),
        const SizedBox(width: 12),
        Container(width: 1, height: 28, color: Colors.white10),
        const SizedBox(width: 12),
        _stripStat('OUT', exp, AppTheme.danger),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('NET',
              style: GoogleFonts.inter(
                  color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
          Text(
            _fmt.format(inc - exp),
            style: GoogleFonts.inter(
              color: (inc - exp) >= 0 ? AppTheme.success : AppTheme.danger,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _stripStat(String label, double val, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
          Text(
            _fmt.format(val),
            style: GoogleFonts.inter(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      );

  Widget _txTile(tx, Map<String, dynamic> cat, FCCProvider p) {
    final isIncome = tx.type == 'INCOME';
    final isTransfer = tx.type == 'TRANSFER';
    final color = isIncome
        ? AppTheme.success
        : isTransfer
            ? AppTheme.tertiaryNeon
            : AppTheme.danger;

    Color priorityDot = Colors.transparent;
    if (tx.priority == 'HIGH') priorityDot = AppTheme.danger;
    if (tx.priority == 'MEDIUM') priorityDot = AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: AppTheme.surfaceDecoration(radius: 14),
      child: Row(children: [
        Stack(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_catIcon(cat['icon'] as String? ?? 'category'),
                color: color, size: 22),
          ),
          if (priorityDot != Colors.transparent)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: priorityDot,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.background, width: 1.5)),
              ),
            ),
        ]),
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
            const SizedBox(height: 3),
            Text(
              '${cat['name']} Â· ${DateFormat('hh:mm a').format(tx.date as DateTime)}',
              style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 11),
            ),
            if (tx.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Wrap(
                  spacing: 4,
                  children: (tx.tagList as List<String>)
                      .take(3)
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNeon.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('#$t',
                                style: GoogleFonts.inter(
                                    color: AppTheme.primaryNeon, fontSize: 9)),
                          ))
                      .toList(),
                ),
              ),
          ]),
        ),
        Text(
          '${isIncome ? "+" : isTransfer ? "â†”" : "-"}${_fmt.format(tx.amount)}',
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

  Widget _chip(String type, String label) {
    final sel = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primaryNeon : AppTheme.surfaceHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: sel
                  ? AppTheme.primaryNeon
                  : Colors.white.withOpacity(0.08)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: sel ? const Color(0xFF003824) : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _empty() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.receipt_long_rounded, color: AppTheme.textMuted, size: 56),
          const SizedBox(height: 16),
          Text('No transactions found',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Tap + to record your first entry',
              style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13)),
        ]),
      );

  IconData _catIcon(String name) {
    const m = {
      'fastfood': Icons.fastfood_rounded,
      'home': Icons.home_rounded,
      'work': Icons.work_rounded,
      'shopping_bag': Icons.shopping_bag_rounded,
      'payments': Icons.payments_rounded,
      'campaign': Icons.campaign_rounded,
      'dns': Icons.dns_rounded,
      'people': Icons.people_rounded,
      'category': Icons.category_rounded,
      'swap_horiz': Icons.swap_horiz_rounded,
    };
    return m[name] ?? Icons.receipt_rounded;
  }
}
