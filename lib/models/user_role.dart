// lib/models/user_role.dart
enum UserRole { user, admin, superadmin }

// Extension untuk memudahkan konversi antara enum dan string
extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.admin:
        return 'admin';
      case UserRole.superadmin:
        return 'superadmin';
      // ignore: unreachable_switch_default
      default:
        return 'user';
    }
  }

  // Metode statis untuk mendapatkan enum dari string
  static UserRole fromString(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'superadmin':
        return UserRole.superadmin;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}
