import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../app_colors.dart';

// Halaman untuk edit data transaksi
class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  // Controller untuk input data
  late TextEditingController descriptionController;
  late TextEditingController amountController;

  // Data transaksi yang akan diedit
  late DateTime selectedDate;
  late String selectedCategory;
  late TransactionType selectedType;

  // kategori contoh — bisa disesuaikan
  final List<String> categories = [
    'Makanan & Minuman',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Tagihan',
    'Lain-lain',
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi data transaksi yang akan diedit
    descriptionController =
        TextEditingController(text: widget.transaction.description);
    amountController =
        TextEditingController(text: widget.transaction.amount.toString());

    selectedDate = widget.transaction.date;
    selectedCategory = widget.transaction.category;
    selectedType = widget.transaction.type;
  }

  @override
  // Membersihkan controller saat widget dihapus
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // Untuk memilih tanggal transaksi dengan datepicker
  Future<void> pickDate() async {
    DateTime? result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() => selectedDate = result);
    }
  }

  // Update transaksi
  void saveTransaction() {
    final provider = context.read<TransactionProvider>();

    // Validasi input
    if (descriptionController.text.isEmpty ||
        amountController.text.isEmpty ||
        double.tryParse(amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields correctly"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Buat objek transaksi baru dengan nilai yang diperbarui
    final updated = TransactionModel(
      id: widget.transaction.id,
      description: descriptionController.text,
      amount: double.parse(amountController.text),
      category: selectedCategory,
      date: selectedDate,
      type: selectedType,
    );

    // Update transaksi di database
    provider.updateTransaction(updated);

    // Snackbar data berhasil diupdate
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Transaction updated successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    // Kembali ke halaman sebelumnya
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Transaction",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryPink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input deskripsi
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Input jumlah uang
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Dropdown kategori
            DropdownButtonFormField(
              value: selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedCategory = value!);
              },
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Switch income vs expense
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Transaction Type",
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: selectedType == TransactionType.income,
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.redAccent,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value
                          ? TransactionType.income
                          : TransactionType.expense;
                    });
                  },
                ),
                Text(
                  selectedType == TransactionType.income
                      ? "Income"
                      : "Expense",
                  style: TextStyle(
                    color: selectedType == TransactionType.income
                        ? Colors.green
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Date picker
            GestureDetector(
              onTap: pickDate,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_month),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
