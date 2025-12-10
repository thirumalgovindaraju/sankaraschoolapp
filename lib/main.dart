// lib/main.dart
// Complete version with Firebase Auth initialization

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/constants/app_theme.dart';
import 'core/routes/route_generator.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/home_provider.dart';
import 'presentation/providers/academic_provider.dart';
import 'presentation/providers/announcement_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/admin_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/student_provider.dart';
import 'presentation/providers/teacher_provider.dart';
import 'presentation/providers/attendance_provider.dart';
import 'presentation/providers/worksheet_generator_provider.dart';
import 'presentation/providers/worksheet_submission_provider.dart';
import 'data/services/auth_service.dart';
import 'data/services/api_service.dart';
import 'data/services/data_initialization_service.dart';
import 'data/services/test_users_loader.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Step 1: Initialize Firebase FIRST
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  // ✅ Step 2: Initialize test Firebase Auth users
  // Option A: Load ALL test users from TestDataService (comprehensive)
  try {
    await TestUsersLoader.loadAllTestUsers();
    debugPrint('✅ All test users loaded into Firebase Auth');
  } catch (e) {
    debugPrint('❌ Error loading all test users: $e');
  }

  // Option B: Or use the faster common users method (uncomment if Option A is too slow)
  // try {
  //   await TestUsersLoader.initializeCommonTestUsers();
  //   debugPrint('✅ Common test users initialized');
  // } catch (e) {
  //   debugPrint('❌ Error initializing common test users: $e');
  // }

  // ✅ Step 3: Initialize data in background (non-blocking)
  _initializeDataInBackground();

  // ✅ Step 4: Start the app
  runApp(const MyApp());
}

// Initialize data in the background without blocking the UI
void _initializeDataInBackground() async {
  debugPrint('🚀 Starting background data initialization...');

  try {
    final initialized = await DataInitializationService.initializeAllData();

    if (initialized) {
      final status = await DataInitializationService.getInitializationStatus();
      debugPrint('✅ Data initialization complete!');
      debugPrint('📊 Students: ${status['student_count']}');
      debugPrint('👨‍🏫 Teachers: ${status['teacher_count']}');
    } else {
      debugPrint('⚠️ Data initialization failed, app may not work correctly');
    }
  } catch (e) {
    debugPrint('❌ Error during data initialization: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (context) => AuthProvider(AuthService(ApiService())),
        ),

        // Dashboard Provider (uses Firebase - will now work with request.auth)
        ChangeNotifierProvider(
          create: (_) => DashboardProvider()..initializeRealTimeUpdates(),
        ),

        // Core Providers
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => AcademicProvider()),
        ChangeNotifierProvider(create: (context) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),

        // Admin Providers
        ChangeNotifierProvider(create: (context) => AdminProvider()),
        ChangeNotifierProvider(create: (context) => StudentProvider()),
        ChangeNotifierProvider(create: (context) => TeacherProvider()),

        // Attendance Provider
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),

        // Worksheet Providers
        ChangeNotifierProvider(create: (_) => WorksheetGeneratorProvider()),
        ChangeNotifierProvider(create: (_) => WorksheetSubmissionProvider()),
      ],
      child: MaterialApp(
        title: 'Sri Sankara Global School',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
        navigatorKey: navigatorKey,
      ),
    );
  }
}