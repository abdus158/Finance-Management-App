class Loan {
  final String id;
  final String personName;
  final String type; // PAYABLE (we owe them), RECEIVABLE (they owe us)
  final double principalAmount;
  final double remainingAmount;
  final DateTime dueDate;
  final String status; // ACTIVE, PAID, DEFAULTED

  Loan({
    required this.id,
    required this.personName,
    required this.type,
    required this.principalAmount,
    required this.remainingAmount,
    required this.dueDate,
    required this.status,
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

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'] as String,
      personName: map['personName'] as String,
      type: map['type'] as String,
      principalAmount: (map['principalAmount'] as num).toDouble(),
      remainingAmount: (map['remainingAmount'] as num).toDouble(),
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int),
      status: map['status'] as String,
    );
  }

  Loan copyWith({
    String? id,
    String? personName,
    String? type,
    double? principalAmount,
    double? remainingAmount,
    DateTime? dueDate,
    String? status,
  }) {
    return Loan(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      type: type ?? this.type,
      principalAmount: principalAmount ?? this.principalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }
}

class LoanInstallment {
  final String id;
  final String loanId;
  final String transactionId;
  final double amount;
  final DateTime date;

  LoanInstallment({
    required this.id,
    required this.loanId,
    required this.transactionId,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loanId': loanId,
      'transactionId': transactionId,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory LoanInstallment.fromMap(Map<String, dynamic> map) {
    return LoanInstallment(
      id: map['id'] as String,
      loanId: map['loanId'] as String,
      transactionId: map['transactionId'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    );
  }
}
