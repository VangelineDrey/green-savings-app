import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final Function(TransactionModel)? onEdit;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onEdit,
  });

  // Format angka menjadi Rupiah
  String formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(0);
    String result = '';
    int counter = 0;
    // Menyisipkan titik di setiap 3 angka dari belakang
    for (int i = amountStr.length - 1; i >= 0; i--) {
      result = amountStr[i] + result;
      counter++;
      if (counter % 3 == 0 && i != 0) result = '.$result';
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    // Menampilkan ikon berdasarkan kategori transaksi
    final iconData = _getIconForCategory(transaction);

    return Dismissible(
      // Swipe kanan ke kiri untuk menghapus transaksi
      key: Key(transaction.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),

      // Konfirmasi penghapusan transaksi
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Transaction"),
            content: const Text("Are you sure you want to delete this item?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                child: const Text("Delete"),
                onPressed: () => Navigator.pop(context, true),
              )
            ],
          ),
        );
      },

      // Menghapus transaksi dari SQLite jika disetujui pengguna
      onDismissed: (_) async {
        await provider.deleteTransaction(transaction.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction deleted")),
        );
      },

      // Long press untuk menampilkan halaman edit
      child: GestureDetector(
        onLongPress: () {
          if (onEdit != null) onEdit!(transaction);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: iconData['color'].withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData['icon'], color: iconData['color'], size: 24),
              ),
              const SizedBox(width: 15),

              // Deskripsi & Kategori Transaksi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deskripsi transaksi
                    Text(transaction.description,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    // Kategori transaksi
                    Text(transaction.category,
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),

              // Jumlah transaksi (berbeda warna antara income & expense
              Text(
                (transaction.type == TransactionType.income ? '+ ' : '- ') +
                    formatCurrency(transaction.amount),
                style: TextStyle(
                  color: transaction.type == TransactionType.income
                      ? Colors.green // warna income
                      : Colors.red, // warna expense
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menentukan ikon berdasarkan kategori transaksi
  Map<String, dynamic> _getIconForCategory(TransactionModel t) {
    IconData icon;
    Color color;

    // Jika transaksi berupa income
    if (t.type == TransactionType.income) {
      color = Colors.green;
      if (t.category.toLowerCase().contains('gaji')) icon = Icons.attach_money;
      else if (t.category.toLowerCase().contains('bonus')) icon = Icons.card_giftcard;
      else icon = Icons.account_balance_wallet;
    // Jika transaksi berupa expense
    } else {
      color = Colors.redAccent;
      if (t.category.toLowerCase().contains('makan')) icon = Icons.fastfood;
      else if (t.category.toLowerCase().contains('transport')) icon = Icons.directions_car;
      else if (t.category.toLowerCase().contains('hiburan')) icon = Icons.movie;
      else if (t.category.toLowerCase().contains('belanja')) icon = Icons.shopping_bag;
      else icon = Icons.money_off;
    }

    return {'icon': icon, 'color': color};
  }
}
