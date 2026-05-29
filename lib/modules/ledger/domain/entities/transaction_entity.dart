class TransactionEntity {
  final String id;
  final String walletId;
  final String type; // INCOME, EXPENSE, TRANSFER
  final double amount;
  final String categoryId;
  final String tags;
  final String priority; // LOW, MEDIUM, HIGH
  final DateTime date;
  final String notes;
  final String? linkedTransactionId;

  TransactionEntity({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.tags,
    required this.priority,
    required this.date,
    required this.notes,
    this.linkedTransactionId,
  });
}
