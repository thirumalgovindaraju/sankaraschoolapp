// lib/main.dart

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
import 'data/services/auth_service.dart';
import 'data/services/api_service.dart';
import 'data/services/data_initialization_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase FIRST before anything else
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
  }

  // ✅ DON'T AWAIT - Start initialization in background
  // This allows the app UI to render immediately while data loads
  _initializeDataInBackground();

  // Start the app immediately - don't wait for data
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
        // Auth Provider (doesn't use Firebase directly)
        ChangeNotifierProvider(
          create: (context) => AuthProvider(AuthService(ApiService())),
        ),

        // Dashboard Provider (uses Firebase - will now work)
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