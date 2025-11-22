import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/db_helper.dart';
import '../models/transaction.dart';
import 'dart:collection';

// Provider untuk mengelola data transaksi dan komunikasi dengan database
class TransactionProvider extends ChangeNotifier {
  final DbHelper _db = DbHelper(); // Inisialisasi helper database SQLite
  List<TransactionModel> _items = []; // List transaksi yang tersimpan
  bool _loading = false; // Status loading untuk UI

  // Getter untuk akses data transaksi (read-only) dan status loading
  UnmodifiableListView<TransactionModel> get items => UnmodifiableListView(_items);
  bool get loading => _loading;

  // Ambil User ID dari Firebase Auth
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // Constructor: langsung load semua data saat provider dibuat
  TransactionProvider() {
    loadAll();
  }

  // Fungsi untuk mengambil semua data transaksi dari database
  Future<void> loadAll() async {
    // Jika user belum login, kosongkan data
    if (_userId.isEmpty) {
      _items = [];
      notifyListeners();
      return;
    }

    print('🔄 [TransactionProvider] Loading data for UserID: $_userId');
    _loading = true;
    notifyListeners();

    try {
      // Ambil data HANYA milik user yang sedang login
      _items = await _db.getTransactionsByUser(_userId);
      // Sort transaksi terbaru di atas
      _items.sort((a, b) => b.date.compareTo(a.date));
      print('✅ [TransactionProvider] Loaded ${_items.length} transactions');
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
    try {
      final id = await _db.insertTransaction(t); // Simpan ke SQLite
      // Masukkan ke list dengan ID auto-increment
      _items.add(t.copyWith(id: id));
      // Sort ulang agar urutan tetap benar
      _items.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      print('❌ addTransaction error: $e');
      rethrow;
    }
  }

  // Fungsi untuk mengupdate transaksi yang sudah ada
  Future<void> updateTransaction(TransactionModel updated) async {
    try {
      await _db.updateTransaction(updated);

      final index = _items.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
        _items[index] = updated;
        // Sort ulang
        _items.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    } catch (e) {
      print('❌ updateTransaction error: $e');
      rethrow;
    }
  }

  // Fungsi untuk menghapus transaksi berdasarkan ID
  Future<void> deleteTransaction(int id) async {
    try {
      await _db.deleteTransaction(id);
      _items.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      print('❌ deleteTransaction error: $e');
      rethrow;
    }
  }
}