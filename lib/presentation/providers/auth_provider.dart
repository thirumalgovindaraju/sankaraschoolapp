// lib/presentation/providers/auth_provider.dart
// Updated to use Firebase Auth login method

import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  AuthProvider(this._authService) {
    _initializeAuth();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  // Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      debugPrint('🔄 Initializing AuthProvider...');

      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
        debugPrint('✅ User restored: ${_currentUser?.name} (${_currentUser?.role.name})');
      } else {
        debugPrint('ℹ️ No logged-in user found');
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error initializing auth: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // ============================================================================
  // AUTHENTICATION METHODS
  // ============================================================================

  /// Login with Firebase Auth (recommended method)
  Future<bool> login({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('=== AUTH PROVIDER LOGIN ===');
      debugPrint('Email: $email');
      debugPrint('Role: ${role?.name}');

      // ✅ Use Firebase Auth login method
      final response = await _authService.loginWithFirebaseAuth(
        email: email,
        password: password,
        role: role,
      );

      debugPrint('Login response success: ${response.success}');
      debugPrint('Login response message: ${response.message}');

      if (response.success && response.user != null) {
        _currentUser = response.user;
        _errorMessage = null;

        debugPrint('✅ Login successful!');
        debugPrint('User: ${_currentUser?.name}');
        debugPrint('Role: ${_currentUser?.role.name}');
        debugPrint('Approval: ${_currentUser?.approvalStatus}');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        debugPrint('❌ Login failed: $_errorMessage');

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Login error in provider: $e');
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      debugPrint('=== AUTH PROVIDER REGISTER ===');
      debugPrint('Email: $email');
      debugPrint('Name: $name');
      debugPrint('Role: ${role.name}');

      final response = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        additionalData: additionalData,
      );

      debugPrint('Register response success: ${response.success}');
      debugPrint('Register response message: ${response.message}');

      if (response.success) {
        _errorMessage = response.message;
        debugPrint('✅ Registration successful!');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        debugPrint('❌ Registration failed: $_errorMessage');

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Registration error in provider: $e');
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      debugPrint('=== AUTH PROVIDER LOGOUT ===');

      await _authService.logout();
      _currentUser = null;
      _errorMessage = null;

      debugPrint('✅ Logout successful');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      _errorMessage = 'Logout failed';
      notifyListeners();
    }
  }

  // ============================================================================
  // PASSWORD MANAGEMENT
  // ============================================================================

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (success) {
        _errorMessage = null;
        debugPrint('✅ Password changed successfully');
      } else {
        _errorMessage = 'Failed to change password';
        debugPrint('❌ Password change failed');
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('❌ Change password error: $e');
      _errorMessage = 'An error occurred while changing password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.forgotPassword(email);

      if (result['success']) {
        _errorMessage = null;
        debugPrint('✅ Password reset email sent');
      } else {
        _errorMessage = result['message'];
        debugPrint('❌ Password reset failed: ${result['message']}');
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('❌ Forgot password error: $e');
      _errorMessage = 'An error occurred';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'An error occurred'};
    }
  }

  // ============================================================================
  // PROFILE MANAGEMENT
  // ============================================================================

  /// Update profile
  Future<bool> updateProfile({
    required String name,
    String? phone,
    String? profileImage,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedUser = await _authService.updateProfile(
        name: name,
        phone: phone,
        profileImage: profileImage,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        _errorMessage = null;
        debugPrint('✅ Profile updated successfully');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update profile';
        debugPrint('❌ Profile update failed');

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Update profile error: $e');
      _errorMessage = 'An error occurred while updating profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    try {
      debugPrint('🔄 Refreshing user data...');

      final refreshedUser = await _authService.refreshUserData();

      if (refreshedUser != null) {
        _currentUser = refreshedUser;
        debugPrint('✅ User data refreshed: ${_currentUser?.name}');
        notifyListeners();
      } else {
        debugPrint('⚠️ Failed to refresh user data');
      }
    } catch (e) {
      debugPrint('❌ Error refreshing user data: $e');
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if user has specific role
  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  /// Check if user is admin
  bool get isAdmin => hasRole(UserRole.admin);

  /// Check if user is teacher
  bool get isTeacher => hasRole(UserRole.teacher);

  /// Check if user is student
  bool get isStudent => hasRole(UserRole.student);

  /// Check if user is parent
  bool get isParent => hasRole(UserRole.parent);

  /// Get user's role label
  String get roleLabel {
    switch (_currentUser?.role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
      default:
        return 'Unknown';
    }
  }
}