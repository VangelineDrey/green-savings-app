// Enum untuk tipe transaksi: pemasukan atau pengeluaran
enum TransactionType { income, expense }

// Model data untuk transaksi keuangan
class TransactionModel {
  final int? id; // ID transaksi (nullable, karena bisa auto-increment)
  final String description; // Deskripsi atau catatan transaksi
  final double amount; // Jumlah uang
  final String category; // Kategori transaksi (misal: Makanan, Gaji)
  final TransactionType type; // Tipe transaksi (income/expense)
  final DateTime date; // Tanggal transaksi

  // Constructor untuk membuat objek transaksi
  TransactionModel({
    this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  // Konversi objek transaksi ke Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'type': type == TransactionType.income ? 1 : 0, // 1 = income, 0 = expense
      'date': date.toIso8601String(), // Format untuk tanggal
    };
  }

  // Factory constructor untuk membuat objek dari Map (saat ambil dari database)
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

  // Fungsi untuk membuat salinan objek dengan perubahan yang diinginkan
  // copyWith digunakan untuk mempermudah edit transaksi di edit screen
  TransactionModel copyWith({
    int? id,
    String? description,
    double? amount,
    String? category,
    TransactionType? type,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }

}
