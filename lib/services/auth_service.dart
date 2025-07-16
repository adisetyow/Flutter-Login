// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import 'dart:developer';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan user saat ini
  User? get currentUser => _auth.currentUser;

  // Stream untuk memantau perubahan state autentikasi
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mendapatkan user model dari Firestore
  Future<UserModel?> getCurrentUserModel() async {
    if (currentUser == null) return null;

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(currentUser!.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      log('Error getting user data: $e');
      return null;
    }
  }

  Future<User?> registerWithEmail({
    required String namaLengkap,
    required String email,
    required String password,
    required String jabatan,
  }) async {
    try {
      // Daftar akun ke Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Tentukan role berdasarkan jabatan
        UserRole role;

        switch (jabatan.toLowerCase()) {
          case 'ketua':
          case 'bendahara':
          case 'sekretaris':
            role = UserRole.admin;
            break;
          case 'anggota':
            role = UserRole.user;
            break;
          default:
            role = UserRole.user; // fallback jika jabatan tidak dikenal
        }

        // Simpan ke Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'namaLengkap': namaLengkap,
          'email': email,
          'jabatan': jabatan,
          'role': role.name, // simpan sebagai string
          'createdAt': Timestamp.now(),
        });
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUserApproved(String uid) async {
    // Misal ambil dari Firestore
    return true;
  }

  Future<String> getUserRole(String uid) async {
    // Ambil role dari database
    return 'user';
  }

  // Mendapatkan role user saat ini
  Future<UserRole> getCurrentUserRole() async {
    UserModel? user = await getCurrentUserModel();
    return user?.role ?? UserRole.user;
  }

  // Login dengan email dan password
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Logout
  Future<void> signOut() {
    return _auth.signOut();
  }

  // Registrasi user baru (hanya untuk SuperAdmin)
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required String jabatan,
    required UserRole role, // Menggunakan enum UserRole
    String? position,
  }) async {
    // Cek apakah current user adalah superadmin
    UserRole currentRole = await getCurrentUserRole();
    if (role != UserRole.user && currentRole != UserRole.superadmin) {
      throw Exception('Hanya SuperAdmin yang dapat membuat akun Admin');
    }

    // Buat user di Firebase Auth
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Buat data user di Firestore
    UserModel newUser = UserModel(
      uid: result.user!.uid,
      email: email,
      name: name,
      jabatan: jabatan,
      role: role,
      position: position,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(result.user!.uid)
        .set(newUser.toMap());

    return newUser;
  }
}
