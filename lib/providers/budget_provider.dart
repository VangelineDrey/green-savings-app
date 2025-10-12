import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/budget.dart';

class BudgetProvider with ChangeNotifier {
  final DbHelper dbHelper = DbHelper(); // gunakan DbHelper, bukan DatabaseHelper

  List<Budget> _budgets = [];
  List<Budget> get budgets => _budgets;

  bool _loading = true;
  bool get loading => _loading;

  BudgetProvider() {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    _loading = true;
    notifyListeners();

    _budgets = await dbHelper.getBudgets();
    _loading = false;
    notifyListeners();
  }

  Future<void> addBudget(Budget budget) async {
    await dbHelper.insertBudget(budget);
    await loadBudgets();
  }

  Future<void> updateBudget(Budget budget) async {
    await dbHelper.updateBudget(budget);
    await loadBudgets();
  }

  Future<void> deleteBudget(int id) async {
    await dbHelper.deleteBudget(id);
    await loadBudgets();
  }
}
