class Wallet {
  final String id;
  final String name;
  final String type; // CASH, BANK, DIGITAL, BUSINESS
  final double balance;
  final String currency;

  Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'currency': currency,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      balance: (map['balance'] as num).toDouble(),
      currency: map['currency'] as String,
    );
  }

  Wallet copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    String? currency,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
    );
  }
}
