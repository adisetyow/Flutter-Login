import 'package:cloud_firestore/cloud_firestore.dart';

class Presensi {
  final String id;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final DateTime sessionDate;

  Presensi({
    required this.id,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.sessionDate,
  });

  factory Presensi.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Presensi(
      id: doc.id,
      userId: data['userId'],
      userName: data['userName'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      sessionDate: (data['sessionDate'] as Timestamp).toDate(),
    );
  }
}

class PresensiSession {
  final String id;
  final DateTime date;
  final bool isOpen;
  final int totalPresensi;

  PresensiSession({
    required this.id,
    required this.date,
    required this.isOpen,
    required this.totalPresensi,
  });

  factory PresensiSession.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return PresensiSession(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      isOpen: data['isOpen'],
      totalPresensi: data['totalPresensi'],
    );
  }
}
