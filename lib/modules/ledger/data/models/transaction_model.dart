import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    required super.id,
    required super.walletId,
    required super.type,
    required super.amount,
    required super.categoryId,
    required super.tags,
    required super.priority,
    required super.date,
    required super.notes,
    super.linkedTransactionId,
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

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      walletId: entity.walletId,
      type: entity.type,
      amount: entity.amount,
      categoryId: entity.categoryId,
      tags: entity.tags,
      priority: entity.priority,
      date: entity.date,
      notes: entity.notes,
      linkedTransactionId: entity.linkedTransactionId,
    );
  }
}
