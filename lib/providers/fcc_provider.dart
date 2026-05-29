import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/database/db_helper.dart';
import '../core/security/secure_repository.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../models/loan.dart';

class FCCProvider extends ChangeNotifier {
  final SecureRepository _secureRepository = SecureRepository();

  List<Wallet> _wallets = [];
  List<TransactionModel> _transactions = [];
  List<Loan> _loans = [];
  Map<String, double> _trustScores = {};
  Map<String, dynamic> _cashForecast = {};
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;

  List<Wallet> get wallets => _wallets;
  List<TransactionModel> get transactions => _transactions;
  List<Loan> get loans => _loans;
  Map<String, double> get trustScores => _trustScores;
  Map<String, dynamic> get cashForecast => _cashForecast;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;

  FCCProvider() {
    refreshAll();
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      _wallets = await DBHelper.instance.getAllWallets();
      _transactions = await _secureRepository.getDecryptedTransactions();
      _loans = await _secureRepository.getDecryptedLoans();
      
      // Calculate dynamic trust scores locally based on decrypted contact names
      final Map<String, double> scores = {};
      final now = DateTime.now().millisecondsSinceEpoch;
      for (var loan in _loans) {
        if (loan.type == 'RECEIVABLE') {
          double score = 100.0;
          if (loan.status == 'ACTIVE' && now > loan.dueDate.millisecondsSinceEpoch) {
            final delayMs = now - loan.dueDate.millisecondsSinceEpoch;
            final delayDays = (delayMs / (1000 * 60 * 60 * 24)).floor();
            score -= 10.0; // Base penalty
            score -= (delayDays * 2.0); // 2 pts per day delayed
          }
          if (score < 0) score = 0.0;
          scores[loan.personName] = score;
        }
      }
      _trustScores = scores;
      
      _cashForecast = await DBHelper.instance.getCashForecast();
      _categories = await DBHelper.instance.getCategories();
    } catch (e) {
      debugPrint("Error fetching data from local database: $e");
      if (kIsWeb) {
        _wallets = _webDemoWallets();
        _categories = _webDemoCategories();
        _transactions = _webDemoTransactions();
        _loans = [];
        _cashForecast = {'dailyBurnRate': 1200.0, 'daysRemaining': '62.5', 'isCritical': false};
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add standard Transaction
  Future<void> addNewTransaction(TransactionModel tx) async {
    await _secureRepository.addSecureTransaction(tx);
    await refreshAll();
  }

  // Transfer funds internally
  Future<void> makeInternalTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String notes,
  }) async {
    await _secureRepository.makeSecureTransfer(
      fromWalletId: fromWalletId,
      toWalletId: toWalletId,
      amount: amount,
      notes: notes,
    );
    await refreshAll();
  }

  // Create a new Loan
  Future<void> addNewLoan(Loan loan) async {
    await _secureRepository.addSecureLoan(loan);
    await refreshAll();
  }

  // Record Installment Payment
  Future<void> payInstallment({
    required String loanId,
    required String walletId,
    required double amount,
    required String notes,
  }) async {
    await _secureRepository.makeSecureInstallment(
      loanId: loanId,
      walletId: walletId,
      amount: amount,
      notes: notes,
    );
    await refreshAll();
  }

  // Add new wallet
  Future<void> addWallet(Wallet wallet) async {
    await _secureRepository.addSecureWallet(wallet);
    await refreshAll();
  }

  // Delete wallet — returns error string or null on success
  Future<String?> deleteWallet(String id) async {
    final err = await _secureRepository.deleteWallet(id);
    if (err == null) await refreshAll();
    return err;
  }

  // Delete transaction (reverses balance)
  Future<void> deleteTransaction(String txId) async {
    await _secureRepository.deleteTransaction(txId);
    await refreshAll();
  }

  // Delete loan + its installment records
  Future<void> deleteLoan(String loanId) async {
    await _secureRepository.deleteLoan(loanId);
    await refreshAll();
  }

  // Change PIN (re-derives session encryption key)
  Future<void> changePin(String newPin) async {
    await _secureRepository.changePin(newPin);
  }

