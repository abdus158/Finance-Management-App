import '../../../../core/security/secure_repository.dart';
import '../../../../core/database/db_helper.dart';
import '../models/wallet_model.dart';

abstract class WalletLocalDataSource {
  Future<List<WalletModel>> fetchWallets();
  Future<void> makeTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String notes,
  });
}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  final SecureRepository secureRepository;
  final DBHelper dbHelper = DBHelper.instance;

  WalletLocalDataSourceImpl(this.secureRepository);

  @override
  Future<List<WalletModel>> fetchWallets() async {
    final rawWallets = await dbHelper.getAllWallets();
    return rawWallets.map((w) {
      return WalletModel(
        id: w.id,
        name: w.name,
        type: w.type,
        balance: w.balance,
        currency: w.currency,
      );
    }).toList();
  }

  @override
  Future<void> makeTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String notes,
  }) async {
    await secureRepository.makeSecureTransfer(
      fromWalletId: fromWalletId,
      toWalletId: toWalletId,
      amount: amount,
      notes: notes,
    );
  }
}
