import 'package:auth/domain/entities/user_session.dart';

class UserProfile extends UserSession {
  UserProfile({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    required super.status,
    required super.isOwner,
    required super.warehouseId,
    required super.warehouseName,
    required super.roles,
    required super.permissions,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      status: json['status'] as String,
      isOwner: json['isOwner'] as bool,
      warehouseId: json['warehouseId'] as int,
      warehouseName: json['warehouseName'] as String,
      roles: (json['roles'] as List<dynamic>).map((e) => e.toString()).toList(),
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }
}
