import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserData data;

  const HomeScreen({super.key, required this.data});

  // 🔹 Format angka ke Rupiah
  String formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(0);
    String result = '';
    int counter = 0;
    for (int i = amountStr.length - 1; i >= 0; i--) {
      result = amountStr[i] + result;
      counter++;
      if (counter % 3 == 0 && i != 0) result = '.$result';
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    if (provider.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final transactions = provider.items;

    // 🔹 Hitung total income, expense, dan balance
    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else if (t.type == TransactionType.expense) {
        totalExpense += t.amount;
      }
    }

    double totalBalance = totalIncome - totalExpense;

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
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
                        Image.asset('images/profile.png', height: 70),
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
                            Text(
                              '${data.name}!',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // ...
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          // 🔹 Ketika logout ditekan → kembali ke LoginScreen
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginRegisterScreen()),
                                (Route<dynamic> route) => false, // Hapus semua route sebelumnya
                          );
                        },
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Colors.grey,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 CARD TOTAL BALANCE
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                child: _buildSavingsCard(
                  totalBalance: totalBalance,
                  totalIncome: totalIncome,
                  totalExpense: totalExpense,
                ),
              ),

              // 🔹 LIST TRANSAKSI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...transactions
                        .map((t) => _buildTransactionTile(t))
                        .toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Widget Card Balance (dengan Income & Expenses)
  Widget _buildSavingsCard({
    required double totalBalance,
    required double totalIncome,
    required double totalExpense,
  }) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryPink, AppColors.peach],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(totalBalance),
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 🔹 Income & Expense
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Income
              Row(
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: AppColors.incomeGreen,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Income', style: TextStyle(fontSize: 12)),
                      Text(
                        formatCurrency(totalIncome),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              // Expenses
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  children: [
                    Container(
                      height: 24,
                      width: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Expenses', style: TextStyle(fontSize: 12)),
                        Text(
                          formatCurrency(totalExpense),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 Widget item transaksi
  Widget _buildTransactionTile(TransactionModel t) {
    // 🔹 Dapatkan ikon dan warna berdasarkan kategori
    final Map<String, dynamic> iconData = _getIconForCategory(t);

    return Container(
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
          // 🔹 Icon kategori
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

          // 🔹 Deskripsi dan tanggal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.category,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // 🔹 Jumlah
          Text(
            (t.type == TransactionType.income ? '+ ' : '- ') +
                formatCurrency(t.amount),
            style: TextStyle(
              color: t.type == TransactionType.income
                  ? Colors.green
                  : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Tentukan ikon dan warna berdasarkan kategori dan tipe transaksi
  Map<String, dynamic> _getIconForCategory(TransactionModel t) {
    IconData icon;
    Color color;

    if (t.type == TransactionType.income) {
      color = Colors.green;
      if (t.category.toLowerCase().contains('gaji') ||
          t.category.toLowerCase().contains('salary')) {
        icon = Icons.attach_money;
      } else if (t.category.toLowerCase().contains('bonus')) {
        icon = Icons.card_giftcard;
      } else if (t.category.toLowerCase().contains('investasi')) {
        icon = Icons.trending_up;
      } else {
        icon = Icons.account_balance_wallet;
      }
    } else {
      color = Colors.redAccent;
      if (t.category.toLowerCase().contains('makan') ||
          t.category.toLowerCase().contains('minum')) {
        icon = Icons.fastfood;
      } else if (t.category.toLowerCase().contains('transport')) {
        icon = Icons.directions_car;
      } else if (t.category.toLowerCase().contains('hiburan')) {
        icon = Icons.movie;
      } else if (t.category.toLowerCase().contains('belanja')) {
        icon = Icons.shopping_bag;
      } else {
        icon = Icons.money_off;
      }
    }

    return {'icon': icon, 'color': color};
  }
}
