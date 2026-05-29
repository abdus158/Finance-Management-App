import '../repositories/wallet_repository.dart';

class TransferFunds {
  final WalletRepository repository;

  TransferFunds(this.repository);

  Future<void> call({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError("Transfer amount must be strictly greater than zero.");
    }
    await repository.transferFunds(
      fromWalletId: fromWalletId,
      toWalletId: toWalletId,
      amount: amount,
      notes: notes,
    );
  }
}
