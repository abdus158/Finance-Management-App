import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/loan_entity.dart';
import '../state/loan_state.dart';
import '../../../wallet/presentation/state/wallet_state.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<LoanState>().loadLoans();
      context.read<WalletState>().loadWallets();
    });
  }

  void _showAddLoanModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = 'RECEIVABLE'; // they owe us

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "New Loan / Liability",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00FFCC),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Person Name
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Contact / Person Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FFCC))),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter contact name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  // Principal Amount
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Principal Amount (PKR)',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FFCC))),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter an amount';
                      final num = double.tryParse(val);
                      if (num == null || num <= 0) return 'Please enter a positive value';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  // Loan Type
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    dropdownColor: const Color(0xFF1E293B),
                    items: const [
                      DropdownMenuItem(value: 'RECEIVABLE', child: Text('RECEIVABLE (They Owe Me)', style: TextStyle(color: Color(0xFF00FFCC)))),
                      DropdownMenuItem(value: 'PAYABLE', child: Text('PAYABLE (I Owe Them)', style: TextStyle(color: Color(0xFFFF007A)))),
                    ],
                    onChanged: (val) => selectedType = val!,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FFCC),
                      foregroundColor: const Color(0xFF0F172A),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final principal = double.parse(amountController.text);
                        final loan = LoanEntity(
                          id: const Uuid().v4(),
                          personName: nameController.text,
                          type: selectedType,
                          principalAmount: principal,
                          remainingAmount: principal,
                          dueDate: DateTime.now().add(const Duration(days: 30)), // default due date in 30 days
                          status: 'ACTIVE',
                        );
                        try {
                          await context.read<LoanState>().addNewLoan(loan);
                          Navigator.pop(ctx);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    child: const Text('CREATE LOAN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showInstallmentModal(BuildContext context, LoanEntity loan) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    
    final wallets = context.read<WalletState>().wallets;
    if (wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No wallets found. Create a wallet first.")),
      );
      return;
    }

    String selectedWalletId = wallets[0].id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (stCtx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pay Installment - ${loan.personName}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00FFCC),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedWalletId,
                        decoration: const InputDecoration(labelText: 'Wallet'),
                        dropdownColor: const Color(0xFF1E293B),
                        items: wallets.map((w) {
                          return DropdownMenuItem(value: w.id, child: Text(w.name));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedWalletId = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Amount (Max: ${loan.remainingAmount})',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FFCC))),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter an amount';
                          final num = double.tryParse(val);
                          if (num == null || num <= 0) return 'Please enter a positive value';
                          if (num > loan.remainingAmount) return 'Cannot exceed remaining amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Payment Reference / Notes',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FFCC))),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please add a reference';
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FFCC),
                          foregroundColor: const Color(0xFF0F172A),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              await context.read<LoanState>().executeInstallment(
                                    loanId: loan.id,
                                    walletId: selectedWalletId,
                                    amount: double.parse(amountController.text),
                                    notes: notesController.text,
                                  );
                              // refresh wallets balances
                              await context.read<WalletState>().loadWallets();
                              Navigator.pop(ctx);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        child: const Text('SUBMIT PAYMENT', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoanState>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "LOANS & LIABILITIES",
          style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFCC)))
          : state.loans.isEmpty
              ? const Center(
                  child: Text(
                    "No Loans or Liabilities recorded.",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: state.loans.length,
                  itemBuilder: (ctx, index) {
                    final loan = state.loans[index];
                    final isPayable = loan.type == 'PAYABLE';
                    final score = state.trustScores[loan.personName] ?? 100.0;

                    return Card(
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: isPayable ? const Color(0xFFFF007A).withOpacity(0.2) : const Color(0xFF00FFCC).withOpacity(0.2),
                                child: Icon(
                                  isPayable ? Icons.call_made : Icons.call_received,
                                  color: isPayable ? const Color(0xFFFF007A) : const Color(0xFF00FFCC),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    loan.personName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  if (!isPayable)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "Trust: ${score.toStringAsFixed(0)}%",
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: score > 75 ? const Color(0xFF00FFCC) : const Color(0xFFFF007A),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Principal: ${loan.principalAmount.toStringAsFixed(0)} PKR | Due in 30 Days",
                                  style: const TextStyle(fontSize: 12, color: Colors.white38),
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${loan.remainingAmount.toStringAsFixed(0)} PKR",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    loan.status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: loan.status == 'PAID' ? const Color(0xFF00FFCC) : Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (loan.status == 'ACTIVE')
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF00FFCC)),
                                  onPressed: () => _showInstallmentModal(context, loan),
                                  icon: const Icon(Icons.payment, size: 16),
                                  label: const Text('PAY INSTALLMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00FFCC),
        foregroundColor: const Color(0xFF0F172A),
        onPressed: () => _showAddLoanModal(context),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
