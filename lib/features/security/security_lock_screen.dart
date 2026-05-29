import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/database/db_helper.dart';
import '../../core/security/secure_repository.dart';
import '../../core/security/security_helper.dart';
import '../../providers/fcc_provider.dart';

class SecurityLockScreen extends StatefulWidget {
  const SecurityLockScreen({super.key});

  @override
  State<SecurityLockScreen> createState() => _SecurityLockScreenState();
}

class _SecurityLockScreenState extends State<SecurityLockScreen>
    with TickerProviderStateMixin {
  bool _isSetupMode = false;
  bool _isConfirming = false;
  String _setupPin = '';
  String _currentInput = '';
  String _errorMessage = '';
  bool _checkingPin = true;
  bool _biometricAvailable = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 16)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    if (kIsWeb) {
      // Web: SQLite WASM requires SharedArrayBuffer which needs specific server
      // headers not available in all environments. Skip lock screen for web demo.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _navigateToMain();
      });
      return;
    }
    _checkUserExists();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await SecurityHelper.isBiometricAvailable();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkUserExists() async {
    try {
      final db = await DBHelper.instance.database;
      final result =
          await db.query('users', where: 'id = ?', whereArgs: ['local_user']);
      setState(() {
        _isSetupMode = result.isEmpty;
        _checkingPin = false;
      });
    } catch (_) {
      setState(() {
        _isSetupMode = true;
        _checkingPin = false;
      });
    }
  }

  void _onKey(String key) {
    if (_currentInput.length >= 6) return;
    setState(() {
      _currentInput += key;
      _errorMessage = '';
    });
    if (_currentInput.length == 6) {
      Future.delayed(const Duration(milliseconds: 120), _processPin);
    }
  }

  void _onBackspace() {
    if (_currentInput.isEmpty) return;
    setState(() =>
        _currentInput = _currentInput.substring(0, _currentInput.length - 1));
  }

  Future<void> _processPin() async {
    final secureRepo = SecureRepository();

    if (_isSetupMode) {
      if (!_isConfirming) {
        setState(() {
          _setupPin = _currentInput;
          _currentInput = '';
          _isConfirming = true;
        });
      } else {
        if (_currentInput == _setupPin) {
          await secureRepo.registerUserPin(_currentInput);
          if (mounted) _navigateToMain();
        } else {
          _triggerError('PINs do not match. Try again.');
          setState(() => _isConfirming = false);
        }
      }
    } else {
      final valid = await secureRepo.verifyUserPin(_currentInput);
      if (valid) {
        if (mounted) _navigateToMain();
      } else {
        _triggerError('Incorrect PIN. Try again.');
      }
    }
  }

  void _triggerError(String msg) {
    setState(() {
      _errorMessage = msg;
      _currentInput = '';
    });
    _shakeController.forward(from: 0);
  }

  void _navigateToMain() {
    Provider.of<FCCProvider>(context, listen: false).refreshAll();
    Navigator.of(context).pushReplacementNamed('/main');
  }

  Future<void> _tryBiometric() async {
    final success = await SecurityHelper.authenticateBiometrics();
    if (success && mounted) _navigateToMain();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPin) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body:
            Center(child: CircularProgressIndicator(color: AppTheme.primaryNeon)),
      );
    }

    final String title = _isSetupMode
        ? (_isConfirming ? 'Confirm PIN' : 'Create PIN')
        : 'Enter PIN';
    final String subtitle = _isSetupMode
        ? (_isConfirming
            ? 'Re-enter your 6-digit PIN'
            : 'Set a 6-digit security PIN')
        : 'Enter your 6-digit PIN to unlock';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Brand mark
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNeon.withOpacity(0.45),
                      blurRadius: 32,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 22),
              Text(
                'Financial Command Center',
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: AppTheme.primaryNeon,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(color: AppTheme.textMuted, fontSize: 12),
              ),

              const SizedBox(height: 44),

              // PIN dots
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(
                      _shakeAnimation.value *
                          ((_shakeController.value < 0.5) ? 1 : -1),
                      0),
                  child: child,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    final filled = i < _currentInput.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 9),
                      width: filled ? 20 : 16,
                      height: filled ? 20 : 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? AppTheme.primaryNeon : Colors.transparent,
                        border: Border.all(
                          color: filled
                              ? AppTheme.primaryNeon
                              : AppTheme.textMuted,
                          width: 2,
                        ),
                        boxShadow: filled
                            ? [
                                BoxShadow(
                                    color:
                                        AppTheme.primaryNeon.withOpacity(0.5),
                                    blurRadius: 10)
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 18),
              AnimatedOpacity(
                opacity: _errorMessage.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _errorMessage,
                  style:
                      GoogleFonts.inter(color: AppTheme.danger, fontSize: 13),
                ),
              ),

              const Spacer(),

              // Number pad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _row(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _row(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _row(['7', '8', '9']),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 80),
                        _numKey('0'),
                        _backspaceKey(),
                      ],
                    ),
                  ],
                ),
              ),

              // Biometric unlock — only in login mode on supported devices
              if (!_isSetupMode && _biometricAvailable) ...[
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _tryBiometric,
                  child: Column(children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryNeon.withOpacity(0.1),
                        border: Border.all(
                            color: AppTheme.primaryNeon.withOpacity(0.3),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.fingerprint_rounded,
                          color: AppTheme.primaryNeon, size: 28),
                    ),
                    const SizedBox(height: 6),
                    Text('Use Biometrics',
                        style: GoogleFonts.inter(
                            color: AppTheme.primaryNeon,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ]),
                ),
              ],

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(List<String> keys) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map(_numKey).toList(),
      );

  Widget _numKey(String key) {
    return GestureDetector(
      onTap: () => _onKey(key),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceHighest,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: Text(
            key,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _backspaceKey() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: const Center(
          child: Icon(Icons.backspace_outlined,
              color: AppTheme.textSecondary, size: 22),
        ),
      ),
    );
  }
}
