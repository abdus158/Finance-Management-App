import '../../../../core/security/secure_repository.dart';
import '../../../../models/transaction.dart' as global_model;
import '../models/transaction_model.dart';

abstract class LedgerLocalDataSource {
  Future<void> saveTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> fetchTransactions();
  Future<void> makeTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String notes,
  });
}

class LedgerLocalDataSourceImpl implements LedgerLocalDataSource {
  final SecureRepository secureRepository;

  LedgerLocalDataSourceImpl(this.secureRepository);

  @override
  Future<List<TransactionModel>> fetchTransactions() async {
    final secureTxs = await secureRepository.getDecryptedTransactions();
    return secureTxs.map((tx) {
      return TransactionModel(
        id: tx.id,
        walletId: tx.walletId,
        type: tx.type,
        amount: tx.amount,
        categoryId: tx.categoryId,
        tags: tx.tags,
        priority: tx.priority,
        date: tx.date,
        notes: tx.notes,
        linkedTransactionId: tx.linkedTransactionId,
      );
    }).toList();
  }

  @override
  Future<void> saveTransaction(TransactionModel transaction) async {
    final globalTx = global_model.TransactionModel(
      id: transaction.id,
      walletId: transaction.walletId,
      type: transaction.type,
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      tags: transaction.tags,
      priority: transaction.priority,
      date: transaction.date,
      notes: transaction.notes,
      linkedTransactionId: transaction.linkedTransactionId,
    );
    await secureRepository.addSecureTransaction(globalTx);
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
