import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/glass_panel.dart';
import '../../../ledger/presentation/state/ledger_state.dart';
import '../../../wallet/presentation/state/wallet_state.dart';
import '../../../loans/presentation/state/loan_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  bool _isPersonal = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController);

    Future.microtask(() {
      context.read<LedgerState>().loadTransactions();
      context.read<WalletState>().loadWallets();
      context.read<LoanState>().loadLoans();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ledgerState = context.watch<LedgerState>();
    final walletState = context.watch<WalletState>();

    final totalBalance = walletState.wallets.fold<double>(0, (sum, w) => sum + w.balance);
    final recentTx = ledgerState.transactions.take(3).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
              elevation: 0,
              flexibleSpace: ClipRect(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Row(
                          children: [
                            ClipPath(
                              clipper: _HexClipper(),
                              child: Container(
                                width: 40,
                                height: 40,
                                color: theme.primaryColor,
                                alignment: Alignment.center,
                                child: Text(
                                  'FT',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'FinTrack',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        // Personal / Business Toggle
                        Container(
                          height: 36,
                          width: 180,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF303636),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Stack(
                            children: [
                              AnimatedAlign(
                                alignment: _isPersonal ? Alignment.centerLeft : Alignment.centerRight,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child: Container(
                                  width: 86,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22BBC6),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primaryColor.withValues(alpha: 0.4),
                                        blurRadius: 10,
                                      )
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _isPersonal ? 'Personal' : 'Business',
                                    style: const TextStyle(
                                      fontFamily: 'Space Grotesk',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF00363A),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _isPersonal = true),
                                      child: const SizedBox(height: double.infinity),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _isPersonal = false),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          _isPersonal ? 'Business' : 'Personal',
                                          style: TextStyle(
                                            fontFamily: 'Space Grotesk',
                                            fontSize: 12,
                                            color: Colors.white.withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Actions
                        Icon(Icons.cloud_done_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      ],
                    ),
                  ),
                ),
              ),
              toolbarHeight: 64,
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 32),

                  // ── Hero: Balance ────────────────────────────────────
                  Text(
                    'CURRENT LIQUIDITY',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 12,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w500,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.5,
                      color: theme.colorScheme.onSurface,
                      shadows: [
                        Shadow(
                          color: theme.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.trending_up, color: theme.primaryColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '+12.4%',
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Synced just now',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Quick Stats Row ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.account_balance_outlined,
                          label: 'Wallets',
                          value: '${walletState.wallets.length}',
                          theme: theme,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.payments_outlined,
                          label: 'Debts',
                          value: '\$12k',
                          theme: theme,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Recent Activity ──────────────────────────────────
                  GlassPanel(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Recent Activity',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FadeTransition(
                                  opacity: _pulseAnimation,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/ledger'),
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  fontFamily: 'Space Grotesk',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (recentTx.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No transactions yet. Add your first entry!',
                                style: TextStyle(
                                  fontFamily: 'Space Grotesk',
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          )
                        else
                          ...recentTx.map((tx) {
                            final isExpense = tx.type == 'EXPENSE';
                            final txColor = isExpense ? theme.colorScheme.error : theme.primaryColor;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B2121).withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.06),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: txColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isExpense ? Icons.shopping_cart_outlined : Icons.work_outline,
                                      color: txColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx.notes.isEmpty ? 'Transaction' : tx.notes,
                                          style: TextStyle(
                                            fontFamily: 'Space Grotesk',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          tx.categoryId,
                                          style: TextStyle(
                                            fontFamily: 'Space Grotesk',
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isExpense ? '-' : '+'}\$${tx.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: txColor,
                                        ),
                                      ),
                                      Text(
                                        '${tx.date.day}/${tx.date.month}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Asset Allocation Card ────────────────────────────
                  GlassPanel(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ASSET ALLOCATION',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 11,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChip('Stocks 65%', theme.primaryColor, theme),
                            _buildChip('Crypto 15%', theme.colorScheme.secondary, theme),
                            _buildChip('Cash 20%', const Color(0xFFD2BCFF), theme),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.primaryColor.withValues(alpha: 0.3),
                                width: 12,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'High\nRisk',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Bottom nav padding
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required Color color,
  }) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.25, 0);
    path.lineTo(w * 0.75, 0);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.75, h);
    path.lineTo(w * 0.25, h);
    path.lineTo(0, h * 0.5);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
