// lib/data/services/test_users_loader.dart
// Helper to load all test users into Firebase Auth
// ✅ FIXED: Uses existing TestDataService structure

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestUsersLoader {
  /// Initialize all common test users in Firebase Auth
  /// This includes all the main test accounts used in the app
  static Future<void> loadAllTestUsers() async {
    try {
      debugPrint('🔧 Loading all test users into Firebase Auth...');

      // List of all test users that need Firebase Auth accounts
      final testUsers = [
        // Main role accounts
        {'email': 'admin@school.com', 'password': 'password123'},
        {'email': 'teacher@school.com', 'password': 'password123'},
        {'email': 'student@school.com', 'password': 'password123'},
        {'email': 'parent@school.com', 'password': 'password123'},

        // Additional test accounts
        {'email': 'priya@school.com', 'password': 'password123'},
        {'email': 'raj@school.com', 'password': 'password123'},
        {'email': 'amit@school.com', 'password': 'password123'},
        {'email': 'neha@school.com', 'password': 'password123'},
        {'email': 'john@school.com', 'password': 'password123'},
        {'email': 'sarah@school.com', 'password': 'password123'},
        {'email': 'ravi@school.com', 'password': 'password123'},
        {'email': 'anita@school.com', 'password': 'password123'},
        {'email': 'kumar@school.com', 'password': 'password123'},
        {'email': 'lakshmi@school.com', 'password': 'password123'},
        {'email': 'vikram@school.com', 'password': 'password123'},

        // Add more users as needed from your test data
        {'email': 'meena@school.com', 'password': 'password123'},
        {'email': 'suresh@school.com', 'password': 'password123'},
        {'email': 'divya@school.com', 'password': 'password123'},
        {'email': 'arjun@school.com', 'password': 'password123'},
        {'email': 'kavita@school.com', 'password': 'password123'},
      ];

      int created = 0;
      int existing = 0;
      int failed = 0;

      for (var user in testUsers) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: user['email']!,
            password: user['password']!,
          );
          debugPrint('✅ Created: ${user['email']}');
          created++;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            existing++;
          } else {
            debugPrint('⚠️ Error ${user['email']}: ${e.code}');
            failed++;
          }
        }
      }

      // Sign out after initialization
      await FirebaseAuth.instance.signOut();

      debugPrint('✅ Firebase Auth users loaded:');
      debugPrint('   📝 Created: $created');
      debugPrint('   ✓ Existing: $existing');
      debugPrint('   ✗ Failed: $failed');
      debugPrint('   📊 Total: ${created + existing}/${testUsers.length}');
    } catch (e) {
      debugPrint('❌ Error loading test users: $e');
    }
  }

  /// Initialize only the core test users (faster startup)
  static Future<void> initializeCommonTestUsers() async {
    try {
      debugPrint('🔧 Initializing common test Firebase Auth users...');

      final testUsers = [
        {'email': 'admin@school.com', 'password': 'password123'},
        {'email': 'teacher@school.com', 'password': 'password123'},
        {'email': 'student@school.com', 'password': 'password123'},
        {'email': 'parent@school.com', 'password': 'password123'},
        {'email': 'priya@school.com', 'password': 'password123'},
        {'email': 'raj@school.com', 'password': 'password123'},
        {'email': 'amit@school.com', 'password': 'password123'},
      ];

      int created = 0;
      int existing = 0;

      for (var user in testUsers) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: user['email']!,
            password: user['password']!,
          );
          debugPrint('✅ Created: ${user['email']}');
          created++;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            existing++;
          }
        }
      }

      await FirebaseAuth.instance.signOut();
      debugPrint('✅ Common users initialized: $created created, $existing existing');
    } catch (e) {
      debugPrint('❌ Error initializing common test users: $e');
    }
  }

  /// Check if a user exists in Firebase Auth
  static Future<bool> userExistsInFirebaseAuth(String email) async {
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Create a single Firebase Auth user
  static Future<bool> createFirebaseAuthUser(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseAuth.instance.signOut();
      debugPrint('✅ Created Firebase Auth user: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        debugPrint('ℹ️ User already exists: $email');
        return true;
      } else {
        debugPrint('❌ Error creating Firebase Auth user: ${e.code}');
        return false;
      }
    }
  }

  /// Batch create multiple users at once
  static Future<void> batchCreateUsers(List<Map<String, String>> users) async {
    debugPrint('🔧 Batch creating ${users.length} Firebase Auth users...');

    int success = 0;
    int failed = 0;

    for (var user in users) {
      final created = await createFirebaseAuthUser(
        user['email']!,
        user['password'] ?? 'password123',
      );

      if (created) {
        success++;
      } else {
        failed++;
      }
    }

    debugPrint('✅ Batch complete: $success succeeded, $failed failed');
  }
}