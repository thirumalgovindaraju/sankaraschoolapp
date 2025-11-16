// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import 'data/services/auth_service.dart';
import 'data/services/api_service.dart';
import 'data/services/dashboard_service.dart';
import 'data/services/data_initialization_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize data from test_data.json
  print('🚀 Initializing application data...');
  final initialized = await DataInitializationService.initializeAllData();

  if (initialized) {
    final status = await DataInitializationService.getInitializationStatus();
    print('✅ Data initialization complete!');
    print('📊 Students: ${status['student_count']}');
    print('👨‍🏫 Teachers: ${status['teacher_count']}');
  } else {
    print('⚠️ Data initialization failed, app may not work correctly');
  }

  runApp(const MyApp());
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

        // Dashboard Provider
        /*ChangeNotifierProvider(
          create: (context) => DashboardProvider(
            DashboardService(ApiService(), useTestMode: true),
          ),*/
        ),
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