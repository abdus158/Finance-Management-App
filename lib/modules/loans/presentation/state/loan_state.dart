import 'package:flutter/material.dart';
import '../../domain/entities/loan_entity.dart';
import '../../domain/usecases/get_loans.dart';
import '../../domain/usecases/pay_installment.dart';
import '../../domain/repositories/loan_repository.dart';

class LoanState extends ChangeNotifier {
  final GetLoans getLoansUseCase;
  final PayInstallment payInstallmentUseCase;
  final LoanRepository repository; // For custom actions

  List<LoanEntity> _loans = [];
  Map<String, double> _trustScores = {};
  bool _isLoading = false;
  String? _errorMessage;

  LoanState({
    required this.getLoansUseCase,
    required this.payInstallmentUseCase,
    required this.repository,
  });

  List<LoanEntity> get loans => _loans;
  Map<String, double> get trustScores => _trustScores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetches decrypted loans securely through usecases
  Future<void> loadLoans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _loans = await getLoansUseCase();
      _trustScores = await repository.fetchTrustScores();
    } catch (e) {
      _errorMessage = "Failed to load loans: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adds a secure, encrypted loan
  Future<void> addNewLoan(LoanEntity loan) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.addLoan(loan);
      await loadLoans();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Records installment securely (updates loan status, transaction table, wallet balance)
  Future<void> executeInstallment({
    required String loanId,
    required String walletId,
    required double amount,
    required String notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await payInstallmentUseCase(
        loanId: loanId,
        walletId: walletId,
        amount: amount,
        notes: notes,
      );
      await loadLoans(); // reload to refresh remaining balances
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
