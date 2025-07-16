import 'package:get/get.dart';
import 'package:tunas_mandiri/screens/auth/login_screen.dart';
import 'package:tunas_mandiri/screens/auth/register_screen.dart';
import 'package:tunas_mandiri/screens/dashboard/admin_dashboard_screen.dart';
import 'package:tunas_mandiri/screens/dashboard/superadmin_dashboard_screen.dart';
import 'package:tunas_mandiri/screens/dashboard/user_dashboard_screen.dart';
import 'package:tunas_mandiri/screens/keuangan/keuangan_screen.dart';
import 'package:tunas_mandiri/screens/kegiatan/kegiatan_screen.dart';
import 'package:tunas_mandiri/screens/presensi/presensi_screen.dart';

class RouteApp {
  static final routes = [
    GetPage(name: '/', page: () => LoginScreen()),
    GetPage(name: '/register', page: () => RegisterScreen()),
    GetPage(name: '/user_dashboard', page: () => UserDashboardScreen()),
    GetPage(
      name: '/superadmin_dashboard',
      page: () => SuperAdminDashboardScreen(),
    ),
    GetPage(name: '/admin_dashboard', page: () => AdminDashboardScreen()),
    GetPage(name: '/keuangan', page: () => KeuanganScreen()),
    GetPage(name: '/presensi', page: () => PresensiScreen()),
    GetPage(name: '/kegiatan', page: () => KegiatanScreen()),
  ];
}
