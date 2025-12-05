// lib/data/models/auth_response.dart
// ✅ UPDATED: Added approval-specific response handling

import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;
  // ✅ NEW: Approval status flag (Line 11)
  final bool? isApprovalPending;

  AuthResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
    // ✅ NEW: Add to constructor (Line 20)
    this.isApprovalPending,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      accessToken: json['access_token'] ?? json['token'],
      refreshToken: json['refresh_token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      // ✅ NEW: Parse approval pending flag (Line 32)
      isApprovalPending: json['approval_pending'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user?.toJson(),
      // ✅ NEW: Include in JSON (Line 44)
      'approval_pending': isApprovalPending,
    };
  }

  AuthResponse copyWith({
    bool? success,
    String? message,
    String? accessToken,
    String? refreshToken,
    UserModel? user,
    // ✅ NEW: Add to copyWith (Line 55)
    bool? isApprovalPending,
  }) {
    return AuthResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      // ✅ NEW: Include in copyWith return (Line 65)
      isApprovalPending: isApprovalPending ?? this.isApprovalPending,
    );
  }

  // ✅ NEW: Factory constructors for common approval scenarios (Lines 69-109)
  factory AuthResponse.pendingApproval({
    required String email,
    required UserRole role,
  }) {
    return AuthResponse(
      success: false,
      message: '🕐 Your account is pending admin approval.\n\n'
          'Email: $email\n'
          'Role: ${role.name.toUpperCase()}\n\n'
          'You will receive an email notification once your account is approved.\n\n'
          'Please contact the school administrator if you have any questions.',
      isApprovalPending: true,
    );
  }

  factory AuthResponse.rejected({
    required String email,
    String? reason,
  }) {
    return AuthResponse(
      success: false,
      message: '❌ Your account registration has been rejected.\n\n'
          'Email: $email\n'
          '${reason != null ? 'Reason: $reason\n\n' : ''}'
          'Please contact the school administrator for more information.',
      isApprovalPending: false,
    );
  }

  factory AuthResponse.registrationSuccess({
    required String email,
    required UserRole role,
  }) {
    return AuthResponse(
      success: true,
      message: '✅ Registration Successful!\n\n'
          'Your account has been created and is pending admin approval.\n\n'
          'Email: $email\n'
          'Role: ${role.name.toUpperCase()}\n\n'
          'You will receive a notification once approved.',
      isApprovalPending: true,
    );
  }
}