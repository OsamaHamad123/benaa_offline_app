import 'package:equatable/equatable.dart';

/// 👤 Auth User Entity - كيان المستخدم المُصادق عليه
class AuthUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role;
  final List<String> roles;
  final List<String> permissions;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role, this.phone,
    this.avatar,
    this.roles = const [],
    this.permissions = const [],
  });

  /// ✅ التحقق من وجود صلاحية
  bool hasPermission(String permission) => permissions.contains(permission);

  /// ✅ التحقق من وجود دور
  bool hasRole(String role) => roles.contains(role);

  /// 🔄 نسخة معدلة
  AuthUser copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? role,
    List<String>? roles,
    List<String>? permissions,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props => [id, email, name, role];
}
