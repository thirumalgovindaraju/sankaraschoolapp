// lib/core/routes/route_generator.dart

import 'package:flutter/material.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboards/admin_dashboard.dart';
import '../../presentation/screens/dashboards/teacher_dashboard.dart';
import '../../presentation/screens/dashboards/student_dashboard.dart';
import '../../presentation/screens/dashboards/parent_dashboard.dart';
import '../../presentation/screens/admin/add_student_screen.dart';
import '../../presentation/screens/admin/add_teacher_screen.dart';
import '../../presentation/screens/admin/manage_users_screen.dart';
import '../../presentation/screens/attendance/mark_attendance_screen.dart';
import '../../presentation/screens/grades/grades_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/debug/debug_users_screen.dart';
import '../../presentation/screens/events/events_screen.dart';
import '../../presentation/screens/reports/reports_screen.dart';
import '../../presentation/screens/fees/fees_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/contact/contact_screen.dart';
import '../../presentation/screens/academic/create_announcement_screen.dart';
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Get arguments passed in route
    final args = settings.arguments;

    switch (settings.name) {
    // Auth Routes
      case '/':
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/debug-users':
        return MaterialPageRoute(builder: (_) => const DebugUsersScreen());
    // Dashboard Routes
      case '/admin-dashboard':
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      case '/teacher-dashboard':
        return MaterialPageRoute(builder: (_) => const TeacherDashboard());

      case '/student-dashboard':
        return MaterialPageRoute(builder: (_) => const StudentDashboard());

      case '/parent-dashboard':
        return MaterialPageRoute(builder: (_) => const ParentDashboard());

      case '/events':
      case '/new-event':
        return MaterialPageRoute(
          builder: (_) => const EventsScreen(),
          settings: settings,
        );

      case '/reports':
        return MaterialPageRoute(
          builder: (_) => const ReportsScreen(),
          settings: settings,
        );

      case '/fees':
        return MaterialPageRoute(
          builder: (_) => const FeesScreen(),
          settings: settings,
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

// These routes should already exist, if not add them:
      case '/contact':
        return MaterialPageRoute(
          builder: (_) => const ContactScreen(),
          settings: settings,
        );

      case '/create-announcement':
        return MaterialPageRoute(
          builder: (_) => const CreateAnnouncementScreen(),
          settings: settings,
        );
    // Admin Routes
    //   case '/admin/add-student':
    //     return MaterialPageRoute(
    //       builder: (_) => AddStudentScreen(
    //         studentData: args as Map<String, dynamic>?,
    //       ),
    //     );
    //
    //   case '/admin/add-teacher':
    //     return MaterialPageRoute(
    //       builder: (_) => AddTeacherScreen(
    //         teacherData: args as Map<String, dynamic>?,
    //       ),
    //     );
    //
    //   case '/admin/manage-users':
    //     return MaterialPageRoute(builder: (_) => const ManageUsersScreen());
      case '/add-student':
        return MaterialPageRoute(
          builder: (_) => const AddStudentScreen(),
        );

      case '/add-teacher':
        return MaterialPageRoute(
          builder: (_) => const AddTeacherScreen(),
        );

      case '/manage-users':
        return MaterialPageRoute(
          builder: (_) => const ManageUsersScreen(),
        );
    // Attendance Routes
      case '/attendance':
        if (args is Map<String, dynamic> && args['studentId'] != null) {
          return MaterialPageRoute(
            builder: (_) => GradesScreen(
              studentId: args['studentId'] as String,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const GradesScreen());

      case '/mark-attendance':
        if (args is Map<String, dynamic> &&
            args['classId'] != null &&
            args['section'] != null) {
          return MaterialPageRoute(
            builder: (_) => MarkAttendanceScreen(
              classId: args['classId'] as String,
              section: args['section'] as String,
            ),
          );
        }
        return _errorRoute('Missing required parameters for mark attendance');

    // Grades Routes
      case '/grades':
        if (args is Map<String, dynamic> && args['studentId'] != null) {
          return MaterialPageRoute(
            builder: (_) => GradesScreen(
              studentId: args['studentId'] as String,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const GradesScreen());

    // Profile Route
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

    // Notifications Route
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const Notificationscreen());

    // Default - Route not found
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  // Error route for undefined routes
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Route names class for easy reference
class Routes {
  // Auth
  static const String login = '/login';
  static const String register = '/register';

  // Dashboards
  static const String adminDashboard = '/admin-dashboard';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String studentDashboard = '/student-dashboard';
  static const String parentDashboard = '/parent-dashboard';

  // Admin
  static const String addStudent = '/admin/add-student';
  static const String addTeacher = '/admin/add-teacher';
  static const String manageUsers = '/admin/manage-users';

  // Features
  static const String attendance = '/attendance';
  static const String markAttendance = '/mark-attendance';
  static const String grades = '/grades';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
}