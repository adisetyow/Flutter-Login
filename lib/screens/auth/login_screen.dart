import 'package:flutter/material.dart';
import 'package:tunas_mandiri/models/user_role.dart';
import 'package:tunas_mandiri/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tunas_mandiri/utils/validation_util.dart';
import 'package:tunas_mandiri/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Login Firebase Auth
        UserCredential userCredential = await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Cek status persetujuan
        bool isApproved = await _authService.isUserApproved(
          userCredential.user!.uid,
        );
        if (!isApproved) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Akun Anda belum disetujui. Silakan tunggu persetujuan dari admin.';
          });
          await _authService.signOut();
          return;
        }

        // Ambil data user dari Firestore
        UserModel? userModel = await _authService.getCurrentUserModel();

        if (userModel == null) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Data pengguna tidak ditemukan.';
          });
          await _authService.signOut();
          return;
        }

        // Arahkan ke dashboard berdasarkan role
        switch (userModel.role) {
          case UserRole.superadmin:
            Get.offAllNamed('/superadmin_dashboard');
            break;
          case UserRole.admin:
            Get.offAllNamed('/admin_dashboard');
            break;
          case UserRole.user:
            Get.offAllNamed('/user_dashboard');
            break;
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
          if (e.code == 'user-not-found') {
            _errorMessage = 'Email tidak terdaftar.';
          } else if (e.code == 'wrong-password') {
            _errorMessage = 'Password salah.';
          } else {
            _errorMessage = 'Gagal login: ${e.message}';
          }
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
        });
      }
    }
  }

  // Future<void> _login() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _isLoading = true;
  //       _errorMessage = '';
  //     });

  //     try {
  //       // Lakukan login menggunakan Firebase Auth
  //       UserCredential userCredential = await FirebaseAuth.instance
  //           .signInWithEmailAndPassword(
  //             email: _emailController.text.trim(),
  //             password: _passwordController.text,
  //           );

  //       // Cek apakah akun telah disetujui (jika perlu)
  //       bool isApproved = await _authService.isUserApproved(
  //         userCredential.user!.uid,
  //       );

  //       if (!isApproved) {
  //         setState(() {
  //           _isLoading = false;
  //           _errorMessage =
  //               'Akun Anda belum disetujui. Silakan tunggu persetujuan dari admin.';
  //         });
  //         await _authService.signOut();
  //         return;
  //       }

  //       // Arahkan ke dashboard pengguna
  //       Get.offAllNamed('/user_dashboard');
  //     } on FirebaseAuthException catch (e) {
  //       setState(() {
  //         _isLoading = false;
  //         if (e.code == 'user-not-found') {
  //           _errorMessage = 'Email tidak terdaftar.';
  //         } else if (e.code == 'wrong-password') {
  //           _errorMessage = 'Password salah.';
  //         } else {
  //           _errorMessage = 'Gagal login: ${e.message}';
  //         }
  //       });
  //     } catch (e) {
  //       setState(() {
  //         _isLoading = false;
  //         _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo atau ilustrasi
                  Icon(
                    Icons.account_balance,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),

                  // Judul
                  Text(
                    'Remaja Tunas Mandiri',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) => ValidationUtil.validateEmail(value!),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator:
                        (value) => ValidationUtil.validatePassword(value!),
                  ),
                  const SizedBox(height: 8),

                  // Lupa Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed('/forgot_password');
                      },
                      child: const Text('Lupa Password?'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red.shade100,
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade900),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text('MASUK'),
                  ),
                  const SizedBox(height: 16),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum punya akun?'),
                      TextButton(
                        onPressed: () {
                          Get.toNamed('/register');
                        },
                        child: const Text('Daftar Sekarang'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
