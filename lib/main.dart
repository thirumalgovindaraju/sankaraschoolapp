import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// Conditional imports for platform-specific features
import 'package:firebase_messaging/firebase_messaging.dart'
if (dart.library.html) 'package:firebase_messaging/firebase_messaging.dart'
if (dart.library.io) 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart'
if (dart.library.html) 'stubs/flutter_local_notifications_stub.dart'
if (dart.library.io) 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Import the generated file
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
import 'data/services/auth_service.dart';
import 'data/services/api_service.dart';
import 'data/services/dashboard_service.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Check if current platform supports Firebase Messaging
bool get _supportsFirebaseMessaging {
  if (kIsWeb) return true;
  return Platform.isAndroid || Platform.isIOS;
}

// Background message handler - only for mobile
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (_supportsFirebaseMessaging) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('Background message: ${message.messageId}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase on all platforms
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully ✓');

    // Set up Firebase Messaging only on supported platforms
    if (_supportsFirebaseMessaging) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('Permission status: ${settings.authorizationStatus}');
    } else {
      debugPrint('Firebase Messaging not supported on this platform (Windows/Linux/macOS desktop)');
    }
  } catch (e) {
    debugPrint('Firebase error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    if (_supportsFirebaseMessaging) {
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      _initializeNotifications();
    } else {
      debugPrint('Local notifications not available on this platform');
    }
  }

  Future<void> _initializeNotifications() async {
    if (!_supportsFirebaseMessaging || _flutterLocalNotificationsPlugin == null) {
      return;
    }

    try {
      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _flutterLocalNotificationsPlugin!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Android-specific channel setup
      if (Platform.isAndroid) {
        const androidChannel = AndroidNotificationChannel(
          'default_channel',
          'Default Notifications',
          description: 'General notifications',
          importance: Importance.high,
        );

        await _flutterLocalNotificationsPlugin!
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);
      }

      // Foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message: ${message.messageId}');

        if (message.notification != null) {
          _showLocalNotification(
            title: message.notification!.title ?? 'New Notification',
            body: message.notification!.body ?? '',
            payload: message.data.toString(),
          );
        }
      });

      // App opened from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          debugPrint('Opened from terminated: ${message.messageId}');
          _handleNotificationClick(message);
        }
      });

      // App opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('Opened from background: ${message.messageId}');
        _handleNotificationClick(message);
      });

      // Get and log FCM token
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('═══════════════════════════════════════');
      debugPrint('FCM Token: $token');
      debugPrint('═══════════════════════════════════════');

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('Token refreshed: $newToken');
      });
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (_flutterLocalNotificationsPlugin == null) return;

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'General notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin!.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  void _handleNotificationClick(RemoteMessage message) {
    final data = message.data;
    debugPrint('Notification data: $data');

    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'announcement':
          navigatorKey.currentState?.pushNamed('/announcements');
          break;
        case 'assignment':
          navigatorKey.currentState?.pushNamed('/academic');
          break;
        case 'attendance':
          navigatorKey.currentState?.pushNamed('/attendance');
          break;
        default:
          navigatorKey.currentState?.pushNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(AuthService(ApiService())),
        ),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => AcademicProvider()),
        ChangeNotifierProvider(create: (context) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => AdminProvider()),
        ChangeNotifierProvider(
          create: (context) => DashboardProvider(
            DashboardService(ApiService(), useTestMode: true),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'School Management App',
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