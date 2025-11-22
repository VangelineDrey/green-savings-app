import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_colors.dart';
import 'models/transaction.dart'; // Diperlukan untuk Enum TransactionType
import 'screens/home_screen.dart';
import 'screens/transaction_entry_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tangkap error inisialisasi Firebase agar tidak crash silent
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e, st) {
    // Cetak ke console agar terlihat pada flutter run -v
    debugPrint('Firebase.initializeApp() failed: $e');
    debugPrint('$st');
    // Lanjutkan tanpa Firebase supaya UI masih muncul untuk debugging lokal.
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: const LeafyFlowApp(),
    ),
  );
}

// Widget utama aplikasi
class LeafyFlowApp extends StatelessWidget {
  const LeafyFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // fallback color jika AppColors.background ternyata gelap/hitam saat debugging
    final Color bg = AppColors.background;

    return MaterialApp(
      title: 'Green Savings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryPink,
        scaffoldBackgroundColor: bg,
        fontFamily: 'Montserrat',
        useMaterial3: true,
        // Pastikan brightness sesuai (menghindari tema gelap otomatis)
        brightness: Brightness.light,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Pastikan indikator loading kontras terhadap background
            return Scaffold(
              backgroundColor: bg,
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            debugPrint('authStateChanges error: ${snapshot.error}');
            return Scaffold(
              backgroundColor: bg,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Terjadi kesalahan autentikasi:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            );
          }

          // Jika User sudah login
          if (snapshot.hasData) {
            return MainScreen(user: snapshot.data!);
          }

          // Jika belum login
          return const LoginRegisterScreen();
        },
      ),
    );
  }
}

// Menampilkan homeScreen ketika sudah berhasil login
class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; //index 1 : default untuk HomeScreen

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // Load data dari SQLite saat MainScreen dibuat
    Future.microtask(() {
      try {
        context.read<TransactionProvider>().loadAll();
        context.read<BudgetProvider>().loadBudgets();
        debugPrint('Requested loadAll() and loadBudgets()');
      } catch (e, st) {
        debugPrint('Error loading providers: $e');
        debugPrint('$st');
      }
    });

    // daftar halaman berdasarkan index
    _screens = [
      const Placeholder(), // Index 0: Tombol Add
      HomeScreen(user: widget.user), // Index 1: Home
      const AnalysisScreen(), // Index 2: Analysis
      const AIChatScreen(), // Index 3: Halaman Chat AI
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
    // Jika Anda melihat layar hitam, coba ganti sementara menjadi Container(color: Colors.orange)
    return Scaffold(
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      floatingActionButton: _selectedIndex == 3
          ? null
          : FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 3;
          });
        },
        backgroundColor: AppColors.darkGreen,
        child: const Icon(Icons.psychology, color: Colors.white),
        tooltip: 'Tanya Leafy',
      ),
      bottomNavigationBar: LeafyBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}