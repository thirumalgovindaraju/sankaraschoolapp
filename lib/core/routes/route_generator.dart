// lib/core/routes/route_generator.dart
// ✅ COMPLETE VERSION - With Pending Approvals Route Added

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
import '../../presentation/screens/admin/manage_students_screen.dart';
import '../../presentation/screens/admin/manage_teachers_screen.dart';
import '../../presentation/screens/admin/pending_approvals_screen.dart'; // ✅ ADDED
import '../../presentation/screens/attendance/mark_attendance_screen.dart';
import '../../presentation/screens/grades/grades_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/debug/debug_users_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/contact/contact_screen.dart';
import '../../presentation/screens/academic/create_announcement_screen.dart';
import '../../presentation/screens/events/enhanced_events_screen.dart';
import '../../presentation/screens/reports/enhanced_reports_screen.dart';
import '../../presentation/screens/fees/enhanced_fees_screen.dart';
import '../../presentation/screens/news/news_management_screen.dart';
import '../../data/models/student_model.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/announcements/announcements_list_screen.dart';
import '../../presentation/screens/announcements/announcement_detail_screen.dart';
import '../../presentation/screens/announcements/edit_announcement_screen.dart';
import '../../data/models/announcement_model.dart';
import '../../presentation/screens/teacher/teacher_attendance_entry_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
    // ============= AUTH ROUTES =============
      case '/':
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case '/debug-users':
        return MaterialPageRoute(builder: (_) => const DebugUsersScreen());

    // ============= DASHBOARD ROUTES =============
      case '/admin-dashboard':
        return MaterialPageRoute(builder: (_) => const AdminDashboard());

      case '/teacher-dashboard':
        return MaterialPageRoute(builder: (_) => const TeacherDashboard());

      case '/student-dashboard':
        return MaterialPageRoute(builder: (_) => const StudentDashboard());

      case '/parent-dashboard':
        return MaterialPageRoute(builder: (_) => const ParentDashboard());

    // ============= STUDENT MANAGEMENT ROUTES =============
      case '/manage-students':
        return MaterialPageRoute(
          builder: (_) => const ManageStudentsScreen(),
        );

      case '/add-student':
        if (args != null) {
          if (args is StudentModel) {
            return MaterialPageRoute(
              builder: (_) => AddStudentScreen(studentData: args.toJson()),
            );
          } else if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (_) => AddStudentScreen(studentData: args),
            );
          }
        }
        return MaterialPageRoute(
          builder: (_) => const AddStudentScreen(),
        );

      case '/edit-student':
        if (args != null) {
          if (args is StudentModel) {
            return MaterialPageRoute(
              builder: (_) => AddStudentScreen(studentData: args.toJson()),
            );
          } else if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (_) => AddStudentScreen(studentData: args),
            );
          }
        }
        return _errorRoute('Student data required for editing');

    // ============= TEACHER MANAGEMENT ROUTES =============
      case '/manage-teachers':
        return MaterialPageRoute(
          builder: (_) => const ManageTeachersScreen(),
        );

      case '/add-teacher':
        if (args != null && args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => AddTeacherScreen(teacherData: args),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const AddTeacherScreen(),
        );

      case '/edit-teacher':
        if (settings.arguments != null && settings.arguments is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => AddTeacherScreen(
              teacherData: settings.arguments as Map<String, dynamic>,
            ),
          );
        }
        return _errorRoute('Teacher data required for editing');

      case '/manage-users':
        return MaterialPageRoute(
          builder: (_) => const ManageUsersScreen(),
        );

    // ✅ ADDED: Pending Approvals Route
      case '/pending-approvals':
        return MaterialPageRoute(
          builder: (_) => const PendingApprovalsScreen(),
        );

      case '/teacher-attendance-entry':
        return MaterialPageRoute(
          builder: (_) => const TeacherAttendanceEntryScreen(),
        );

    // ============= ANNOUNCEMENT ROUTES =============
      case '/create-announcement':
        return MaterialPageRoute(
          builder: (_) => const CreateAnnouncementScreen(),
          settings: settings,
        );

      case '/announcements':
        return MaterialPageRoute(
          builder: (_) => const AnnouncementsListScreen(),
          settings: settings,
        );

      case '/post-news':
        return MaterialPageRoute(
          builder: (_) => const NewsManagementScreen(),
        );

    // ============= ACADEMIC ROUTES (Enhanced versions) =============
      case '/new-event':
      case '/events':
        return MaterialPageRoute(
          builder: (_) => const EnhancedEventsScreen(),
        );

      case '/reports':
        return MaterialPageRoute(
          builder: (_) => const EnhancedReportsScreen(),
        );

      case '/fees':
        return MaterialPageRoute(
          builder: (_) => const EnhancedFeesScreen(),
        );

    // ============= ATTENDANCE ROUTES =============
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

    // ============= GRADES ROUTES =============
      case '/grades':
        if (args is Map<String, dynamic> && args['studentId'] != null) {
          return MaterialPageRoute(
            builder: (_) => GradesScreen(
              studentId: args['studentId'] as String,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const GradesScreen());

    // ============= ANNOUNCEMENT DETAIL ROUTES =============
      case '/announcement-detail':
        final announcement = settings.arguments as AnnouncementModel;
        return MaterialPageRoute(
          builder: (_) => AnnouncementDetailScreen(announcement: announcement),
        );

      case '/edit-announcement':
        final announcement = settings.arguments as AnnouncementModel;
        return MaterialPageRoute(
          builder: (_) => EditAnnouncementScreen(announcement: announcement),
        );

    // ============= OTHER ROUTES =============
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case '/notifications':
        return MaterialPageRoute(
          builder: (context) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final userId = authProvider.currentUser?.id ?? 'ADM001';
            return NotificationsScreen(userId: userId);
          },
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      case '/contact':
        return MaterialPageRoute(
          builder: (_) => const ContactScreen(),
          settings: settings,
        );

    // ============= DEFAULT - ROUTE NOT FOUND =============
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Routes {
  // Auth Routes
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String debugUsers = '/debug-users';

  // Dashboard Routes
  static const String adminDashboard = '/admin-dashboard';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String studentDashboard = '/student-dashboard';
  static const String parentDashboard = '/parent-dashboard';

  // Student Management Routes
  static const String manageStudents = '/manage-students';
  static const String addStudent = '/add-student';
  static const String editStudent = '/edit-student';

  // Teacher Management Routes
  static const String manageTeachers = '/manage-teachers';
  static const String addTeacher = '/add-teacher';
  static const String editTeacher = '/edit-teacher';
  static const String manageUsers = '/manage-users';
  static const String pendingApprovals = '/pending-approvals'; // ✅ ADDED

  // Announcement Routes
  static const String createAnnouncement = '/create-announcement';
  static const String announcements = '/announcements';
  static const String postNews = '/post-news';

  // Academic Routes
  static const String events = '/events';
  static const String newEvent = '/new-event';
  static const String reports = '/reports';
  static const String fees = '/fees';

  // Attendance & Grades Routes
  static const String attendance = '/attendance';
  static const String markAttendance = '/mark-attendance';
  static const String grades = '/grades';

  // Other Routes
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String contact = '/contact';
}