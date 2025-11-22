import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_colors.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../screens/transaction_edit_screen.dart';
import '../services/auth_service.dart';
import '../widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    await _currentUser.reload();
    if (mounted) {
      setState(() {
        _currentUser = FirebaseAuth.instance.currentUser!;
      });
    }
  }

  // Format angka ke Rupiah
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final transactions = provider.items;

    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    double totalBalance = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await provider.fetchTransactions();
            await _refreshUserData();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 25),
                  child: _buildSavingsCard(
                    totalBalance: totalBalance,
                    totalIncome: totalIncome,
                    totalExpense: totalExpense,
                  ),
                ),
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

                      // LIST ITEM
                      ...transactions.map(
                            (t) => Dismissible(
                          key: ValueKey(t.id),
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            padding: const EdgeInsets.only(left: 20),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditTransactionScreen(transaction: t),
                              ),
                            );
                            return false;
                          },
                          child: TransactionCard(
                            transaction: t,
                            onEdit: (transaction) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditTransactionScreen(
                                    transaction: transaction,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: const BoxDecoration(
        color: AppColors.babypink,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    '${_currentUser.displayName ?? "User"}!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // LOGOUT BUTTON
          GestureDetector(
            onTap: () async => await AuthService().logout(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.grey,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BALANCE CARD =================

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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAmountRow('Income', totalIncome, Colors.green,
                  Icons.arrow_downward),
              _buildAmountRow('Expenses', totalExpense, Colors.redAccent,
                  Icons.arrow_upward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
      String label, double amount, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              formatCurrency(amount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}