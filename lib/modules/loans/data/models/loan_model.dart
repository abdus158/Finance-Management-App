import '../../domain/entities/loan_entity.dart';

class LoanModel extends LoanEntity {
  LoanModel({
    required super.id,
    required super.personName,
    required super.type,
    required super.principalAmount,
    required super.remainingAmount,
    required super.dueDate,
    required super.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'type': type,
      'principalAmount': principalAmount,
      'remainingAmount': remainingAmount,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'status': status,
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'] as String,
      personName: map['personName'] as String,
      type: map['type'] as String,
      principalAmount: (map['principalAmount'] as num).toDouble(),
      remainingAmount: (map['remainingAmount'] as num).toDouble(),
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int),
      status: map['status'] as String,
    );
  }

  factory LoanModel.fromEntity(LoanEntity entity) {
    return LoanModel(
      id: entity.id,
      personName: entity.personName,
      type: entity.type,
      principalAmount: entity.principalAmount,
      remainingAmount: entity.remainingAmount,
      dueDate: entity.dueDate,
      status: entity.status,
    );
  }
}
