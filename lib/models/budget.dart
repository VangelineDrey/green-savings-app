class Budget {
  final int? id;
  final String category;
  final double limitAmount;

  Budget({this.id, required this.category, required this.limitAmount});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'category': category,
      'limitAmount': limitAmount,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id'].toString()),
      category: map['category'] as String,
      limitAmount: (map['limitAmount'] as num).toDouble(),
    );
  }
}
