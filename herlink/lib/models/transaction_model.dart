class Transaction {
  final String id;
  final double amount;
  final String status;
  final String type;
  final String provider;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.amount,
    required this.status,
    required this.type,
    required this.provider,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      status: json['status'] ?? 'UNKNOWN',
      type: json['type'] ?? 'payment',
      provider: json['provider'] ?? 'Telebirr',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}
