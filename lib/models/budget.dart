class Budget {
  final int? id;
  final String category;
  final double limitAmount;
  final String month;

  Budget({
    this.id,
    required this.category,
    required this.limitAmount,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'limitAmount': limitAmount,
      'month': month,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      limitAmount: map['limitAmount'] is int
          ? (map['limitAmount'] as int).toDouble()
          : map['limitAmount'],
      month: map['month'],
    );
  }
}
