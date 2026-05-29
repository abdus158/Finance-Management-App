import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/glass_panel.dart';
import '../state/ledger_state.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<LedgerState>().loadTransactions();
    });
  }

  void _showAddTransactionModal(BuildContext context) {
    // Keep internal logic but adapt UI later in a separate task
    // Placeholder to match new UI design later
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LedgerState>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "History",
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Review and manage your complete financial footprint.",
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              // Search Bar
              GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: 12,
                child: TextField(
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    hintText: "Search transactions, tags...",
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3)),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip("All", true, theme),
                    const SizedBox(width: 8),
                    _buildFilterChip("Income", false, theme),
                    const SizedBox(width: 8),
                    _buildFilterChip("Expense", false, theme),
                    const SizedBox(width: 8),
                    _buildFilterChip("Transfers", false, theme),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: state.isLoading
                    ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                    : state.transactions.isEmpty
                        ? Center(
                            child: Text(
                              "No Secure Ledger Transactions Yet.",
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.transactions.length,
                            itemBuilder: (ctx, index) {
                              final tx = state.transactions[index];
                              final isExpense = tx.type == 'EXPENSE';
                              final txColor = isExpense ? theme.colorScheme.error : theme.colorScheme.primary;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: GlassPanel(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: txColor.withOpacity(0.1),
                                          border: Border.all(color: txColor.withOpacity(0.2)),
                                        ),
                                        child: Icon(
                                          isExpense ? Icons.shopping_cart : Icons.payments,
                                          color: txColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx.notes.isEmpty ? "Transaction" : tx.notes,
                                              style: TextStyle(
                                                fontFamily: 'Space Grotesk',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: theme.colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.surface.withOpacity(0.4),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                                  ),
                                                  child: Text(
                                                    tx.categoryId.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontFamily: 'Space Grotesk',
                                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "• ${tx.date.day}/${tx.date.month}/${tx.date.year}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: txColor.withOpacity(0.3),
                                                  blurRadius: 15,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              "${isExpense ? '-' : '+'}\$${tx.amount.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: txColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            tx.type,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.colorScheme.onSurface.withOpacity(0.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: theme.primaryColor,
          foregroundColor: theme.colorScheme.onPrimary,
          onPressed: () => _showAddTransactionModal(context),
          child: const Icon(Icons.add, size: 30),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? theme.primaryColor : const Color(0xFF1B2121).withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? Colors.transparent : theme.primaryColor.withOpacity(0.2),
        ),
        boxShadow: isActive
            ? [BoxShadow(color: theme.primaryColor.withOpacity(0.4), blurRadius: 10)]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}
