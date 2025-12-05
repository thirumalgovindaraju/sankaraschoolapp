// lib/data/services/auth_service.dart
// ✅ FIXED VERSION - Corrects method signature issues

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/auth_response.dart';
import 'api_service.dart';
import 'test_data_service.dart';

class AuthService {
  final ApiService _apiService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const bool _useTestData = true; // ✅ CHANGED: Enable test mode by default

  AuthService(this._apiService);

  // ============================================================================
  // AUTHENTICATION METHODS
  // ============================================================================

  /// Login - FIXED VERSION
  Future<AuthResponse> login({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    try {
      debugPrint('=== AUTH SERVICE LOGIN ===');
      debugPrint('Email: $email');
      debugPrint('Role: ${role?.name}');
      debugPrint('Using test data: $_useTestData');

      if (_useTestData) {
        // Load test data
        await TestDataService.instance.loadTestData();

        // ✅ FIX: Get UserModel from test data
        final user = await TestDataService.instance.loginWithTestData(email, password);

        if (user != null) {
          debugPrint('✅ Test user found: ${user.name}');

          // ✅ FIX: Verify role matches if provided
          if (role != null && user.role != role) {
            debugPrint('❌ Role mismatch! Expected: ${role.name}, Got: ${user.role.name}');
            return AuthResponse(
              success: false,
              message: 'Invalid role selected for this account',
            );
          }

          // Check approval status
          if (user.isPending) {
            return AuthResponse.pendingApproval(
              email: email,
              role: user.role,
            );
          }

          if (user.isRejected) {
            return AuthResponse.rejected(email: email);
          }

          if (!user.isApproved) {
            return AuthResponse(
              success: false,
              message: 'Your account status does not allow login. Please contact administration.',
            );
          }

          // Save user data
          await _saveUserData(user);
          await _saveToken('test_token_${user.id}');

          debugPrint('✅ Login successful!');
          return AuthResponse(
            success: true,
            message: 'Login successful',
            user: user,
            accessToken: 'test_token_${user.id}',
          );
        } else {
          debugPrint('❌ Invalid credentials');
          return AuthResponse(
            success: false,
            message: 'Invalid email or password.\n\nTest accounts:\n'
                '• admin@school.com / password123\n'
                '• teacher@school.com / password123\n'
                '• student@school.com / password123\n'
                '• parent@school.com / password123',
          );
        }
      }

      // Production API call
      debugPrint('🌐 Making API call to /auth/login');
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
        if (role != null) 'role': role.name,
      });

      debugPrint('📡 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final user = UserModel.fromJson(data['data']['user']);

          // Check approval status
          if (user.isPending) {
            return AuthResponse.pendingApproval(
              email: email,
              role: user.role,
            );
          }

          if (user.isRejected) {
            return AuthResponse.rejected(email: email);
          }

          final token = data['data']['token'] ?? data['token'];
          await _saveToken(token);
          await _saveUserData(user);

          return AuthResponse(
            success: true,
            message: 'Login successful',
            user: user,
            accessToken: token,
          );
        }

        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Login failed',
        );
      }

      return AuthResponse(
        success: false,
        message: 'Login failed with status code: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('❌ Login error: $e');
      return AuthResponse(
        success: false,
        message: 'An error occurred during login: ${e.toString()}',
      );
    }
  }

  /// Register - FIXED VERSION
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      debugPrint('=== AUTH SERVICE REGISTER ===');
      debugPrint('Email: $email');
      debugPrint('Name: $name');
      debugPrint('Role: ${role.name}');

      if (_useTestData) {
        await TestDataService.instance.loadTestData();

        if (TestDataService.instance.emailExists(email)) {
          debugPrint('❌ Email already exists');
          return AuthResponse(
            success: false,
            message: 'Email already registered. Please login or use a different email.',
          );
        }

        final success = await TestDataService.instance.registerUser(
          email: email,
          password: password,
          name: name,
          phone: phone,
          role: role,
        );

        if (success) {
          debugPrint('✅ Registration successful');
          return AuthResponse.registrationSuccess(
            email: email,
            role: role,
          );
        } else {
          debugPrint('❌ Registration failed');
          return AuthResponse(
            success: false,
            message: 'Registration failed. Please try again.',
          );
        }
      }

      // Production API call
      final response = await _apiService.post('/auth/register', {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        'role': role.name,
        ...?additionalData,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.registrationSuccess(
          email: email,
          role: role,
        );
      }

      final data = json.decode(response.body);
      return AuthResponse(
        success: false,
        message: data['message'] ?? 'Registration failed',
      );
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      return AuthResponse(
        success: false,
        message: 'An error occurred during registration: ${e.toString()}',
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      debugPrint('=== AUTH SERVICE LOGOUT ===');

      if (!_useTestData) {
        try {
          final token = await getToken();
          if (token != null) {
            await _apiService.post('/auth/logout', {});
          }
        } catch (e) {
          debugPrint('API logout error: $e');
        }
      }

      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await _apiService.removeToken();

      debugPrint('✅ Logout successful');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
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
      if (_useTestData) {
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('✅ Password changed (test mode)');
        return true;
      }

      final response = await _apiService.put('/auth/change-password', {
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Change password error: $e');
      return false;
    }
  }

  /// Forgot password - Firebase implementation
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('✅ Password reset email sent (test mode) to: $email');
        return {
          'success': true,
          'message': 'Password reset instructions have been sent to your email'
        };
      }

      final normalizedEmail = email.trim().toLowerCase();
      debugPrint('🔄 Sending Firebase password reset to: $normalizedEmail');

      await _firebaseAuth.sendPasswordResetEmail(email: normalizedEmail);

      debugPrint('✅ Firebase password reset email sent');
      return {
        'success': true,
        'message': 'Password reset instructions have been sent to your email address.'
      };

    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code}');

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please try again later';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection';
          break;
        default:
          errorMessage = 'Failed to send reset email. Please try again';
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      debugPrint('❌ Forgot password error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred'
      };
    }
  }

  // ============================================================================
  // PROFILE MANAGEMENT
  // ============================================================================

  /// Update profile
  Future<UserModel?> updateProfile({
    required String name,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return null;

      if (_useTestData) {
        final updatedUser = currentUser.copyWith(
          name: name,
          phone: phone,
          profileImage: profileImage,
        );
        await _saveUserData(updatedUser);
        return updatedUser;
      }

      final response = await _apiService.put('/auth/profile', {
        'name': name,
        if (phone != null) 'phone': phone,
        if (profileImage != null) 'profile_image': profileImage,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final updatedUser = UserModel.fromJson(data['data'] ?? data['user']);
          await _saveUserData(updatedUser);
          return updatedUser;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Update profile error: $e');
      return null;
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userData = json.decode(userJson);
        return UserModel.fromJson(userData);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error getting current user: $e');
      return null;
    }
  }

  /// Refresh user data
  Future<UserModel?> refreshUserData() async {
    try {
      if (_useTestData) {
        return await getCurrentUser();
      }

      final response = await _apiService.get('/auth/me');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final user = UserModel.fromJson(data['data'] ?? data['user']);
          await _saveUserData(user);
          return user;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error refreshing user data: $e');
      return null;
    }
  }

  // ============================================================================
  // TOKEN MANAGEMENT
  // ============================================================================

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('❌ Error getting token: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);
      final isLoggedIn = token != null && token.isNotEmpty && userJson != null;
      debugPrint('🔐 Is logged in: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      return false;
    }
  }

  Future<bool> verifyToken() async {
    try {
      if (_useTestData) {
        return await isLoggedIn();
      }

      final response = await _apiService.get('/auth/verify');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error verifying token: $e');
      return false;
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      _apiService.setAuthToken(token);
      debugPrint('✅ Token saved');
    } catch (e) {
      debugPrint('❌ Error saving token: $e');
    }
  }

  Future<void> _saveUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
      debugPrint('✅ User data saved: ${user.name}');
    } catch (e) {
      debugPrint('❌ Error saving user data: $e');
    }
  }

  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await _apiService.removeToken();
      debugPrint('✅ Auth data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing auth data: $e');
    }
  }
}