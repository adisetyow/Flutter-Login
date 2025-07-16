import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tunas_mandiri/models/presensi_model.dart';
import 'package:tunas_mandiri/models/user_model.dart';
import 'package:tunas_mandiri/models/user_role.dart';
import 'package:tunas_mandiri/services/presensi_service.dart';
import 'package:tunas_mandiri/services/auth_service.dart';

class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  final PresensiService _presensiService = PresensiService();
  final AuthService _authService = AuthService();
  bool isPresensiOpen = true;
  List<Presensi> presensiList = [];
  List<PresensiSession> presensiSessions = [];
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPresensiStatus();
    _loadPresensiData();
    _loadPresensiSessions();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUserData();
    setState(() {
      currentUser = user;
    });
  }

  Future<void> _loadPresensiStatus() async {
    bool status = await _presensiService.getCurrentPresensiStatus();
    setState(() {
      isPresensiOpen = status;
    });
  }

  Future<void> _loadPresensiData() async {
    List<Presensi> data = await _presensiService.getTodayPresensi();
    setState(() {
      presensiList = data;
    });
  }

  Future<void> _loadPresensiSessions() async {
    List<PresensiSession> sessions =
        await _presensiService.getAllPresensiSessions();
    setState(() {
      presensiSessions = sessions;
    });
  }

  Future<void> _togglePresensi() async {
    await _presensiService.togglePresensiStatus(!isPresensiOpen);
    setState(() {
      isPresensiOpen = !isPresensiOpen;
    });
    Get.snackbar(
      'Info',
      isPresensiOpen ? 'Presensi dibuka' : 'Presensi ditutup',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _createNewPresensiSession() async {
    await _presensiService.createNewPresensiSession();
    await _loadPresensiSessions();
    Get.snackbar(
      'Sukses',
      'Sesi presensi baru dibuat',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _deletePresensi(String presensiId) async {
    await _presensiService.deletePresensi(presensiId);
    await _loadPresensiData();
    Get.snackbar(
      'Sukses',
      'Presensi dihapus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isSuperAdmin = currentUser?.role == UserRole.superadmin;

    return DefaultTabController(
      length: isSuperAdmin ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Presensi Kegiatan'),
          actions: [
            if (isSuperAdmin)
              IconButton(
                icon: Icon(isPresensiOpen ? Icons.lock : Icons.lock_open),
                onPressed: _togglePresensi,
                tooltip: isPresensiOpen ? 'Tutup Presensi' : 'Buka Presensi',
              ),
          ],
          bottom:
              isSuperAdmin
                  ? const TabBar(
                    tabs: [
                      Tab(text: 'Daftar Presensi'),
                      Tab(text: 'Sesi Presensi'),
                    ],
                  )
                  : null,
        ),
        floatingActionButton:
            isSuperAdmin
                ? FloatingActionButton(
                  onPressed: _createNewPresensiSession,
                  child: const Icon(Icons.add),
                )
                : null,
        body: TabBarView(
          children: [
            // Tab 1: Daftar Presensi
            Column(
              children: [
                if (!isSuperAdmin && isPresensiOpen) _buildPresensiButton(),
                if (!isSuperAdmin && !isPresensiOpen)
                  _buildPresensiClosedMessage(isDarkMode),
                Expanded(child: _buildPresensiList(isDarkMode, isSuperAdmin)),
              ],
            ),
            // Tab 2: Sesi Presensi (hanya untuk superadmin)
            if (isSuperAdmin) _buildPresensiSessionsList(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildPresensiButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          if (currentUser != null) {
            await _presensiService.addPresensi(
              userId: currentUser!.uid,
              userName: currentUser!.name,
            );
            await _loadPresensiData();
            Get.snackbar(
              'Sukses',
              'Presensi berhasil',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[800],
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'PRESENSI SEKARANG',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPresensiClosedMessage(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.red[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Presensi saat ini ditutup oleh admin',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresensiList(bool isDarkMode, bool isSuperAdmin) {
    if (presensiList.isEmpty) {
      return Center(
        child: Text(
          isSuperAdmin ? 'Belum ada presensi' : 'Anda belum melakukan presensi',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: presensiList.length,
      itemBuilder: (context, index) {
        final presensi = presensiList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text(presensi.userName[0])),
            title: Text(presensi.userName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMM yyyy HH:mm').format(presensi.timestamp),
                ),
                if (isSuperAdmin)
                  Text(
                    'Sesi: ${DateFormat('dd MMM yyyy').format(presensi.sessionDate)}',
                  ),
              ],
            ),
            trailing:
                isSuperAdmin
                    ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePresensi(presensi.id),
                    )
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildPresensiSessionsList(bool isDarkMode) {
    if (presensiSessions.isEmpty) {
      return const Center(child: Text('Belum ada sesi presensi'));
    }

    return ListView.builder(
      itemCount: presensiSessions.length,
      itemBuilder: (context, index) {
        final session = presensiSessions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(DateFormat('EEEE, dd MMMM yyyy').format(session.date)),
            subtitle: Text(
              'Status: ${session.isOpen ? 'Terbuka' : 'Tertutup'}\n'
              'Total Presensi: ${session.totalPresensi}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  session.isOpen ? Icons.lock_open : Icons.lock,
                  color: session.isOpen ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  session.isOpen ? 'Buka' : 'Tutup',
                  style: TextStyle(
                    color: session.isOpen ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            onTap: () {
              // Navigasi ke detail sesi presensi
              // Anda bisa implementasikan ini sesuai kebutuhan
            },
          ),
        );
      },
    );
  }
}
