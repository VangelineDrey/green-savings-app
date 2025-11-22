import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/transaction.dart';
import 'dart:collection';


// Provider untuk mengelola data transaksi dan komunikasi dengan database
class TransactionProvider extends ChangeNotifier {
  final DbHelper _db = DbHelper(); // Inisialisasi helper database SQLite
  List<TransactionModel> _items = []; // List transaksi yang tersimpan
  bool _loading = true; // Status loading untuk UI

  // Getter untuk akses data transaksi dan status loading
  UnmodifiableListView<TransactionModel> get items => UnmodifiableListView(_items);
  // Getter untuk status loading
  bool get loading => _loading;

  // Constructor: langsung load semua data saat provider dibuat
  TransactionProvider() {
    loadAll();
    _items.sort((a, b) => b.date.compareTo(a.date));
  }

  // Fungsi untuk mengambil semua data transaksi dari database
  Future<void> loadAll() async {
    print('🔄 [TransactionProvider] loadAll() start');
    _loading = true;
    notifyListeners();

    try {
      // Mengambil data dari SQLite
      _items = await _db.getAllTransactions();
      print('✅ [TransactionProvider] loaded ${_items.length} transactions');
    } catch (e, st) {
      print('❌ [TransactionProvider] error in loadAll: $e');
      print(st);
      _items = [];
    }

    _loading = false;
    notifyListeners();
    print('🔵 [TransactionProvider] loadAll() finished');
  }

  // Fungsi untuk menambahkan transaksi baru ke database
  Future<void> addTransaction(TransactionModel t) async {
    final id = await _db.insertTransaction(t);
    // Masukkan ke list dengan ID auto-increment
    _items.add(t.copyWith(id: id));
    notifyListeners();
  }

  // Update transaksi tertentu berdasarkan ID
  Future<void> updateTransaction(TransactionModel updated) async {
    // Update data ke SQLite
    await _db.updateTransaction(updated);

    // Update data di list
    final index = _items.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      // Update data dengan data terbaru
      _items[index] = updated;
      notifyListeners();
    }
  }

  // Hapus transaksi berdasarkan ID
  Future<void> deleteTransaction(int id) async {
    // Hapus dari SQLite
    await _db.deleteTransaction(id);
    // Hapus dari list
    _items.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
