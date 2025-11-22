import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

const List<String> expenseCategories = [
  "Makanan & Minuman",
  "Transportasi",
  "Belanja",
  "Hiburan",
  "Tagihan",
  "Lain-lain",
];

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TransactionProvider>().loadAll();
      context.read<BudgetProvider>().loadBudgets();
    });
  }

  String formatCurrency(double amount) {
    final s = amount.toStringAsFixed(0);
    return "Rp " +
        s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                (match) => "${match[1]}.");
  }

  Map<String, double> _getExpensesByCategory(List<TransactionModel> items) {
    final result = <String, double>{};

    for (var t in items) {
      if (t.type == TransactionType.expense) {
        result[t.category] = (result[t.category] ?? 0) + t.amount;
      }
    }
    return result;
  }

  List<Map<String, double>> _getMonthlyFlow(List<TransactionModel> items) {
    final grouped = <String, Map<String, double>>{};

    for (var t in items) {
      final key = "${t.date.year}-${t.date.month.toString().padLeft(2, "0")}";
      grouped.putIfAbsent(key, () => {"income": 0, "expense": 0});

      if (t.type == TransactionType.income) {
        grouped[key]!["income"] = grouped[key]!["income"]! + t.amount;
      } else {
        grouped[key]!["expense"] = grouped[key]!["expense"]! + t.amount;
      }
    }

    final sortedKeys = grouped.keys.toList()..sort();

    final selected = sortedKeys.length > 4
        ? sortedKeys.sublist(sortedKeys.length - 4)
        : sortedKeys;

    return selected.map((k) => grouped[k]!).toList();
  }

  void _showBudgetDialog(
      BuildContext context,
      BudgetProvider bp,
      TransactionProvider tp, {
        Budget? existing,
      }) {
    final controller = TextEditingController(
        text: existing?.limitAmount.toStringAsFixed(0) ?? "");

    String selectedCategory = existing?.category ?? expenseCategories.first;

    final now = DateTime.now();
    final monthKey = "${now.year}-${now.month.toString().padLeft(2, "0")}";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          title: Text(existing == null ? "Tambah Anggaran" : "Edit Anggaran"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                value: selectedCategory,
                isExpanded: true,
                items: expenseCategories
                    .map((cat) => DropdownMenuItem(
                    value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: "Batas Anggaran (Rp)"),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal")),
            ElevatedButton(
                onPressed: () async {
                  final input = controller.text
                      .replaceAll(".", "")
                      .replaceAll(",", "");

                  final value = double.tryParse(input);
                  if (value == null) return;

                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  if (existing == null) {
                    await bp.addBudget(
                      Budget(
                        userId: user.uid,
                        category: selectedCategory,
                        limitAmount: value,
                        month: monthKey,
                      ),
                    );
                  } else {
                    await bp.updateBudget(
                      Budget(
                        id: existing.id,
                        userId: user.uid,
                        category: selectedCategory,
                        limitAmount: value,
                        month: monthKey,
                      ),
                    );
                  }
                  if (mounted) Navigator.pop(ctx);
                },
                child: const Text("Simpan")),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransactionProvider>();
    final bp = context.watch<BudgetProvider>();

    if (tp.loading || bp.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = DateTime.now();
    final monthKey = "${now.year}-${now.month.toString().padLeft(2, "0")}";

    final budgets = bp.budgets.where((b) => b.month == monthKey).toList();

    final expensesByCategory = _getExpensesByCategory(tp.items);
    final monthlyFlow = _getMonthlyFlow(tp.items);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Analisis & Anggaran",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          Text("Anggaran Bulan Ini ($monthKey)",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 14),

          if (budgets.isEmpty)
            Center(
                child: Text("Belum ada anggaran",
                    style: TextStyle(color: Colors.grey[600])))
          else
            Column(
              children: budgets.map((b) {
                final spent = expensesByCategory[b.category] ?? 0;
                final percentage = spent / b.limitAmount;

                Color color = percentage < .5
                    ? Colors.green
                    : percentage < .85
                    ? Colors.orange
                    : Colors.red;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: Key("budget-${b.id}"),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => bp.deleteBudget(b.id!),
                    child: InkWell(
                      onLongPress: () =>
                          _showBudgetDialog(context, bp, tp, existing: b),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.category,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: percentage.clamp(0, 1),
                                  minHeight: 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                  AlwaysStoppedAnimation(color),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Terpakai: ${formatCurrency(spent)}"),
                                  Text("Batas: ${formatCurrency(b.limitAmount)}"),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () => _showBudgetDialog(context, bp, tp),
              child: const Text("Kelola Anggaran"),
            ),
          ),

          const SizedBox(height: 30),
          const Text("Alur Keuangan 4 Bulan Terakhir",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          _buildMonthlyFlowChart(monthlyFlow),

          const SizedBox(height: 30),
          const Text("Pengeluaran Berdasarkan Kategori",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          _buildCategoryExpenseChart(expensesByCategory),
        ],
      ),
    );
  }

  Widget _buildMonthlyFlowChart(List<Map<String, double>> flow) {
    if (flow.isEmpty) return const Text("Belum ada data transaksi");

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: flow.asMap().entries.map((entry) {
            int i = entry.key;
            double income = entry.value["income"]!;
            double expense = entry.value["expense"]!;
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: income,
                color: Colors.green,
                width: 12,
              ),
              BarChartRodData(
                toY: expense,
                color: Colors.red,
                width: 12,
              ),
            ]);
          }).toList(),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildCategoryExpenseChart(Map<String, double> data) {
    if (data.isEmpty) return const Text("Belum ada pengeluaran");

    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 45,
          sections: data.entries.map((e) {
            return PieChartSectionData(
              title: "${e.key}\n${formatCurrency(e.value)}",
              radius: 65,
            );
          }).toList(),
        ),
      ),
    );
  }
}
