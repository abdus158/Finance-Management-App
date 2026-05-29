class LoanEntity {
  final String id;
  final String personName;
  final String type; // PAYABLE (we owe), RECEIVABLE (they owe)
  final double principalAmount;
  final double remainingAmount;
  final DateTime dueDate;
  final String status; // ACTIVE, PAID, DEFAULTED

  LoanEntity({
    required this.id,
    required this.personName,
    required this.type,
    required this.principalAmount,
    required this.remainingAmount,
    required this.dueDate,
    required this.status,
  });
}
