import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'models/transaction.dart';
import 'screens/home_screen.dart';
import 'screens/transaction_entry_screen.dart';
import 'screens/analysis_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const PiggyFlowApp(),
    ),
  );
}

class PiggyFlowApp extends StatelessWidget {
  const PiggyFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Savings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryPink,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Montserrat',
        useMaterial3: true,
      ),
      home: const LoginRegisterScreen(), // halaman awal login
    );
  }
}

// ✅ Tambahkan agar bisa menerima data user dari login
class MainScreen extends StatefulWidget {
  final UserData userData; // ✅ ambil data user dari login

  const MainScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  late final List<Widget> _screens; // pakai late karena butuh widget.userData

  @override
  void initState() {
    super.initState();
    // ✅ kirim data user ke HomeScreen
    _screens = [
      const Placeholder(),
      HomeScreen(data: widget.userData),
      const AnalysisScreen(),
    ];
  }

  void _showTransactionChoice(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Catat Apa?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.arrow_circle_up,
                    color: AppColors.incomeGreen, size: 30),
                title: const Text(
                  'Pemasukan (Revenue)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                tileColor: AppColors.incomeGreen.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showTransactionEntry(context, TransactionType.income);
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.arrow_circle_down,
                    color: AppColors.expenseRed, size: 30),
                title: const Text(
                  'Pengeluaran (Expense)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                tileColor: AppColors.expenseRed.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showTransactionEntry(context, TransactionType.expense);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTransactionEntry(BuildContext context, TransactionType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => TransactionEntryScreen(initialType: type),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      _showTransactionChoice(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: PiggyBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
