import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tunas_mandiri/models/user_model.dart';
import 'package:tunas_mandiri/services/auth_service.dart';
import '/models/dashboard_models.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM y', 'id_ID').format(now);

    // Sample data
    final List<FinancialData> financialChartData = [
      FinancialData('Jan', 3500000, 2800000),
      FinancialData('Feb', 4200000, 3100000),
      FinancialData('Mar', 3800000, 2900000),
      FinancialData('Apr', 4500000, 3200000),
      FinancialData('Mei', 5000000, 3500000),
    ];

    final List<UpcomingEvent> upcomingEvents = [
      UpcomingEvent(
        'Persiapan 17 Agustus',
        '10 Agustus 2023',
        'Balai Desa',
        Icons.flag,
        Colors.red,
      ),
      UpcomingEvent(
        'Rapat Evaluasi',
        '15 Agustus 2023',
        'Kantor Desa',
        Icons.groups,
        Colors.blue,
      ),
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sistem Informasi Desa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Tunas Mandiri',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 1,
        actions: [_buildNotificationButton(context), const SizedBox(width: 8)],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Add refresh logic here
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FutureBuilder untuk mengambil data User
                FutureBuilder<UserModel?>(
                  future: AuthService().getCurrentUserModel(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Text('Tidak ada data pengguna');
                    } else {
                      // Mengambil data pengguna yang login
                      final user = snapshot.data!;
                      if (user.name.isEmpty) {
                        return Text('Nama pengguna tidak tersedia');
                      }
                      return Text(
                        'Selamat datang, ${user.name}', // Nama pengguna yang login
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                // Date Header
                FutureBuilder<UserModel?>(
                  future: AuthService().getCurrentUserModel(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return _buildDateHeader(
                        formattedDate,
                        isDarkMode,
                        'Warga',
                      );
                    }

                    final user = snapshot.data!;
                    return _buildDateHeader(
                      formattedDate,
                      isDarkMode,
                      user.jabatan,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Quick Stats
                _buildQuickStats(isDarkMode),
                const SizedBox(height: 24),

                // Financial Chart
                _buildFinancialChart(context, financialChartData, isDarkMode),
                const SizedBox(height: 24),

                // Upcoming Events
                _buildUpcomingEvents(context, upcomingEvents, isDarkMode),
                const SizedBox(height: 24),

                // Footer
                _buildFooter(isDarkMode),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, isDarkMode),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: const Text(
              '3',
              style: TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(String date, bool isDarkMode, String jabatan) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          date,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green[800],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            jabatan,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '5',
            'Pengumuman Baru',
            Colors.orange[600]!,
            Icons.campaign,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '2',
            'Laporan Baru',
            Colors.blue[600]!,
            Icons.description,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '3',
            'Kegiatan',
            Colors.green[600]!,
            Icons.event,
            isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color color,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialChart(
    BuildContext context,
    List<FinancialData> data,
    bool isDarkMode,
  ) {
    final totalIncome = data.fold(0, (sum, item) => sum + item.income);
    final totalExpense = data.fold(0, (sum, item) => sum + item.expense);
    final balance = totalIncome - totalExpense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Grafik Keuangan Desa',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, size: 20),
              onPressed: () {
                _showFinancialInfo(context);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: CategoryAxis(
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      numberFormat: NumberFormat.compactCurrency(
                        symbol: 'Rp',
                        decimalDigits: 0,
                      ),
                      labelStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    legend: Legend(
                      isVisible: true,
                      textStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      position: LegendPosition.bottom,
                    ),
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      format: 'Rp point.y',
                    ),
                    series: <CartesianSeries>[
                      ColumnSeries<FinancialData, String>(
                        name: 'Pemasukan',
                        dataSource: data,
                        xValueMapper: (FinancialData data, _) => data.month,
                        yValueMapper: (FinancialData data, _) => data.income,
                        color: Colors.green[600],
                        width: 0.6,
                        spacing: 0.2,
                      ),
                      ColumnSeries<FinancialData, String>(
                        name: 'Pengeluaran',
                        dataSource: data,
                        xValueMapper: (FinancialData data, _) => data.month,
                        yValueMapper: (FinancialData data, _) => data.expense,
                        color: Colors.red[600],
                        width: 0.6,
                        spacing: 0.2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildFinancialSummary(
                  totalIncome,
                  totalExpense,
                  balance,
                  isDarkMode,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummary(
    int income,
    int expense,
    int balance,
    bool isDarkMode,
  ) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryItem(
          'Pemasukan',
          formatCurrency.format(income),
          Colors.green[600]!,
          isDarkMode,
        ),
        _buildSummaryItem(
          'Pengeluaran',
          formatCurrency.format(expense),
          Colors.red[600]!,
          isDarkMode,
        ),
        _buildSummaryItem(
          'Saldo',
          formatCurrency.format(balance),
          Colors.blue[600]!,
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    Color color,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showFinancialInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Informasi Keuangan'),
            content: const Text(
              'Data keuangan desa diperbarui setiap akhir bulan. '
              'Grafik menampilkan perbandingan pemasukan dan pengeluaran '
              'dalam 5 bulan terakhir.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Mengerti'),
              ),
            ],
          ),
    );
  }

  Widget _buildUpcomingEvents(
    BuildContext context,
    List<UpcomingEvent> events,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kegiatan Mendatang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/activities');
              },
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ...events.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildEventItem(context, event, isDarkMode),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/presence');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text(
                    'Presensi Kegiatan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(
    BuildContext context,
    UpcomingEvent event,
    bool isDarkMode,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/event-detail');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: event.color.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(event.icon, color: event.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      event.date,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      event.location,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDarkMode) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Aplikasi Sistem Informasi Desa Tunas Mandiri',
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Adi Setyo Wenang',
          style: TextStyle(
            fontSize: 8,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Versi 1.0.0',
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  // Di bagian _buildBottomNavBar:
  Widget _buildBottomNavBar(BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Presensi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_outlined),
              activeIcon: Icon(Icons.attach_money),
              label: 'Keuangan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Kegiatan',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: Colors.green[800],
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          elevation: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                // Tetap di dashboard
                break;
              case 1:
                Get.toNamed('/presensi'); // Gunakan GetX navigation
                break;
              case 2:
                Get.toNamed('/keuangan'); // Gunakan GetX navigation
                break;
              case 3:
                Get.toNamed('/kegiatan'); // Gunakan GetX navigation
                break;
            }
          },
        ),
      ),
    );
  }
}
