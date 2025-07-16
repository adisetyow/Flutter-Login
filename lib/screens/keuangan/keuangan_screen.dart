import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../models/dashboard_models.dart';

class KeuanganScreen extends StatelessWidget {
  const KeuanganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final List<FinancialData> financialData = [
      FinancialData('Kas Desa', 5000000, 3500000),
      FinancialData('Jimpitan', 2000000, 1500000),
      FinancialData('17-an', 3000000, 2800000),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Keuangan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SfCartesianChart(
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
              primaryXAxis: CategoryAxis(),
              series: <CartesianSeries<FinancialData, String>>[
                BarSeries<FinancialData, String>(
                  dataSource: financialData,
                  xValueMapper: (FinancialData data, _) => data.month,
                  yValueMapper: (FinancialData data, _) => data.income,
                  name: 'Pemasukan',
                  color: Colors.green,
                ),
                BarSeries<FinancialData, String>(
                  dataSource: financialData,
                  xValueMapper: (FinancialData data, _) => data.month,
                  yValueMapper: (FinancialData data, _) => data.expense,
                  name: 'Pengeluaran',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