  // ── Web demo fallback data (used when SQLite WASM unavailable) ────────────
  static List<Wallet> _webDemoWallets() => [
    Wallet(id: 'w1', name: 'Cash Wallet',   type: 'CASH',     balance: 5000,   currency: 'PKR'),
    Wallet(id: 'w2', name: 'HBL Bank',      type: 'BANK',     balance: 120000, currency: 'PKR'),
    Wallet(id: 'w3', name: 'Easypaisa',     type: 'DIGITAL',  balance: 15000,  currency: 'PKR'),
    Wallet(id: 'w4', name: 'Emerge Nexus',  type: 'BUSINESS', balance: 450000, currency: 'PKR'),
  ];

  static List<Map<String, dynamic>> _webDemoCategories() => [
    {'id': 'c1', 'name': 'Food & Dining',       'icon': 'fastfood',     'type': 'EXPENSE', 'context': 'PERSONAL'},
    {'id': 'c2', 'name': 'Rent & Bills',         'icon': 'home',         'type': 'EXPENSE', 'context': 'PERSONAL'},
    {'id': 'c3', 'name': 'Salary',               'icon': 'work',         'type': 'INCOME',  'context': 'PERSONAL'},
    {'id': 'c4', 'name': 'Shopping',             'icon': 'shopping_bag', 'type': 'EXPENSE', 'context': 'PERSONAL'},
    {'id': 'c5', 'name': 'Client Payment',       'icon': 'payments',     'type': 'INCOME',  'context': 'BUSINESS'},
    {'id': 'c6', 'name': 'Marketing & Ads',      'icon': 'campaign',     'type': 'EXPENSE', 'context': 'BUSINESS'},
    {'id': 'c7', 'name': 'Hosting & Software',   'icon': 'dns',          'type': 'EXPENSE', 'context': 'BUSINESS'},
    {'id': 'c8', 'name': 'Freelancer Payout',    'icon': 'people',       'type': 'EXPENSE', 'context': 'BUSINESS'},
    {'id': 'c9', 'name': 'Miscellaneous',        'icon': 'category',     'type': 'EXPENSE', 'context': 'BOTH'},
  ];

  static List<TransactionModel> _webDemoTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(id: 't1', walletId: 'w3', type: 'INCOME',  amount: 85000,  categoryId: 'c5', tags: 'client', priority: 'HIGH',   date: now.subtract(const Duration(days: 1)), notes: 'Nexus Project Payment'),
      TransactionModel(id: 't2', walletId: 'w1', type: 'EXPENSE', amount: 1200,   categoryId: 'c1', tags: 'food',   priority: 'LOW',    date: now.subtract(const Duration(days: 1)), notes: 'Dinner at Kolachi'),
      TransactionModel(id: 't3', walletId: 'w2', type: 'INCOME',  amount: 150000, categoryId: 'c3', tags: 'salary', priority: 'HIGH',   date: now.subtract(const Duration(days: 3)), notes: 'Monthly Salary'),
      TransactionModel(id: 't4', walletId: 'w2', type: 'EXPENSE', amount: 45000,  categoryId: 'c2', tags: 'rent',   priority: 'HIGH',   date: now.subtract(const Duration(days: 3)), notes: 'House Rent May'),
      TransactionModel(id: 't5', walletId: 'w4', type: 'EXPENSE', amount: 12000,  categoryId: 'c6', tags: 'ads',    priority: 'MEDIUM', date: now.subtract(const Duration(days: 4)), notes: 'Meta Ads Campaign'),
      TransactionModel(id: 't6', walletId: 'w1', type: 'EXPENSE', amount: 3500,   categoryId: 'c4', tags: 'shop',   priority: 'LOW',    date: now.subtract(const Duration(days: 5)), notes: 'Clothing Centaurus'),
      TransactionModel(id: 't7', walletId: 'w4', type: 'EXPENSE', amount: 8500,   categoryId: 'c7', tags: 'hosting', priority: 'MEDIUM', date: now.subtract(const Duration(days: 6)), notes: 'AWS + Vercel Monthly'),
      TransactionModel(id: 't8', walletId: 'w3', type: 'INCOME',  amount: 25000,  categoryId: 'c5', tags: 'client', priority: 'MEDIUM', date: now.subtract(const Duration(days: 7)), notes: 'UI Design Project'),
    ];
  }
}
