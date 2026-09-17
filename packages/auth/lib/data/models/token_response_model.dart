import 'package:auth/data/models/user_profile.dart';

class TokenResponseModel {
  final String accessToken;
  final String? refreshToken;
  final DateTime? accessTokenExpiresAt;
  final UserProfile user;

  TokenResponseModel({
    required this.accessToken,
    this.refreshToken,
    this.accessTokenExpiresAt,
    required this.user,
  });

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) {
    return TokenResponseModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      accessTokenExpiresAt: json['accessTokenExpiresAt'] != null
          ? DateTime.tryParse(json['accessTokenExpiresAt'] as String)
          : null,
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
