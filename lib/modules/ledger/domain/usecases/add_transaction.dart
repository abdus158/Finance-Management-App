import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  Future<void> call(TransactionEntity transaction) async {
    if (transaction.amount <= 0) {
      throw ArgumentError("Transaction amount must be strictly greater than zero.");
    }
    await repository.addTransaction(transaction);
  }
}
