import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/security/security_helper.dart';
import '../../core/security/secure_repository.dart';
import '../../providers/fcc_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    try {
      final available = await SecurityHelper.isBiometricAvailable();
      if (mounted) setState(() => _biometricAvailable = available);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings',
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [

          // ── Security Section ─────────────────────────────────────────────
          _sectionHeader('SECURITY'),
          const SizedBox(height: 10),

          _settingsTile(
            icon: Icons.lock_outline_rounded,
            iconColor: AppTheme.primaryNeon,
            title: 'Change PIN',
            subtitle: 'Update your 6-digit security PIN',
            onTap: () => _showChangePinSheet(context),
          ),

          if (_biometricAvailable) ...[
            const SizedBox(height: 10),
            _settingsTile(
              icon: Icons.fingerprint_rounded,
              iconColor: AppTheme.tertiaryNeon,
              title: 'Biometric Unlock',
              subtitle: 'Use fingerprint / face to unlock app',
              trailing: Icon(Icons.check_circle_rounded,
                  color: AppTheme.success, size: 20),
              onTap: () {},
            ),
          ],

          const SizedBox(height: 24),

          // ── Data Section ─────────────────────────────────────────────────
          _sectionHeader('DATA'),
          const SizedBox(height: 10),

          _settingsTile(
            icon: Icons.refresh_rounded,
            iconColor: AppTheme.secondaryNeon,
            title: 'Refresh All Data',
            subtitle: 'Force sync from local database',
            onTap: () {
              Provider.of<FCCProvider>(context, listen: false).refreshAll();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Data refreshed.',
                    style: GoogleFonts.inter(color: Colors.white)),
                backgroundColor: AppTheme.surfaceHighest,
                duration: const Duration(seconds: 2),
              ));
            },
          ),

          const SizedBox(height: 24),

          // ── About Section ────────────────────────────────────────────────
          _sectionHeader('ABOUT'),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.surfaceDecoration(radius: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.primaryNeon.withValues(alpha: 0.3),
                            blurRadius: 12),
                      ],
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Financial Command Center',
                        style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    Text('Version 1.0.0',
                        style: GoogleFonts.inter(
                            color: AppTheme.textMuted, fontSize: 12)),
                  ]),
                ]),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withValues(alpha: 0.06)),
                const SizedBox(height: 12),
                _aboutRow('Platform', 'Offline-First · SQLite · AES-256'),
                const SizedBox(height: 8),
                _aboutRow('Encryption', 'AES-256 + PBKDF2 Key Derivation'),
                const SizedBox(height: 8),
                _aboutRow('Developer', 'Emerge Nexus'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) => Text(
        text,
        style: GoogleFonts.inter(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2),
      );

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.surfaceDecoration(radius: 14),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.inter(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: GoogleFonts.inter(
                      color: AppTheme.textMuted, fontSize: 12)),
            ]),
          ),
          trailing ??
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted, size: 20),
        ]),
      ),
    );
  }

  Widget _aboutRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: AppTheme.textMuted, fontSize: 12)),
          Text(value,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      );

  // ── Change PIN Sheet ────────────────────────────────────────────────────────
  void _showChangePinSheet(BuildContext ctx) {
    final p = Provider.of<FCCProvider>(ctx, listen: false);
    String step = 'current'; // current | new | confirm
    String currentInput = '';
    String newPin = '';
    String errorMsg = '';
    bool done = false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (bCtx) => StatefulBuilder(
        builder: (bCtx, setS) {
          final titles = {
            'current': 'Enter Current PIN',
            'new': 'Enter New PIN',
            'confirm': 'Confirm New PIN',
          };
          final subtitles = {
            'current': 'Verify your identity first',
            'new': 'Choose a new 6-digit PIN',
            'confirm': 'Re-enter your new PIN',
          };

          void onKey(String k) {
            if (currentInput.length >= 6) return;
            setS(() {
              currentInput += k;
              errorMsg = '';
            });
            if (currentInput.length == 6) {
              Future.delayed(const Duration(milliseconds: 150), () async {
                if (step == 'current') {
                  final valid = await SecureRepository().verifyUserPin(currentInput);
                  if (valid) {
                    setS(() { step = 'new'; currentInput = ''; });
                  } else {
                    setS(() { errorMsg = 'Incorrect PIN.'; currentInput = ''; });
                  }
                } else if (step == 'new') {
                  setS(() { newPin = currentInput; step = 'confirm'; currentInput = ''; });
                } else {
                  if (currentInput == newPin) {
                    await p.changePin(newPin);
                    setS(() { done = true; });
                    await Future.delayed(const Duration(milliseconds: 600));
                    if (bCtx.mounted) Navigator.pop(bCtx);
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text('PIN updated successfully.',
                            style: GoogleFonts.inter(color: Colors.white)),
                        backgroundColor: AppTheme.success,
                      ));
                    }
                  } else {
                    setS(() { errorMsg = 'PINs do not match.'; step = 'new'; currentInput = ''; newPin = ''; });
                  }
                }
              });
            }
          }

          void onBack() {
            if (currentInput.isEmpty) return;
            setS(() => currentInput = currentInput.substring(0, currentInput.length - 1));
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(bCtx).viewInsets.bottom + 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 44, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),

              if (done)
                Column(children: [
                  Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 52),
                  const SizedBox(height: 12),
                  Text('PIN Updated!',
                      style: GoogleFonts.inter(color: AppTheme.success, fontSize: 18, fontWeight: FontWeight.w700)),
                ])
              else ...[
                Text(titles[step]!,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitles[step]!,
                    style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 13)),
                const SizedBox(height: 28),

                Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      final filled = i < currentInput.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: filled ? 18 : 14,
                        height: filled ? 18 : 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled ? AppTheme.primaryNeon : Colors.transparent,
                          border: Border.all(
                              color: filled ? AppTheme.primaryNeon : AppTheme.textMuted, width: 2),
                        ),
                      );
                    })),

                const SizedBox(height: 12),
                AnimatedOpacity(
                  opacity: errorMsg.isNotEmpty ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(errorMsg,
                      style: GoogleFonts.inter(color: AppTheme.danger, fontSize: 12)),
                ),

                const SizedBox(height: 20),

                // Numpad
                ...[[' 1 ', '2', '3'], ['4', '5', '6'], ['7', '8', '9']].map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: row.map((k) => _pinKey(k.trim(), () => onKey(k.trim()))).toList()),
                )),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  const SizedBox(width: 64),
                  _pinKey('0', () => onKey('0')),
                  _backKey(onBack),
                ]),
              ],
            ]),
          );
        },
      ),
    );
  }

  Widget _pinKey(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceHighest,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
          child: Center(
            child: Text(label,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w600)),
          ),
        ),
      );

  Widget _backKey(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
          child: const Center(
            child: Icon(Icons.backspace_outlined, color: AppTheme.textSecondary, size: 20),
          ),
        ),
      );
}
