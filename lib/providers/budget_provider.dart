import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/db_helper.dart';
import '../models/budget.dart';

// Provider untuk mengelola data anggaran (budget)
// dan komunikasi dengan database (fetch, insert, update, delete)
class BudgetProvider with ChangeNotifier {
  final DbHelper dbHelper = DbHelper();

  // Data anggaran yang disimpan di memory
  List<Budget> _budgets = [];
  bool _loading = false;

  // Getter untuk data anggaran dan status loading
  List<Budget> get budgets => _budgets;
  bool get loading => _loading;

  // Getter untuk mengambil User ID dari Firebase Auth
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // Konstruktor opsional: bisa dipanggil untuk auto-load
  BudgetProvider() {
    loadBudgets();
  }

  // Fungsi untuk mengambil semua data anggaran dari database
  Future<void> loadBudgets() async {
    // Jika user belum login, kosongkan data
    if (_userId.isEmpty) {
      _budgets = [];
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      // Ambil data berdasarkan userId
      _budgets = await dbHelper.getBudgetsByUser(_userId);
    } catch (e) {
      print("❌ Error loadBudgets: $e");
      _budgets = [];
    }

    _loading = false;
    notifyListeners();
  }

  // Fungsi untuk menambahkan anggaran baru ke database
  Future<void> addBudget(Budget budget) async {
    try {
      await dbHelper.insertBudget(budget); // Simpan ke SQLite
      await loadBudgets(); // Refresh data setelah insert
    } catch (e) {
      print("❌ Error addBudget: $e");
      rethrow;
    }
  }

  // Fungsi untuk mengupdate anggaran yang sudah ada
  Future<void> updateBudget(Budget budget) async {
    try {
      await dbHelper.updateBudget(budget); // Update data di SQLite
      await loadBudgets(); // Refresh data setelah update
    } catch (e) {
      print("❌ Error updateBudget: $e");
      rethrow;
    }
  }

  // Fungsi untuk menghapus anggaran berdasarkan ID
  Future<void> deleteBudget(int id) async {
    try {
      await dbHelper.deleteBudget(id); // Hapus dari SQLite
      await loadBudgets(); // Refresh data setelah delete
    } catch (e) {
      print("❌ Error deleteBudget: $e");
      rethrow;
    }
  }
}
