import 'package:flutter/foundation.dart';
import '../data/db_helper.dart';
import '../models/budget.dart';

class BudgetProvider with ChangeNotifier {
  final DbHelper dbHelper = DbHelper();
  List<Budget> _budgets = [];
  bool _loading = true;

  List<Budget> get budgets => _budgets;
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
