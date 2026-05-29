import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(TransactionEntity transaction);
  Future<List<TransactionEntity>> getTransactions();
  Future<void> makeTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String notes,
  });
}
