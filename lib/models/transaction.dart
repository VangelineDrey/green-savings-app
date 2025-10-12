enum TransactionType { income, expense }

class TransactionModel {
  final int? id;
  final String description;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'type': type == TransactionType.income ? 1 : 0,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> m) {
    return TransactionModel(
      id: m['id'] as int?,
      description: m['description'] as String,
      amount: (m['amount'] as num).toDouble(),
      category: m['category'] as String,
      type: (m['type'] as int) == 1
          ? TransactionType.income
          : TransactionType.expense,
      date: DateTime.parse(m['date'] as String),
    );
  }
}
