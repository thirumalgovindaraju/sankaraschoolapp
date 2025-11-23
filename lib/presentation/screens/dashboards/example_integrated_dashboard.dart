// lib/presentation/screens/dashboards/example_integrated_dashboard.dart
// Complete example showing how to integrate notifications, announcements, and attendance

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/dashboard/dashboard_widgets.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../../core/constants/app_colors.dart';

class IntegratedDashboardScreen extends StatefulWidget {
  const IntegratedDashboardScreen({Key? key}) : super(key: key);

  @override
  State<IntegratedDashboardScreen> createState() => _IntegratedDashboardScreenState();
}

class _IntegratedDashboardScreenState extends State<IntegratedDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      final dashboardProvider = context.read<DashboardProvider>();
      await dashboardProvider.loadDashboardData(user);
    }
  }

  Future<void> _refreshDashboard() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user != null) {
      final dashboardProvider = context.read<DashboardProvider>();
      await dashboardProvider.refreshDashboard(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login to view dashboard'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${user.role?.name?.toUpperCase() ?? 'Dashboard'}'),
        backgroundColor: AppColors.primary,
        actions: [
          // Notifications icon with badge
          Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              final unreadCount = provider.unreadNotificationsCount;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (provider.error != null) {
            return _buildErrorWidget(provider.error!);
          }

          return RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  _buildWelcomeCard(user.name),
                  const SizedBox(height: 16),

                  // Last updated indicator
                  Center(
                    child: Text(
                      'Last updated: ${provider.getTimeSinceLastUpdate()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notifications widget
                  DashboardNotificationsWidget(
                    notifications: provider.recentNotifications,
                    unreadCount: provider.unreadNotificationsCount,
                    onViewAll: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  const SizedBox(height: 16),

                  // Announcements widget
                  DashboardAnnouncementsWidget(
                    announcements: provider.recentAnnouncements,
                    onViewAll: () {
                      Navigator.pushNamed(context, '/announcements');
                    },
                  ),
                  const SizedBox(height: 16),

                  // Attendance widget (role-specific)
                  _buildAttendanceWidget(provider, user.role?.name ?? ''),
                  const SizedBox(height: 16),

                  // Role-specific widgets
                  ..._buildRoleSpecificWidgets(provider, user.role?.name ?? ''),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(String userName) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateTime.now().toString().split(' ')[0],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceWidget(DashboardProvider provider, String role) {
    Map<String, dynamic> attendanceData = {};

    switch (role) {
      case 'admin':
        attendanceData = provider.getTodayAttendanceStats();
        break;
      case 'student':
        attendanceData = provider.getStudentAttendanceSummary();
        break;
      case 'teacher':
      // Teachers can see overall stats
        attendanceData = provider.getTodayAttendanceStats();
        break;
      default:
        return const SizedBox.shrink();
    }

    if (attendanceData.isEmpty) {
      return const SizedBox.shrink();
    }

    return DashboardAttendanceWidget(
      attendanceData: attendanceData,
      onViewDetails: () {
        Navigator.pushNamed(context, '/attendance');
      },
    );
  }

  List<Widget> _buildRoleSpecificWidgets(
      DashboardProvider provider,
      String role,
      ) {
    switch (role) {
      case 'admin':
        return _buildAdminWidgets(provider);
      case 'teacher':
        return _buildTeacherWidgets(provider);
      case 'student':
        return _buildStudentWidgets(provider);
      case 'parent':
        return _buildParentWidgets(provider);
      default:
        return [];
    }
  }

  List<Widget> _buildAdminWidgets(DashboardProvider provider) {
    final pendingTasks = provider.getPendingTasksCount();

    return [
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionButton(
                    icon: Icons.person_add,
                    label: 'Add Student',
                    onTap: () {
                      Navigator.pushNamed(context, '/add-student');
                    },
                  ),
                  _buildQuickActionButton(
                    icon: Icons.school,
                    label: 'Add Teacher',
                    onTap: () {
                      Navigator.pushNamed(context, '/add-teacher');
                    },
                  ),
                  _buildQuickActionButton(
                    icon: Icons.campaign,
                    label: 'New Post',
                    onTap: () {
                      Navigator.pushNamed(context, '/create-announcement');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      if (pendingTasks > 0) ...[
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          color: Colors.orange.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.warning_amber, color: Colors.orange),
            title: const Text('Pending Tasks'),
            subtitle: Text('You have $pendingTasks pending tasks'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to tasks
            },
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildTeacherWidgets(DashboardProvider provider) {
    final attendanceStatus = provider.getAttendanceStatus();
    final pendingClasses = attendanceStatus['attendance_pending'] ?? 0;

    return [
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Classes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionButton(
                    icon: Icons.check_circle,
                    label: 'Mark Attendance',
                    onTap: () {
                      Navigator.pushNamed(context, '/teacher-attendance-entry');
                    },
                  ),
                  _buildQuickActionButton(
                    icon: Icons.grade,
                    label: 'Add Grades',
                    onTap: () {
                      Navigator.pushNamed(context, '/grades');
                    },
                  ),
                  _buildQuickActionButton(
                    icon: Icons.campaign,
                    label: 'Announce',
                    onTap: () {
                      Navigator.pushNamed(context, '/create-announcement');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      if (pendingClasses > 0) ...[
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          color: Colors.red.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: const Text('Attendance Pending'),
            subtitle: Text('Mark attendance for $pendingClasses classes today'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/teacher-attendance-entry');
            },
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildStudentWidgets(DashboardProvider provider) {
    final todayAttendance = provider.getTodayAttendance();

    return [
      if (todayAttendance != null)
        Card(
          elevation: 2,
          color: _getAttendanceStatusColor(todayAttendance['status']).shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(
              _getAttendanceStatusIcon(todayAttendance['status']),
              color: _getAttendanceStatusColor(todayAttendance['status']),
            ),
            title: const Text('Today\'s Attendance'),
            subtitle: Text(
              'Status: ${todayAttendance['status']?.toString().toUpperCase() ?? 'Unknown'}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/attendance');
            },
          ),
        ),
    ];
  }

  List<Widget> _buildParentWidgets(DashboardProvider provider) {
    final childrenAttendance = provider.getChildrenAttendance();

    if (childrenAttendance.isEmpty) {
      return [];
    }

    return [
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Children\'s Attendance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              ...childrenAttendance.map((child) {
                final summary = child['summary'] as Map<String, dynamic>;
                final percentage = summary['attendance_percentage'] ?? 0.0;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(child['student_name'][0]),
                  ),
                  title: Text(child['student_name']),
                  subtitle: Text('Class: ${child['class']}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPercentageColor(percentage).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getPercentageColor(percentage),
                      ),
                    ),
                  ),
                  onTap: () {
                    // Navigate to child's details
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  MaterialColor _getAttendanceStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getAttendanceStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.access_time;
      default:
        return Icons.help;
    }
  }

  MaterialColor _getPercentageColor(double percentage) {
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}