import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_colors.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final transactionProvider = context.read<TransactionProvider>();
      final budgetProvider = context.read<BudgetProvider>();

      transactionProvider.loadAll(); // pastikan ada method ini di provider
      budgetProvider.loadBudgets(); // memanggil ulang agar data tidak kosong
    });
  }

  String formatCurrency(double amount) {
    final s = amount.toStringAsFixed(0);
    return 'Rp' + s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Map<String, double> _getExpensesByCategory(List<TransactionModel> items) {
    final Map<String, double> map = {};
    for (var t in items) {
      if (t.type == TransactionType.expense) {
        final cat = t.category;
        map[cat] = (map[cat] ?? 0) + t.amount;
      }
    }
    return map;
  }

  List<Map<String, double>> _getMonthlyFlow(List<TransactionModel> items) {
    final Map<String, Map<String, double>> grouped = {}; // key: YYYY-MM
    for (var t in items) {
      final d = t.date;
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => {'income': 0.0, 'expense': 0.0});
      if (t.type == TransactionType.income) {
        grouped[key]!['income'] = grouped[key]!['income']! + t.amount;
      } else {
        grouped[key]!['expense'] = grouped[key]!['expense']! + t.amount;
      }
    }

    final sortedKeys = grouped.keys.toList()..sort();
    final keysToUse = sortedKeys.length > 4 ? sortedKeys.sublist(sortedKeys.length - 4) : sortedKeys;
    final result = <Map<String, double>>[];
    for (var k in keysToUse) {
      result.add({
        'income': grouped[k]!['income'] ?? 0.0,
        'expense': grouped[k]!['expense'] ?? 0.0,
      });
    }
    return result;
  }

  void _showEditBudgetDialog(BuildContext context, BudgetProvider budgetProvider) {
    String selectedCategory = budgetProvider.budgets.isNotEmpty ? budgetProvider.budgets.first.category : '';
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Atur Anggaran'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (budgetProvider.budgets.isNotEmpty)
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCategory = val);
                    },
                    items: budgetProvider.budgets.map((b) {
                      return DropdownMenuItem(value: b.category, child: Text(b.category));
                    }).toList(),
                  ),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Batas Anggaran (Rp)'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () async {
                  final text = controller.text.replaceAll('.', '').replaceAll(',', '');
                  final value = double.tryParse(text);
                  if (value != null) {
                    // jika kategori sudah ada, update; kalau tidak ada, tambahkan
                    final existing = budgetProvider.budgets.firstWhere(
                          (b) => b.category == selectedCategory,
                      orElse: () => Budget(id: null, category: selectedCategory, limitAmount: value),
                    );

                    if (existing.id == null && !budgetProvider.budgets.any((b) => b.category == selectedCategory)) {
                      await budgetProvider.addBudget(Budget(category: selectedCategory, limitAmount: value));
                    } else {
                      final updated = Budget(id: existing.id, category: selectedCategory, limitAmount: value);
                      await budgetProvider.updateBudget(updated);
                    }
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);

    if (transactionProvider.loading || budgetProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final transactions = transactionProvider.items; // pastikan provider mu memakai "items"
    final budgets = budgetProvider.budgets;

    final expensesByCategory = _getExpensesByCategory(transactions);
    final monthlyFlow = _getMonthlyFlow(transactions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Analisis & Anggaran', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          // Budget Section
          Text('Anggaran Bulan Ini', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          const SizedBox(height: 10),
          ...budgets.map((b) {
            final spent = expensesByCategory[b.category] ?? 0.0;
            final percentage = b.limitAmount > 0 ? (spent / b.limitAmount) : 0.0;
            Color barColor;
            if (percentage < 0.5) barColor = AppColors.incomeGreen;
            else if (percentage < 0.85) barColor = Colors.orange;
            else barColor = AppColors.expenseRed;

            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Card(
                color: AppColors.primaryPink.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: percentage.clamp(0.0, 1.0).toDouble(),
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation(barColor),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Terpakai: ${formatCurrency(spent)}', style: const TextStyle(fontSize: 12)),
                          Text('Batas: ${formatCurrency(b.limitAmount)}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showEditBudgetDialog(context, budgetProvider),
              child: Text('Kelola Anggaran ➡️', style: TextStyle(color: AppColors.darkText)),
            ),
          ),
          const SizedBox(height: 30),

          // Monthly Flow Chart (income vs expense)
          _buildMonthlyFlowChart(monthlyFlow),

          const SizedBox(height: 30),

          // Category Pie Chart
          _buildCategoryExpenseChart(expensesByCategory),
        ],
      ),
    );
  }

  Widget _buildMonthlyFlowChart(List<Map<String, double>> monthlyFlow) {
    if (monthlyFlow.isEmpty) return const Text('Belum ada data aliran dana');

    double maxY = 0;
    for (var m in monthlyFlow) {
      maxY = [maxY, m['income'] ?? 0.0, m['expense'] ?? 0.0].reduce((a, b) => a > b ? a : b);
    }
    maxY *= 1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Aliran Dana Bulanan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 250,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.accentGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
          child: BarChart(
            BarChartData(
              maxY: maxY <= 0 ? 1.0 : maxY,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false), // jangan pakai const
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final idx = value.toInt();
                      final labels = List.generate(monthlyFlow.length, (i) => (i + 1).toString());
                      if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                      return SideTitleWidget(meta: meta, child: Text(labels[idx]));
                    },
                    reservedSize: 32,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    interval: maxY / 5,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final label = 'Rp${(value / 1000000).toStringAsFixed(1)}J';
                      return SideTitleWidget(meta: meta, child: Text(label, style: const TextStyle(fontSize: 10)));
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: monthlyFlow.asMap().entries.map((entry) {
                final idx = entry.key;
                final m = entry.value;
                return BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(toY: m['income'] ?? 0.0, color: AppColors.incomeGreen, width: 14, borderRadius: BorderRadius.circular(4)),
                    BarChartRodData(toY: m['expense'] ?? 0.0, color: AppColors.expenseRed, width: 14, borderRadius: BorderRadius.circular(4)),
                  ],
                  barsSpace: 4,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryExpenseChart(Map<String, double> expensesByCat) {
    final total = expensesByCat.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return const Text('Belum ada data pengeluaran');

    final colors = [Colors.red.shade300, Colors.blue.shade300, Colors.orange.shade300, Colors.purple.shade300, Colors.green.shade300];
    final entries = expensesByCat.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Proporsi Pengeluaran per Kategori', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 300,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primaryPink.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sections: entries.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final cat = entry.value.key;
                      final val = entry.value.value;
                      final perc = val / total * 100;
                      return PieChartSectionData(color: colors[idx % colors.length], value: val, title: '${perc.toStringAsFixed(1)}%', radius: 60, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white));
                    }).toList(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final cat = entry.value.key;
                    return Row(
                      children: [
                        Container(width: 10, height: 10, color: colors[idx % colors.length], margin: const EdgeInsets.only(right: 6)),
                        Text(cat, style: const TextStyle(fontSize: 12)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
