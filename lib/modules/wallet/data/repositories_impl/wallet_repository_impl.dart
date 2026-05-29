import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_local_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource localDataSource;

  WalletRepositoryImpl(this.localDataSource);

  @override
  Future<List<WalletEntity>> getWallets() async {
    return await localDataSource.fetchWallets();
  }

  @override
  Future<void> transferFunds({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String notes,
  }) async {
    await localDataSource.makeTransfer(
      fromWalletId: fromWalletId,
      toWalletId: toWalletId,
      amount: amount,
      notes: notes,
    );
  }
}
