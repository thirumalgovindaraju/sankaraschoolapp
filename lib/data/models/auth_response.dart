// lib/data/models/auth_response.dart

import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;

  AuthResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      accessToken: json['access_token'] ?? json['token'],
      refreshToken: json['refresh_token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user?.toJson(),
    };
  }

  AuthResponse copyWith({
    bool? success,
    String? message,
    String? accessToken,
    String? refreshToken,
    UserModel? user,
  }) {
    return AuthResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }
}