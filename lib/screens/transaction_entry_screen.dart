import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../models/transaction.dart';

// Dummy list kategori
final List<String> expenseCategories = [
  'Makanan & Minuman', 'Transportasi', 'Belanja', 'Hiburan', 'Tagihan', 'Lain-lain'
];
final List<String> incomeCategories = [
  'Gaji', 'Bonus', 'Investasi', 'Hadiah', 'Lain-lain'
];

class TransactionEntryScreen extends StatefulWidget {
  final TransactionType initialType;

  const TransactionEntryScreen({Key? key, required this.initialType}) : super(key: key);

  @override
  State<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends State<TransactionEntryScreen> {
  late TransactionType _type;
  late String _selectedCategory;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _selectedCategory = _type == TransactionType.income ? incomeCategories.first : expenseCategories.first;
  }

  List<String> get currentCategories => _type == TransactionType.income ? incomeCategories : expenseCategories;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPink, // Kembali ke Primary Pink
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0 || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah atau Deskripsi tidak valid.')),
      );
      return;
    }

    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: _descController.text,
      amount: amount,
      category: _selectedCategory,
      type: _type,
      date: _selectedDate,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${newTransaction.type == TransactionType.income ? "Pemasukan" : "Pengeluaran"} ${newTransaction.amount.toStringAsFixed(0)} dicatat!')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _type == TransactionType.expense ? 'Catat Pengeluaran' : 'Catat Pemasukan',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              Icon(
                _type == TransactionType.income ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                color: _type == TransactionType.income ? AppColors.incomeGreen : AppColors.expenseRed,
                size: 30,
              )
            ],
          ),
          const SizedBox(height: 15),

          // Input Jumlah
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah (Rp)',
              prefixText: 'Rp',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 15),

          // Input Deskripsi
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: 'Deskripsi / Catatan',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 15),

          // Pemilih Kategori (Fitur 2)
          Wrap(
            spacing: 8.0,
            children: currentCategories.map((category) {
              final isSelected = _selectedCategory == category;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: AppColors.accentGreen, // Kembali ke Accent Green
                backgroundColor: AppColors.primaryPink.withOpacity(0.5), // Kembali ke Primary Pink
                labelStyle: TextStyle(
                    color: isSelected ? AppColors.darkText : AppColors.darkText.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategory = category;
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 15),

          // Pemilih Tanggal
          ListTile(
            title: Text('Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            trailing: const Icon(Icons.calendar_today, color: AppColors.darkText),
            onTap: () => _selectDate(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            tileColor: AppColors.primaryPink.withOpacity(0.3), // Kembali ke Primary Pink
          ),
          const SizedBox(height: 20),

          // Tombol Simpan
          ElevatedButton(
            onPressed: _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: _type == TransactionType.expense ? AppColors.expenseRed : AppColors.incomeGreen,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              'Simpan Transaksi',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}