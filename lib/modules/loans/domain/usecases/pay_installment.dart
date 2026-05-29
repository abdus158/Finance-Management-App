import '../repositories/loan_repository.dart';

class PayInstallment {
  final LoanRepository repository;

  PayInstallment(this.repository);

  Future<void> call({
    required String loanId,
    required String walletId,
    required double amount,
    required String notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError("Installment amount must be strictly greater than zero.");
    }
    await repository.payInstallment(
      loanId: loanId,
      walletId: walletId,
      amount: amount,
      notes: notes,
    );
  }
}
