import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../models/transaction.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserData data; // ✅ Tambah properti nama user

  HomeScreen({super.key, required this.data});

  // Fungsi helper format Rupiah
  String formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(0);
    String result = '';
    int counter = 0;
    for (int i = amountStr.length - 1; i >= 0; i--) {
      result = amountStr[i] + result;
      counter++;
      if (counter % 3 == 0 && i != 0) result = '.' + result;
    }
    return 'Rp ' + result;
  }

  // Dummy Data
  final List<Transaction> dummyTransactions = [
    Transaction(
      id: 't1',
      description: 'Gaji Bulanan',
      amount: 8500000,
      category: 'Salaries',
      type: TransactionType.income,
      date: DateTime(2025, 10, 1),
    ),
    Transaction(
      id: 't2',
      description: 'Makan Siang',
      amount: 45500,
      category: 'Food & Beverages',
      type: TransactionType.expense,
      date: DateTime(2025, 10, 10),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 🔹 HEADER
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: const BoxDecoration(
                  color: AppColors.babypink,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('images/Logo.png', height: 70),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            const Text(
                              "Welcome",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black45,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            // ✅ tampilkan nama dari register
                            Text(
                              '${data.name} !',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 CARD & SECTION LAIN
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: _buildSavingsCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsCard() {
    const double totalBalance = 4800000.00;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryPink, AppColors.blushpink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatCurrency(totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
