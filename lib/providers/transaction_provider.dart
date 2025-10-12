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
    _loading = true;
    notifyListeners();

    _items = await _db.getAllTransactions();

    _loading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel t) async {
    await _db.insertTransaction(t);
    await loadAll();
  }

  Future<void> updateTransaction(TransactionModel t) async {
    await _db.updateTransaction(t);
    await loadAll();
  }

  Future<void> removeTransaction(int id) async {
    await _db.deleteTransaction(id);
    await loadAll();
  }
}
