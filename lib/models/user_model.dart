// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String jabatan;
  final UserRole role; // Menggunakan enum UserRole
  final String?
  position; // Untuk Admin: 'ketua', 'wakil', 'bendahara', 'sekretaris', dll.
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.jabatan,
    required this.role,
    this.position,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'jabatan': jabatan,
      'role':
          role.name, // Konversi enum ke string untuk penyimpanan di Firestore
      'position': position,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['namaLengkap'] ?? '',
      jabatan: map['jabatan'] ?? '',
      role: UserRoleExtension.fromString(
        map['role'] ?? 'user',
      ), // Konversi string ke enum
      position: map['position'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
