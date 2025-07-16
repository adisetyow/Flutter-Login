import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart'; // Import GetX untuk routing
import 'firebase_options.dart'; // auto-generated file saat Firebase init
import 'routes/route_app.dart'; // Import file routes yang telah dibuat
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Menggunakan GetMaterialApp dari GetX
      title: 'Tunas Mandiri',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/', // Halaman awal setelah aplikasi dimulai
      getPages: RouteApp.routes, // Menggunakan route yang sudah dibuat
    );
  }
}
