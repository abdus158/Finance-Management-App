import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/loan.dart';
import '../../providers/fcc_provider.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _fmt = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<FCCProvider>(context);
    final recv = p.loans.where((l) => l.type == 'RECEIVABLE').toList();
    final pay = p.loans.where((l) => l.type == 'PAYABLE').toList();

    // Summary totals
    double totalRecv = recv
        .where((l) => l.status == 'ACTIVE')
        .fold(0.0, (s, l) => s + l.remainingAmount);
    double totalPay = pay
        .where((l) => l.status == 'ACTIVE')
        .fold(0.0, (s, l) => s + l.remainingAmount);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text('Loan & Liability Engine',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded,
                color: AppTheme.primaryNeon, size: 26),
            onPressed: () => _showAddLoanDialog(context, p),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('They Owe Me',
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                Text(_fmt.format(totalRecv),
                    style: GoogleFonts.inter(
                        color: AppTheme.success, fontSize: 11)),
              ]),
            ),
            Tab(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('I Owe Them',
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                Text(_fmt.format(totalPay),
                    style: GoogleFonts.inter(
                        color: AppTheme.danger, fontSize: 11)),
              ]),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _loanList(recv, p, isRecv: true),
          _loanList(pay, p, isRecv: false),
        ],
      ),
    );
  }

  Widget _loanList(List<Loan> loans, FCCProvider p, {required bool isRecv}) {
    if (loans.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
              isRecv
                  ? Icons.move_to_inbox_rounded
                  : Icons.outbox_rounded,
              color: AppTheme.textMuted,
              size: 52),
          const SizedBox(height: 14),
          Text(
              isRecv
                  ? 'No receivables recorded'
                  : 'No payables recorded',
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Tap + to add a loan record',
              style: GoogleFonts.inter(
                  color: AppTheme.textMuted, fontSize: 13)),
        ]),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      children: loans.map((l) => _loanCard(l, p, isRecv)).toList(),
    );
  }

  Widget _loanCard(Loan loan, FCCProvider p, bool isRecv) {
    final isPaid = loan.status == 'PAID';
    final isOverdue = !isPaid && DateTime.now().isAfter(loan.dueDate);
    final Color statusColor = isPaid
        ? AppTheme.textMuted
        : isOverdue
            ? AppTheme.dangerBright
            : AppTheme.warning;

    final double score = isRecv
        ? (p.trustScores[loan.personName] ?? 100.0)
        : 100.0;
    final Color scoreColor = score > 70
        ? AppTheme.success
        : score > 40
            ? AppTheme.warning
            : AppTheme.dangerBright;

    final double paidPct = loan.principalAmount > 0
        ? (loan.principalAmount - loan.remainingAmount) / loan.principalAmount
        : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isPaid
                ? Colors.white.withOpacity(0.06)
                : statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: statusColor.withOpacity(0.06),
              blurRadius: 16,
              spreadRadius: 0),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                loan.personName.isNotEmpty
                    ? loan.personName[0].toUpperCase()
                    : '?',
                style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(loan.personName,
                  style: GoogleFonts.inter(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              Text(
                'Due: ${DateFormat('dd MMM yyyy').format(loan.dueDate)}',
                style: GoogleFonts.inter(
                    color: AppTheme.textMuted, fontSize: 11),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isPaid ? 'PAID' : (isOverdue ? 'OVERDUE' : 'ACTIVE'),
              style: GoogleFonts.inter(
                  color: statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _confirmDeleteLoan(context, loan, p),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.danger, size: 16),
            ),
          ),
        ]),

        const SizedBox(height: 14),

        // Amounts row
        Row(children: [
          Expanded(
            child: _amtStat('Principal', loan.principalAmount, AppTheme.textSecondary),
          ),
          Expanded(
            child: _amtStat(
                'Remaining',
                loan.remainingAmount,
                isPaid ? AppTheme.textMuted : AppTheme.primaryNeon),
          ),
        ]),

        const SizedBox(height: 12),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: paidPct.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.06),
            valueColor: AlwaysStoppedAnimation<Color>(
                isPaid ? AppTheme.success : AppTheme.primaryNeon),
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            '${(paidPct * 100).toStringAsFixed(0)}% paid',
            style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 10),
          ),
          if (isRecv && !isPaid)
            Row(children: [
              Icon(Icons.shield_outlined, color: scoreColor, size: 12),
              const SizedBox(width: 4),
              Text('Trust: ${score.toInt()}%',
                  style: GoogleFonts.inter(
                      color: scoreColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ]),
        ]),

        if (!isPaid) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              icon: Icon(
                  isRecv
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 16),
              label: Text(
                  isRecv ? 'Record Received Payment' : 'Pay Installment',
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              onPressed: () =>
                  _showPayInstallmentDialog(context, loan, p),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryNeon,
                side: const BorderSide(
                    color: AppTheme.primaryNeon, width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _amtStat(String label, double val, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: AppTheme.textMuted, fontSize: 10)),
          const SizedBox(height: 2),
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

  // ── Pay Installment Dialog ────────────────────────────────────────────────
  void _showPayInstallmentDialog(
      BuildContext ctx, Loan loan, FCCProvider p) {
    final formKey = GlobalKey<FormState>();
    final amtCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String walletId = p.wallets.isNotEmpty ? p.wallets.first.id : '';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (bCtx) => StatefulBuilder(
        builder: (bCtx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(bCtx).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
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
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text(
                    loan.type == 'RECEIVABLE'
                        ? 'Record Received Payment'
                        : 'Pay Installment',
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                    'Outstanding: ${_fmt.format(loan.remainingAmount)} — ${loan.personName}',
                    style: GoogleFonts.inter(
                        color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: walletId.isEmpty ? null : walletId,
                  dropdownColor: AppTheme.surfaceHighest,
                  style: GoogleFonts.inter(
                      color: AppTheme.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Wallet'),
                  items: p.wallets
                      .map((w) => DropdownMenuItem(
                          value: w.id,
                          child: Text('${w.name} — ${_fmt.format(w.balance)}',
                              style: GoogleFonts.inter(
                                  color: AppTheme.textPrimary))))
                      .toList(),
                  onChanged: (v) => setS(() => walletId = v!),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: amtCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.inter(
                      color: AppTheme.textPrimary, fontSize: 15),
                  decoration: const InputDecoration(
                      labelText: 'Payment Amount', prefixText: 'Rs. '),
                  validator: (v) {
                    if (v == null || double.tryParse(v) == null || double.parse(v) <= 0)
                      return 'Enter valid amount';
                    if (double.parse(v) > loan.remainingAmount)
                      return 'Exceeds outstanding balance';
                    if (loan.type == 'PAYABLE' && walletId.isNotEmpty) {
                      final w = p.wallets.firstWhere((w) => w.id == walletId,
                          orElse: () => p.wallets.first);
                      if (double.parse(v) > w.balance)
                        return 'Insufficient wallet balance';
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
                      const InputDecoration(labelText: 'Reference Notes'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Add notes' : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        p.payInstallment(
                          loanId: loan.id,
                          walletId: walletId,
                          amount: double.parse(amtCtrl.text.trim()),
                          notes: notesCtrl.text.trim(),
                        );
                        Navigator.pop(bCtx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNeon,
                      foregroundColor: const Color(0xFF003824),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Record Payment',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Add Loan Dialog ───────────────────────────────────────────────────────
  void _showAddLoanDialog(BuildContext ctx, FCCProvider p) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    String loanType = 'RECEIVABLE';
    int durationDays = 30;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (bCtx) => StatefulBuilder(
        builder: (bCtx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(bCtx).viewInsets.bottom + 24),
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
                              borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Text('New Loan / Liability',
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
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      _loanTypeBtn(
                          setS, 'RECEIVABLE', loanType, 'They Owe Me',
                          AppTheme.success, (v) => loanType = v),
                      _loanTypeBtn(setS, 'PAYABLE', loanType, 'I Owe Them',
                          AppTheme.danger, (v) => loanType = v),
                    ]),
                  ),
                  const SizedBox(height: 18),

                  TextFormField(
                    controller: nameCtrl,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 14),
                    decoration:
                        const InputDecoration(labelText: 'Contact / Person Name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter name'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: amtCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 15),
                    decoration: const InputDecoration(
                        labelText: 'Principal Amount', prefixText: 'Rs. '),
                    validator: (v) =>
                        (v == null || double.tryParse(v) == null || double.parse(v) <= 0)
                            ? 'Enter valid amount'
                            : null,
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<int>(
                    value: durationDays,
                    dropdownColor: AppTheme.surfaceHighest,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 14),
                    decoration:
                        const InputDecoration(labelText: 'Repayment Deadline'),
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('7 Days')),
                      DropdownMenuItem(value: 15, child: Text('15 Days')),
                      DropdownMenuItem(
                          value: 30, child: Text('30 Days (1 Month)')),
                      DropdownMenuItem(
                          value: 90, child: Text('90 Days (3 Months)')),
                      DropdownMenuItem(
                          value: 180, child: Text('180 Days (6 Months)')),
                    ],
                    onChanged: (v) => setS(() => durationDays = v!),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final loan = Loan(
                            id: const Uuid().v4(),
                            personName: nameCtrl.text.trim(),
                            type: loanType,
                            principalAmount:
                                double.parse(amtCtrl.text.trim()),
                            remainingAmount:
                                double.parse(amtCtrl.text.trim()),
                            dueDate: DateTime.now()
                                .add(Duration(days: durationDays)),
                            status: 'ACTIVE',
                          );
                          p.addNewLoan(loan);
                          Navigator.pop(bCtx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryNeon,
                        foregroundColor: const Color(0xFF003824),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Create Loan Record',
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

  Widget _loanTypeBtn(
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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? color.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: sel ? color : Colors.transparent),
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.inter(
                    color: sel ? color : AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteLoan(BuildContext ctx, loan, FCCProvider p) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Loan?',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'Remove loan record for "${loan.personName}"? All installment history will be deleted.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dCtx);
              p.deleteLoan(loan.id as String);
            },
            child: Text('Delete',
                style: GoogleFonts.inter(
                    color: AppTheme.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
