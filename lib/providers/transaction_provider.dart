import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final DbHelper _db = DbHelper();
  List<TransactionModel> _items = [];
  bool _loading = true;

  List<TransactionModel> get items => _items;
  bool get loading => _loading;

  TransactionProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    print('🔄 [TransactionProvider] loadAll() start');
    _loading = true;
    notifyListeners();

    try {
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

  Future<void> addTransaction(TransactionModel t) async {
    try {
      await _db.insertTransaction(t);
      await loadAll();
    } catch (e) {
      print('❌ addTransaction error: $e');
    }
  }

  Future<void> updateTransaction(TransactionModel t) async {
    try {
      await _db.updateTransaction(t);
      await loadAll();
    } catch (e) {
      print('❌ updateTransaction error: $e');
    }
  }

  Future<void> removeTransaction(int id) async {
    try {
      await _db.deleteTransaction(id);
      await loadAll();
    } catch (e) {
      print('❌ removeTransaction error: $e');
    }
  }
}
