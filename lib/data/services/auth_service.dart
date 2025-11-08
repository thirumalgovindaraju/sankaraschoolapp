// lib/data/services/auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/auth_response.dart';
import 'api_service.dart';
import 'test_data_service.dart';

class AuthService {
  final ApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const bool _useTestData = true; // Toggle this for production

  AuthService(this._apiService);

  // ============================================================================
  // AUTHENTICATION METHODS
  // ============================================================================

  /// Login
  Future<AuthResponse> login({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    try {
      // Use test data if enabled
      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        final user = await TestDataService.instance.loginWithTestData(email, password);

        if (user != null) {
          // Save user data locally
          await _saveUserData(user);
          await _saveToken('test_token_${user.id}');

          return AuthResponse(
            success: true,
            message: 'Login successful',
            user: user,
            accessToken: 'test_token_${user.id}',
          );
        } else {
          return AuthResponse(
            success: false,
            message: 'Invalid credentials. Try:\nadmin@school.com\nteacher@school.com\nstudent@school.com\nparent@school.com',
          );
        }
      }

      // Production API call
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
        if (role != null) 'role': role.name,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final user = UserModel.fromJson(data['data']['user']);
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
      debugPrint('Login error: $e');
      return AuthResponse(
        success: false,
        message: 'An error occurred during login',
      );
    }
  }

  /// Register
  /*
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        return AuthResponse(
          success: true,
          message: 'Registration successful! Please login with your credentials.',
        );
      }

      final response = await _apiService.post('/auth/register', {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        'role': role.name,
        ...?additionalData,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        return AuthResponse(
          success: true,
          message: data['message'] ?? 'Registration successful',
        );
      }

      final data = json.decode(response.body);
      return AuthResponse(
        success: false,
        message: data['message'] ?? 'Registration failed',
      );
    } catch (e) {
      debugPrint('Registration error: $e');
      return AuthResponse(
        success: false,
        message: 'An error occurred during registration',
      );
    }
  }
*//// Register - UPDATED VERSION
  /// Replace the register method in auth_service.dart with this
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (_useTestData) {
        await TestDataService.instance.loadTestData();

        // Check if email already exists
        if (TestDataService.instance.emailExists(email)) {
          return AuthResponse(
            success: false,
            message: 'Email already registered. Please login or use a different email.',
          );
        }

        // Register the user
        final success = await TestDataService.instance.registerUser(
          email: email,
          password: password,
          name: name,
          phone: phone,
          role: role,
        );

        if (success) {
          return AuthResponse(
            success: true,
            message: 'Registration successful! You can now login with your credentials.',
          );
        } else {
          return AuthResponse(
            success: false,
            message: 'Registration failed. Please try again.',
          );
        }
      }

      // Production API call (existing code)
      final response = await _apiService.post('/auth/register', {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        'role': role.name,
        ...?additionalData,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        return AuthResponse(
          success: true,
          message: data['message'] ?? 'Registration successful',
        );
      }

      final data = json.decode(response.body);
      return AuthResponse(
        success: false,
        message: data['message'] ?? 'Registration failed',
      );
    } catch (e) {
      debugPrint('Registration error: $e');
      return AuthResponse(
        success: false,
        message: 'An error occurred during registration',
      );
    }
  }
  /// Logout
  Future<void> logout() async {
    try {
      // Call API to invalidate token (if not using test data)
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

      // Also clear token from ApiService
      await _apiService.removeToken();
    } catch (e) {
      debugPrint('Logout error: $e');
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
        await Future.delayed(const Duration(seconds: 1));
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
      debugPrint('Change password error: $e');
      return false;
    }
  }

  /// Forgot password
  Future<bool> forgotPassword(String email) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Password reset email sent (test mode)');
        return true;
      }

      final response = await _apiService.post('/auth/forgot-password', {
        'email': email,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('Forgot password error: $e');
      return false;
    }
  }

  /// Reset password with token
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Password reset (test mode)');
        return true;
      }

      final response = await _apiService.post('/auth/reset-password', {
        'token': token,
        'new_password': newPassword,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
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
        // Update locally for test data
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
      debugPrint('Update profile error: $e');
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
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Refresh user data from server
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
      debugPrint('Error refreshing user data: $e');
      return null;
    }
  }

  // ============================================================================
  // TOKEN MANAGEMENT
  // ============================================================================

  /// Get token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  /// Check if logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);
      return token != null && token.isNotEmpty && userJson != null;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  /// Verify token validity
  Future<bool> verifyToken() async {
    try {
      if (_useTestData) {
        return await isLoggedIn();
      }

      final response = await _apiService.get('/auth/verify');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error verifying token: $e');
      return false;
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Save token
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);

      // Also save to ApiService
      _apiService.setAuthToken(token);
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  /// Save user data
  Future<void> _saveUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  /// Clear all auth data
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await _apiService.removeToken();
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  // ============================================================================
  // EMAIL VERIFICATION (Optional)
  // ============================================================================

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Email verification sent (test mode)');
        return true;
      }

      final response = await _apiService.post('/auth/send-verification', {});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('Send verification error: $e');
      return false;
    }
  }

  /// Verify email with token
  Future<bool> verifyEmail(String verificationToken) async {
    try {
      if (_useTestData) {
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('✅ Email verified (test mode)');
        return true;
      }

      final response = await _apiService.post('/auth/verify-email', {
        'token': verificationToken,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('Verify email error: $e');
      return false;
    }
  }
}