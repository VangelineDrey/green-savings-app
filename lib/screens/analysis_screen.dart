import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_colors.dart';

/// Dummy Data untuk Laporan, Grafik, dan Budget
class DummyData {
  static final Map<String, double> monthlyExpensesByCategory = {
    'Makanan & Minuman': 2300000,
    'Transportasi': 1500000,
    'Belanja': 900000,
    'Tagihan': 1100000,
    'Hiburan': 500000,
  };

  static final List<Map<String, double>> monthlyFlow = [
    {'income': 7000000, 'expense': 4500000}, // Okt-24
    {'income': 8500000, 'expense': 6100000}, // Nov-24
    {'income': 8000000, 'expense': 5000000}, // Des-24
    {'income': 9200000, 'expense': 7500000}, // Jan-25
  ];

  static final List<Map<String, dynamic>> budgets = [
    {'category': 'Makanan & Minuman', 'limit': 3000000.0, 'spent': 2300000.0},
    {'category': 'Transportasi', 'limit': 2000000.0, 'spent': 1500000.0},
    {'category': 'Hiburan', 'limit': 800000.0, 'spent': 500000.0},
  ];
}

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  String formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(0);
    String result = '';
    int counter = 0;
    for (int i = amountStr.length - 1; i >= 0; i--) {
      result = amountStr[i] + result;
      counter++;
      if (counter % 3 == 0 && i != 0) {
        result = '.' + result;
      }
    }
    return 'Rp$result';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analisis & Anggaran',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 20),
          _buildBudgetSection(context),
          const SizedBox(height: 30),
          _buildMonthlyFlowChart(),
          const SizedBox(height: 30),
          _buildCategoryExpenseChart(),
          const SizedBox(height: 30),
          _buildReportSection(context),
        ],
      ),
    );
  }

  // --- BAGIAN 1: ANGGARAN ---
  Widget _buildBudgetSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anggaran Bulan Ini',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
        ),
        const SizedBox(height: 10),
        ...DummyData.budgets.map((budget) {
          final double percentage = budget['spent'] / budget['limit'];
          Color barColor;

          if (percentage < 0.5) {
            barColor = AppColors.incomeGreen;
          } else if (percentage < 0.85) {
            barColor = Colors.orange;
          } else {
            barColor = AppColors.expenseRed;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Card(
              color: AppColors.primaryPink.withOpacity(0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget['category'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: AppColors.darkText),
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: percentage.clamp(0.0, 1.0),
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Terpakai: ${formatCurrency(budget['spent'])}',
                            style: const TextStyle(fontSize: 12)),
                        Text('Batas: ${formatCurrency(budget['limit'])}',
                            style: const TextStyle(fontSize: 12)),
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
            onPressed: () {},
            child: Text('Kelola Anggaran ➡️',
                style: TextStyle(color: AppColors.darkText)),
          ),
        )
      ],
    );
  }

  // --- BAGIAN 2: GRAFIK BAR ---
  Widget _buildMonthlyFlowChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aliran Dana 4 Bulan Terakhir',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
        ),
        const SizedBox(height: 10),
        Container(
          height: 250,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: BarChart(
            BarChartData(
              maxY: 10000000,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final titles = ['Okt', 'Nov', 'Des', 'Jan'];
                      final idx = value.toInt();

                      if (idx < 0 || idx >= titles.length) return const SizedBox.shrink();

                      return SideTitleWidget(
                        meta: meta, // ✅ Tambahkan ini!
                        child: Text(
                          titles[idx],
                          style: TextStyle(
                            color: AppColors.darkText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                    reservedSize: 32,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    interval: 2000000,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final label = 'Rp${(value / 1000000).toInt()}J';
                      return SideTitleWidget(
                        meta: meta, // ✅ Tambahkan juga di sini
                        child: Text(
                          label,
                          style: TextStyle(
                            color: AppColors.darkText,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: DummyData.monthlyFlow.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, double> data = entry.value;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data['income']!,
                      color: AppColors.incomeGreen,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: data['expense']!,
                      color: AppColors.expenseRed,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
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

  // --- BAGIAN 3: PIE CHART ---
  Widget _buildCategoryExpenseChart() {
    final totalExpense = DummyData.monthlyExpensesByCategory.values.fold(0.0, (a, b) => a + b);
    final categoryEntries = DummyData.monthlyExpensesByCategory.entries.toList();

    List<PieChartSectionData> showingSections() {
      int i = -1;
      return DummyData.monthlyExpensesByCategory.entries.map((entry) {
        i++;
        final value = entry.value;
        final percentage = (value / totalExpense) * 100;

        return PieChartSectionData(
          color: [
            Colors.red.shade300,
            Colors.blue.shade300,
            Colors.purple.shade300,
            Colors.orange.shade300,
            Colors.pink.shade300
          ][i % 5],
          value: value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          titlePositionPercentageOffset: 0.6,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proporsi Pengeluaran per Kategori',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
        ),
        const SizedBox(height: 10),
        Container(
          height: 300,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryPink.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sections: showingSections(),
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
                  children: categoryEntries.asMap().entries.map((entry) {
                    int index = entry.key;
                    MapEntry<String, double> item = entry.value;

                    return Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          color: [
                            Colors.red.shade300,
                            Colors.blue.shade300,
                            Colors.purple.shade300,
                            Colors.orange.shade300,
                            Colors.pink.shade300
                          ][index % 5],
                          margin: const EdgeInsets.only(right: 5),
                        ),
                        Text(item.key, style: const TextStyle(fontSize: 12)),
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

  // --- BAGIAN 4: LAPORAN ---
  Widget _buildReportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Laporan Keuangan',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: Icon(Icons.picture_as_pdf, color: AppColors.expenseRed),
          title: const Text('Laporan Bulan Januari 2025 (PDF)'),
          trailing: Icon(Icons.download, color: AppColors.darkText),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Simulasi: Membuat Laporan PDF...')),
            );
          },
          tileColor: AppColors.primaryPink.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: Icon(Icons.table_chart, color: AppColors.incomeGreen),
          title: const Text('Ekspor Data Transaksi (CSV)'),
          trailing: Icon(Icons.download, color: AppColors.darkText),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Simulasi: Mengekspor Data CSV...')),
            );
          },
          tileColor: AppColors.primaryPink.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ],
    );
  }
}
