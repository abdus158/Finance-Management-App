import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<List<WalletEntity>> getWallets();
  Future<void> transferFunds({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String notes,
  });
}
