import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tunas_mandiri/models/presensi_model.dart';

class PresensiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Membuat sesi presensi baru dengan status terbuka
  Future<void> createNewPresensiSession() async {
    final now = DateTime.now();
    await _firestore.collection('presensi_sessions').add({
      'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
      'isOpen': true,
      'totalPresensi': 0,
      'createdAt': Timestamp.now(),
    });
  }

  // Mengubah status presensi (buka/tutup)
  Future<void> togglePresensiStatus(bool newStatus) async {
    final currentSession = await _getCurrentPresensiSession();
    if (currentSession != null) {
      await _firestore
          .collection('presensi_sessions')
          .doc(currentSession.id)
          .update({'isOpen': newStatus});
    }
  }

  // Mendapatkan status presensi saat ini
  Future<bool> getCurrentPresensiStatus() async {
    final session = await _getCurrentPresensiSession();
    return session?.isOpen ?? false;
  }

  // Menambahkan presensi
  Future<void> addPresensi({
    required String userId,
    required String userName,
  }) async {
    final now = DateTime.now();
    final currentSession = await _getCurrentPresensiSession();

    if (currentSession != null) {
      await _firestore.collection('presensi').add({
        'userId': userId,
        'userName': userName,
        'timestamp': Timestamp.now(),
        'sessionDate': Timestamp.fromDate(
          DateTime(now.year, now.month, now.day),
        ),
      });

      // Update total presensi
      await _firestore
          .collection('presensi_sessions')
          .doc(currentSession.id)
          .update({'totalPresensi': FieldValue.increment(1)});
    }
  }

  // Mendapatkan daftar presensi hari ini
  Future<List<Presensi>> getTodayPresensi() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final query =
        await _firestore
            .collection('presensi')
            .where(
              'sessionDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where(
              'sessionDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
            )
            .orderBy('timestamp', descending: true)
            .get();

    return query.docs.map((doc) => Presensi.fromFirestore(doc)).toList();
  }

  // Mendapatkan semua sesi presensi
  Future<List<PresensiSession>> getAllPresensiSessions() async {
    final query =
        await _firestore
            .collection('presensi_sessions')
            .orderBy('date', descending: true)
            .get();

    return query.docs.map((doc) => PresensiSession.fromFirestore(doc)).toList();
  }

  // Menghapus presensi
  Future<void> deletePresensi(String presensiId) async {
    await _firestore.collection('presensi').doc(presensiId).delete();
  }

  // Helper: Mendapatkan sesi presensi saat ini
  Future<PresensiSession?> _getCurrentPresensiSession() async {
    final now = DateTime.now();
    final query =
        await _firestore
            .collection('presensi_sessions')
            .where(
              'date',
              isEqualTo: Timestamp.fromDate(
                DateTime(now.year, now.month, now.day),
              ),
            )
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      return PresensiSession.fromFirestore(query.docs.first);
    }
    return null;
  }
}
