class TransactionModel {
  final String id;
  final String walletId;
  final String type; // INCOME, EXPENSE, TRANSFER
  final double amount;
  final String categoryId;
  final String tags; // Comma-separated tags or JSON list
  final String priority; // LOW, MEDIUM, HIGH
  final DateTime date;
  final String notes;
  final String? linkedTransactionId; // For internal transfers

  TransactionModel({
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'walletId': walletId,
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'tags': tags,
      'priority': priority,
      'date': date.millisecondsSinceEpoch,
      'notes': notes,
      'linkedTransactionId': linkedTransactionId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      walletId: map['walletId'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['categoryId'] as String,
      tags: map['tags'] as String,
      priority: map['priority'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      notes: map['notes'] as String,
      linkedTransactionId: map['linkedTransactionId'] as String?,
    );
  }

  List<String> get tagList => tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
}
