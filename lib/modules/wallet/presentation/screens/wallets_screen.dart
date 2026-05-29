import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/wallet_state.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WalletState>().loadWallets();
    });
  }

  void _showTransferModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    
    final wallets = context.read<WalletState>().wallets;
    if (wallets.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need at least two wallets to execute a transfer.")),
      );
      return;
    }

    String fromWalletId = wallets[0].id;
    String toWalletId = wallets[1].id;

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
                      const Text(
                        "Internal Wallet Transfer",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00FFCC),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // From Wallet Dropdown
                      DropdownButtonFormField<String>(
                        value: fromWalletId,
                        decoration: const InputDecoration(labelText: 'Source Wallet'),
                        dropdownColor: const Color(0xFF1E293B),
                        items: wallets.map((w) {
                          return DropdownMenuItem(value: w.id, child: Text(w.name));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            fromWalletId = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      // To Wallet Dropdown
                      DropdownButtonFormField<String>(
                        value: toWalletId,
                        decoration: const InputDecoration(labelText: 'Destination Wallet'),
                        dropdownColor: const Color(0xFF1E293B),
                        items: wallets.map((w) {
                          return DropdownMenuItem(value: w.id, child: Text(w.name));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            toWalletId = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      // Amount
                      TextFormField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Amount (PKR)',
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
                      // Notes
                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Transfer Reference / Notes',
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
                          if (fromWalletId == toWalletId) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Source and destination wallets must be different."), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          if (formKey.currentState!.validate()) {
                            try {
                              await context.read<WalletState>().executeTransfer(
                                    fromWalletId: fromWalletId,
                                    toWalletId: toWalletId,
                                    amount: double.parse(amountController.text),
                                    notes: notesController.text,
                                  );
                              Navigator.pop(ctx);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        child: const Text('EXECUTE TRANSFER', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final state = context.watch<WalletState>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "MY WALLETS",
          style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFCC)))
          : GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.2,
              ),
              itemCount: state.wallets.length,
              itemBuilder: (ctx, index) {
                final wallet = state.wallets[index];

                return Card(
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              wallet.type,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF00FFCC), fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.account_balance_wallet, color: Colors.white24),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wallet.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${wallet.balance.toStringAsFixed(0)} ${wallet.currency}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00FFCC),
        foregroundColor: const Color(0xFF0F172A),
        onPressed: () => _showTransferModal(context),
        label: const Text('TRANSFER', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.swap_horiz),
      ),
    );
  }
}
