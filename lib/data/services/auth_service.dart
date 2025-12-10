// lib/data/services/auth_service.dart
// Complete AuthService with Firebase Auth integration

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
  static const bool _useTestData = true;

  AuthService(this._apiService);

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize Firebase Auth users for testing
  /// Call this once when app starts in main.dart
  static Future<void> initializeTestUsers() async {
    try {
      debugPrint('🔧 Initializing test Firebase Auth users...');

      final testUsers = [
        {'email': 'admin@school.com', 'password': 'password123'},
        {'email': 'teacher@school.com', 'password': 'password123'},
        {'email': 'student@school.com', 'password': 'password123'},
        {'email': 'parent@school.com', 'password': 'password123'},
        {'email': 'priya@school.com', 'password': 'password123'},
        {'email': 'raj@school.com', 'password': 'password123'},
        {'email': 'amit@school.com', 'password': 'password123'},
      ];

      for (var user in testUsers) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: user['email']!,
            password: user['password']!,
          );
          debugPrint('✅ Created Firebase Auth user: ${user['email']}');
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            debugPrint('ℹ️ User already exists: ${user['email']}');
          } else {
            debugPrint('⚠️ Error creating ${user['email']}: ${e.code}');
          }
        }
      }

      // Sign out after initialization
      await FirebaseAuth.instance.signOut();
      debugPrint('✅ Test users initialized');
    } catch (e) {
      debugPrint('❌ Error initializing test users: $e');
    }
  }

  // ============================================================================
  // AUTHENTICATION METHODS
  // ============================================================================

  /// Login with Firebase Auth (creates real Firebase sessions)
  Future<AuthResponse> loginWithFirebaseAuth({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    try {
      debugPrint('=== FIREBASE AUTH LOGIN ===');
      debugPrint('Email: $email');
      debugPrint('Role: ${role?.name}');

      // Step 0: Sign out any existing session first (fixes Windows threading issues)
      try {
        await _firebaseAuth.signOut();
        debugPrint('🔓 Signed out any existing Firebase session');
        // Small delay to let Firebase Auth clean up
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        debugPrint('⚠️ Sign out error (can be ignored): $e');
      }

      // Step 1: Sign in with Firebase Auth
      UserCredential? userCredential;
      bool firebaseAuthFailed = false;

      try {
        // Try to sign in
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        debugPrint('✅ Firebase Auth sign in successful');
      } catch (e) {
        debugPrint('⚠️ Firebase Auth error: ${e.toString()}');

        if (e is FirebaseAuthException) {
          // On Windows, unknown-error is common - fall back to legacy login
          if (e.code == 'unknown-error') {
            debugPrint('⚠️ Firebase Auth unknown-error on Windows, using fallback method');
            firebaseAuthFailed = true;
          } else if (e.code == 'user-not-found' ||
              e.code == 'invalid-credential' ||
              e.code == 'wrong-password') {
            debugPrint('📝 Creating Firebase Auth user for: $email (Error: ${e.code})');
            try {
              userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
              debugPrint('✅ Firebase Auth user created successfully');
            } catch (createError) {
              debugPrint('⚠️ Failed to create user, using fallback: $createError');
              firebaseAuthFailed = true;
            }
          } else {
            firebaseAuthFailed = true;
          }
        } else {
          firebaseAuthFailed = true;
        }
      }

      // If Firebase Auth failed, use legacy login method
      if (firebaseAuthFailed || userCredential == null) {
        debugPrint('🔄 Falling back to legacy login method (without Firebase Auth)');
        return await _legacyLogin(email: email, password: password, role: role);
      }

      debugPrint('✅ Firebase Auth successful');

      // Step 2: Get user data from test data
      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        final user = await TestDataService.instance.loginWithTestData(email, password);

        if (user != null) {
          debugPrint('✅ Test user found: ${user.name}');

          // Verify role matches if provided
          if (role != null && user.role != role) {
            debugPrint('❌ Role mismatch! Expected: ${role.name}, Got: ${user.role.name}');
            await _firebaseAuth.signOut();
            return AuthResponse(
              success: false,
              message: 'Invalid role selected for this account',
            );
          }

          // Check approval status
          if (user.isPending) {
            await _firebaseAuth.signOut();
            return AuthResponse.pendingApproval(email: email, role: user.role);
          }

          if (user.isRejected) {
            await _firebaseAuth.signOut();
            return AuthResponse.rejected(email: email);
          }

          if (!user.isApproved) {
            await _firebaseAuth.signOut();
            return AuthResponse(
              success: false,
              message: 'Your account is not approved',
            );
          }

          // Save user data
          await _saveUserData(user);
          final token = await userCredential.user!.getIdToken();
          await _saveToken(token ?? 'test_token_${user.id}');

          debugPrint('✅ Login successful with Firebase Auth!');
          return AuthResponse(
            success: true,
            message: 'Login successful',
            user: user,
            accessToken: token,
          );
        }
      }

      // Fallback if test data fails
      await _firebaseAuth.signOut();
      return AuthResponse(
        success: false,
        message: 'Invalid credentials',
      );

    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error: ${e.code}');

      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Invalid email or password';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later';
          break;
        case 'invalid-email':
          message = 'Invalid email address format';
          break;
        default:
          message = 'Authentication failed: ${e.message}';
      }

      return AuthResponse(success: false, message: message);
    } catch (e) {
      debugPrint('❌ Login error: $e');
      return AuthResponse(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  /// Legacy login method (without Firebase Auth)
  Future<AuthResponse> login({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    try {
      debugPrint('=== AUTH SERVICE LOGIN (Legacy) ===');
      debugPrint('Email: $email');
      debugPrint('Role: ${role?.name}');
      debugPrint('Using test data: $_useTestData');

      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        final user = await TestDataService.instance.loginWithTestData(email, password);

        if (user != null) {
          debugPrint('✅ Test user found: ${user.name}');

          if (role != null && user.role != role) {
            debugPrint('❌ Role mismatch! Expected: ${role.name}, Got: ${user.role.name}');
            return AuthResponse(
              success: false,
              message: 'Invalid role selected for this account',
            );
          }

          if (user.isPending) {
            return AuthResponse.pendingApproval(email: email, role: user.role);
          }

          if (user.isRejected) {
            return AuthResponse.rejected(email: email);
          }

          if (!user.isApproved) {
            return AuthResponse(
              success: false,
              message: 'Your account is not approved',
            );
          }

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
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
        if (role != null) 'role': role.name,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final user = UserModel.fromJson(data['data']['user']);

          if (user.isPending) {
            return AuthResponse.pendingApproval(email: email, role: user.role);
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

  /// Register
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

        // Create Firebase Auth user
        try {
          await _firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          debugPrint('✅ Firebase Auth user created');
          await _firebaseAuth.signOut(); // Sign out after creation
        } on FirebaseAuthException catch (e) {
          if (e.code != 'email-already-in-use') {
            debugPrint('⚠️ Firebase Auth creation warning: ${e.code}');
          }
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

      // Sign out from Firebase Auth
      await _firebaseAuth.signOut();
      debugPrint('✅ Firebase Auth sign out');

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
      await clearAuthData();
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
        // Update Firebase Auth password
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          await user.updatePassword(newPassword);
          debugPrint('✅ Firebase password updated');
        }

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
  // FIREBASE AUTH HELPERS
  // ============================================================================

  /// Get current Firebase user
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Check if Firebase Auth session is active
  bool get hasFirebaseSession => _firebaseAuth.currentUser != null;

  /// Get Firebase ID token
  Future<String?> getFirebaseIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      debugPrint('❌ Error getting Firebase ID token: $e');
      return null;
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Legacy login method (fallback when Firebase Auth fails)
  Future<AuthResponse> _legacyLogin({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    try {
      debugPrint('=== LEGACY LOGIN (without Firebase Auth) ===');

      if (_useTestData) {
        await TestDataService.instance.loadTestData();
        final user = await TestDataService.instance.loginWithTestData(email, password);

        if (user != null) {
          debugPrint('✅ Test user found: ${user.name}');

          if (role != null && user.role != role) {
            debugPrint('❌ Role mismatch! Expected: ${role.name}, Got: ${user.role.name}');
            return AuthResponse(
              success: false,
              message: 'Invalid role selected for this account',
            );
          }

          if (user.isPending) {
            return AuthResponse.pendingApproval(email: email, role: user.role);
          }

          if (user.isRejected) {
            return AuthResponse.rejected(email: email);
          }

          if (!user.isApproved) {
            return AuthResponse(
              success: false,
              message: 'Your account is not approved',
            );
          }

          await _saveUserData(user);
          await _saveToken('test_token_${user.id}');

          debugPrint('✅ Legacy login successful!');
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
            message: 'Invalid email or password',
          );
        }
      }

      // Production API call would go here
      return AuthResponse(
        success: false,
        message: 'API login not implemented',
      );
    } catch (e) {
      debugPrint('❌ Legacy login error: $e');
      return AuthResponse(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

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