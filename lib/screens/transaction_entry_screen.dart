import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

final List<String> expenseCategories = [
  'Makanan & Minuman',
  'Transportasi',
  'Belanja',
  'Hiburan',
  'Tagihan',
  'Lain-lain'
];
final List<String> incomeCategories = [
  'Gaji',
  'Bonus',
  'Investasi',
  'Hadiah',
  'Lain-lain'
];

class TransactionEntryScreen extends StatefulWidget {
  final TransactionType initialType;

  const TransactionEntryScreen({Key? key, required this.initialType})
      : super(key: key);

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
    _selectedCategory = _type == TransactionType.income
        ? incomeCategories.first
        : expenseCategories.first;
  }

  List<String> get currentCategories =>
      _type == TransactionType.income ? incomeCategories : expenseCategories;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPink,
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTransaction() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0 || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah atau Deskripsi tidak valid.')),
      );
      return;
    }

    final newTransaction = TransactionModel(
      description: _descController.text,
      amount: amount,
      category: _selectedCategory,
      type: _type,
      date: _selectedDate,
    );

    final provider = context.read<TransactionProvider>();
    await provider.addTransaction(newTransaction);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_type == TransactionType.income ? "Pemasukan" : "Pengeluaran"} berhasil disimpan!',
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _type == TransactionType.expense
                    ? 'Catat Pengeluaran'
                    : 'Catat Pemasukan',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              Icon(
                _type == TransactionType.income
                    ? Icons.arrow_circle_up
                    : Icons.arrow_circle_down,
                color: _type == TransactionType.income
                    ? AppColors.incomeGreen
                    : AppColors.expenseRed,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah (Rp)',
              prefixText: 'Rp ',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 15),

          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: 'Deskripsi / Catatan',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 15),

          Wrap(
            spacing: 8.0,
            children: currentCategories.map((category) {
              final isSelected = _selectedCategory == category;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: AppColors.accentGreen,
                backgroundColor:
                AppColors.primaryPink.withOpacity(0.5),
                labelStyle: TextStyle(
                  color: AppColors.darkText,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) _selectedCategory = category;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 15),

          ListTile(
            title: Text(
                'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            trailing:
            const Icon(Icons.calendar_today, color: AppColors.darkText),
            onTap: () => _selectDate(context),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            tileColor: AppColors.primaryPink.withOpacity(0.3),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: _type == TransactionType.expense
                  ? AppColors.expenseRed
                  : AppColors.incomeGreen,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              'Simpan Transaksi',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
