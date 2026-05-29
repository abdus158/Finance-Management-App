class WalletEntity {
  final String id;
  final String name;
  final String type; // CASH, BANK, DIGITAL, BUSINESS
  final double balance;
  final String currency;

  WalletEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
  });
}
