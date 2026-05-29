import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../models/wallet.dart';
import '../../providers/fcc_provider.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  static const _typeIcon = {
    'CASH': Icons.account_balance_wallet_rounded,
    'BANK': Icons.account_balance_rounded,
    'DIGITAL': Icons.phonelink_setup_rounded,
    'BUSINESS': Icons.business_center_rounded,
  };

  static Color _typeColor(String type) {
    switch (type) {
      case 'BANK':     return AppTheme.primaryNeon;
      case 'BUSINESS': return const Color(0xFFBD00FF);
      case 'DIGITAL':  return AppTheme.tertiaryNeon;
      default:         return const Color(0xFF64B5F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<FCCProvider>(context);
    final fmt = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    final total = p.wallets.fold(0.0, (s, w) => s + w.balance);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text('My Wallets',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded,
                color: AppTheme.primaryNeon, size: 26),
            tooltip: 'Internal Transfer',
            onPressed: () => showTransferDialog(context, p),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded,
                color: AppTheme.primaryNeon, size: 26),
            tooltip: 'Add Wallet',
            onPressed: () => _showAddWalletDialog(context, p),
          ),
        ],
      ),
      body: p.wallets.isEmpty
          ? _empty()
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
              children: [
                // ── Total strip ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryNeon.withValues(alpha: 0.15),
                        Colors.transparent
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.primaryNeon.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('COMBINED BALANCE',
                          style: GoogleFonts.inter(
                              color: AppTheme.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      Text(
                        fmt.format(total),
                        style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ]),
                    const Spacer(),
                    Text('${p.wallets.length} wallets',
                        style: GoogleFonts.inter(
                            color: AppTheme.primaryNeon,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),

                Text('MONEY CONTAINERS',
                    style: GoogleFonts.inter(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2)),
                const SizedBox(height: 14),

                ...p.wallets.map((w) => _walletCard(context, w, fmt, p)),
              ],
            ),
    );
  }

  Widget _walletCard(BuildContext ctx, Wallet w, NumberFormat fmt, FCCProvider p) {
    final col = _typeColor(w.type);
    final icon = _typeIcon[w.type] ?? Icons.account_balance_wallet_rounded;
    final totalBal = p.wallets.fold(0.0, (s, x) => s + x.balance);
    final pct = totalBal > 0 ? w.balance / totalBal : 0.0;

    return Dismissible(
      key: Key(w.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.danger.withValues(alpha: 0.4)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 26),
          const SizedBox(height: 4),
          Text('Delete',
              style: GoogleFonts.inter(
                  color: AppTheme.danger,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
      confirmDismiss: (_) async {
        return await _confirmDelete(ctx, w, p);
      },
      onDismissed: (_) {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: col.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
                color: col.withValues(alpha: 0.08), blurRadius: 20, spreadRadius: 0),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: col.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: col, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(w.name,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Text(w.type,
                    style: GoogleFonts.inter(
                        color: col.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                fmt.format(w.balance),
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(w.currency,
                  style: GoogleFonts.inter(
                      color: AppTheme.textMuted, fontSize: 10)),
            ]),
          ]),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(col),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(pct * 100).toStringAsFixed(1)}% of total balance',
            style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 10),
          ),
        ]),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext ctx, Wallet w, FCCProvider p) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Wallet?',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'Delete "${w.name}"? This requires a zero balance. Historical transactions are kept.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dCtx, true),
            child: Text('Delete',
                style: GoogleFonts.inter(
                    color: AppTheme.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (result != true) return false;
    final err = await p.deleteWallet(w.id);
    if (err != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(err,
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppTheme.dangerBright,
      ));
      return false;
    }
    return true;
  }

  Widget _empty() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.account_balance_wallet_outlined,
              color: AppTheme.textMuted, size: 56),
          const SizedBox(height: 16),
          Text('No wallets configured',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Tap + to add your first wallet',
              style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13)),
        ]),
      );

  // ── Add Wallet Dialog ─────────────────────────────────────────────────────
  static void _showAddWalletDialog(BuildContext context, FCCProvider p) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final balCtrl = TextEditingController(text: '0');
    String walletType = 'CASH';
    String currency = 'PKR';

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
                          width: 44, height: 4,
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Text('Add New Wallet',
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),

                  // Wallet type selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: AppTheme.surfaceHighest,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      'CASH', 'BANK', 'DIGITAL', 'BUSINESS',
                    ].map((t) {
                      final sel = walletType == t;
                      final col = _typeColor(t);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setS(() => walletType = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? col.withValues(alpha: 0.18) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: sel ? col : Colors.transparent),
                            ),
                            child: Center(
                              child: Text(
                                t == 'DIGITAL' ? 'DIG' : t == 'BUSINESS' ? 'BIZ' : t,
                                style: GoogleFonts.inter(
                                    color: sel ? col : AppTheme.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()),
                  ),
                  const SizedBox(height: 18),

                  TextFormField(
                    controller: nameCtrl,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(labelText: 'Wallet Name'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter wallet name' : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: balCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 15),
                    decoration: const InputDecoration(
                        labelText: 'Opening Balance', prefixText: 'Rs. '),
                    validator: (v) =>
                        (v == null || double.tryParse(v) == null || double.parse(v) < 0)
                            ? 'Enter valid balance (0 or more)'
                            : null,
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: currency,
                    dropdownColor: AppTheme.surfaceHighest,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: ['PKR', 'USD', 'EUR', 'GBP', 'AED', 'SAR']
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c,
                                style: GoogleFonts.inter(
                                    color: AppTheme.textPrimary))))
                        .toList(),
                    onChanged: (v) => setS(() => currency = v!),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final wallet = Wallet(
                            id: const Uuid().v4(),
                            name: nameCtrl.text.trim(),
                            type: walletType,
                            balance: double.parse(balCtrl.text.trim()),
                            currency: currency,
                          );
                          p.addWallet(wallet);
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNeon,
                        foregroundColor: const Color(0xFF003824),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Create Wallet',
                          style: GoogleFonts.inter(
                              fontSize: 15, fontWeight: FontWeight.w700)),
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

  // ── Transfer Dialog (static — callable from Dashboard) ────────────────────
  static void showTransferDialog(BuildContext context, FCCProvider provider) {
    if (provider.wallets.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Need at least 2 wallets to transfer.',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppTheme.dangerBright,
      ));
      return;
    }

    final formKey = GlobalKey<FormState>();
    final amtCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String fromId = provider.wallets.first.id;
    String toId = provider.wallets[1].id;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                  width: 44, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                )),
                const SizedBox(height: 16),
                Text('Internal Transfer',
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Move funds between your wallets',
                    style: GoogleFonts.inter(
                        color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 20),

                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: fromId,
                      dropdownColor: AppTheme.surfaceHighest,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(labelText: 'From'),
                      items: provider.wallets
                          .map((w) => DropdownMenuItem(
                              value: w.id,
                              child: Text(w.name,
                                  style: GoogleFonts.inter(
                                      color: AppTheme.textPrimary))))
                          .toList(),
                      onChanged: (v) {
                        setS(() {
                          fromId = v!;
                          if (fromId == toId) {
                            toId = provider.wallets
                                .firstWhere((w) => w.id != fromId)
                                .id;
                          }
                        });
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.arrow_forward_rounded,
                        color: AppTheme.primaryNeon, size: 22),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: toId,
                      dropdownColor: AppTheme.surfaceHighest,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(labelText: 'To'),
                      items: provider.wallets
                          .where((w) => w.id != fromId)
                          .map((w) => DropdownMenuItem(
                              value: w.id,
                              child: Text(w.name,
                                  style: GoogleFonts.inter(
                                      color: AppTheme.textPrimary))))
                          .toList(),
                      onChanged: (v) => setS(() => toId = v!),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),

                TextFormField(
                  controller: amtCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.inter(
                      color: AppTheme.textPrimary, fontSize: 15),
                  decoration: const InputDecoration(
                      labelText: 'Amount', prefixText: 'Rs. '),
                  validator: (v) {
                    if (v == null || double.tryParse(v) == null || double.parse(v) <= 0) {
                      return 'Enter valid amount';
                    }
                    final src = provider.wallets.firstWhere((w) => w.id == fromId);
                    if (double.parse(v) > src.balance) {
                      return 'Insufficient balance in ${src.name}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: notesCtrl,
                  style: GoogleFonts.inter(
                      color: AppTheme.textPrimary, fontSize: 14),
                  decoration:
                      const InputDecoration(labelText: 'Purpose / Notes'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Add reason' : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                    label: Text('Execute Transfer',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        provider.makeInternalTransfer(
                          fromWalletId: fromId,
                          toWalletId: toId,
                          amount: double.parse(amtCtrl.text.trim()),
                          notes: notesCtrl.text.trim(),
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNeon,
                      foregroundColor: const Color(0xFF003824),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
