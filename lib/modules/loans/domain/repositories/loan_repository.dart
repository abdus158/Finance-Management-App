import '../entities/loan_entity.dart';

abstract class LoanRepository {
  Future<List<LoanEntity>> getLoans();
  Future<void> addLoan(LoanEntity loan);
  Future<void> payInstallment({
    required String loanId,
    required String walletId,
    required double amount,
    required String notes,
  });
  Future<Map<String, double>> fetchTrustScores();
}
