import 'package:equatable/equatable.dart';

class UserSession extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String status;
  final bool isOwner;
  final int warehouseId;
  final String warehouseName;
  final List<String> roles;
  final List<String> permissions;

  const UserSession({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.status,
    required this.isOwner,
    required this.warehouseId,
    required this.warehouseName,
    required this.roles,
    required this.permissions,
  });

  bool hasPermission(String permissionCode) =>
      permissions.contains(permissionCode);
  bool hasRole(String roleName) => roles.contains(roleName);

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phoneNumber,
    status,
    isOwner,
    warehouseId,
    warehouseName,
    roles,
    permissions,
  ];
}
