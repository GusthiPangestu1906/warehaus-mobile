import 'package:equatable/equatable.dart';

class UserSession extends Equatable {
  final int userId;
  final String name;
  final String email;
  final List<String> roles;
  final List<String> permissions;

  const UserSession({
    required this.userId,
    required this.name,
    required this.email,
    required this.roles,
    required this.permissions,
  });

  bool hasPermission(String permissionCode) =>
      permissions.contains(permissionCode);
  bool hasRole(String roleName) => roles.contains(roleName);

  @override
  List<Object?> get props => [userId, name, email, roles, permissions];
}
