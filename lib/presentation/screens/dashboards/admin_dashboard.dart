// lib/presentation/screens/dashboards/admin_dashboard.dart (COMPLETE - ALL ERRORS FIXED)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../widgets/dashboard/announcement_card.dart';
import '../../widgets/dashboard/notification_badge.dart';
import '../../widgets/common/custom_drawer.dart';
import '../../widgets/dashboard/realtime_attendance_widget.dart';
import '../../providers/attendance_provider.dart';
import '/data/services/admin_service.dart';
import '/data/services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final userEmail = authProvider.currentUser?.email;
    if (currentUser == null) return;

    final userId = currentUser.id;
    final userRole = currentUser.role?.name ?? 'admin';

    final futures = <Future>[
      context.read<DashboardProvider>().refreshDashboard(currentUser),
      // ✅ Make sure this has proper error handling
      context.read<AnnouncementProvider>().fetchAnnouncements(
        userRole: userRole,
        userId: userId,
      ).catchError((e) {
        print('⚠️ Non-critical: Could not load announcements: $e');
        return; // Don't block other data loading
      }),
      context.read<StudentProvider>().loadStudents(),
      context.read<TeacherProvider>().loadTeachers(),
    ];

    if (userEmail != null && userEmail.isNotEmpty)
      futures.add(context.read<NotificationProvider>().fetchNotifications(userEmail));
    else if (userId != null) {
      futures.add(context.read<NotificationProvider>().fetchNotifications(userId));
    }

    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final announcementProvider = context.watch<AnnouncementProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final teacherProvider = context.watch<TeacherProvider>();

    final user = authProvider.currentUser;
    final stats = dashboardProvider.stats;
    final recentActivities = dashboardProvider.recentActivities;
    final recentAnnouncements = announcementProvider.announcements.take(3).toList();
    final unreadNotifications = notificationProvider.unreadCount;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: const CustomDrawer(),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Colors.orange.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.dashboard, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Executive Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Strategic Control Center',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          NotificationBadge(
            count: unreadNotifications,
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          const SizedBox(width: 12),
          Builder(
            builder: (context) => Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                tooltip: 'Open Menu',
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: Theme.of(context).colorScheme.primary,
        child: dashboardProvider.isLoading && stats == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading Executive Dashboard...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        )
            : FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExecutiveWelcomeCard(user),
                // ✅ ADD THIS LINE:
                _buildPendingApprovalsCard(context),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKeyStatistics(context, stats, dashboardProvider, studentProvider, teacherProvider),
                      const SizedBox(height: 24),
                      _buildRealTimeAttendanceSection(context),
                      const SizedBox(height: 24),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      if (stats != null) ...[
                        _buildAnalyticsDashboard(context, stats),
                        const SizedBox(height: 24),
                      ],
                      _buildStudentManagementSection(context, studentProvider),
                      const SizedBox(height: 24),
                      _buildTeacherManagementSection(context, teacherProvider),
                      const SizedBox(height: 24),
                      _buildActivityAndAnnouncementsRow(
                        context,
                        recentActivities,
                        recentAnnouncements,
                        dashboardProvider,
                        announcementProvider,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-announcement'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        icon: const Icon(Icons.campaign, size: 24),
        label: const Text(
          'New Announcement',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildExecutiveWelcomeCard(dynamic user) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = 'Good Morning';
    IconData greetingIcon = Icons.wb_sunny;

    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_sunny_outlined;
    } else if (hour >= 17) {
      greeting = 'Good Evening';
      greetingIcon = Icons.nights_stay;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Colors.orange.shade600,
            Colors.deepOrange.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(greetingIcon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.name ?? 'Administrator',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Chief Executive Officer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${now.day}/${now.month}/${now.year}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ✅ ADD THIS NEW METHOD (around line 270)
  Widget _buildPendingApprovalsCard(BuildContext context) {
    return FutureBuilder<int>(
      future: AdminService(ApiService()).getPendingApprovalsCount(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data ?? 0;

        if (pendingCount == 0) {
          return const SizedBox.shrink(); // Hide if no pending approvals
        }

        return Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/pending-approvals'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade400,
                    Colors.deepOrange.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pending_actions,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending Approvals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$pendingCount user${pendingCount > 1 ? 's' : ''} awaiting approval',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$pendingCount',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildKeyStatistics(
      BuildContext context,
      stats,
      DashboardProvider provider,
      StudentProvider studentProvider,
      TeacherProvider teacherProvider,
      ) {
    // Add null safety checks for stats object
    final averageAttendance = stats != null && stats is Map
        ? (stats['averageAttendance'] ?? 0.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Key Performance Indicators',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _buildEnhancedStatCard(
              title: 'Total Students',
              value: studentProvider.totalStudents.toString(),
              icon: Icons.people,
              color: Colors.blue,
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade700],
              ),
              trend: provider.getStudentGrowthTrend(),
              onTap: () => Navigator.pushNamed(context, '/manage-students'),
            ),
            _buildEnhancedStatCard(
              title: 'Total Teachers',
              value: teacherProvider.totalTeachers.toString(),
              icon: Icons.school,
              color: Colors.green,
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade700],
              ),
              trend: provider.getTeacherGrowthTrend(),
              onTap: () => Navigator.pushNamed(context, '/manage-teachers'),
            ),
            _buildEnhancedStatCard(
              title: 'Avg Attendance',
              value: '${averageAttendance is num ? averageAttendance.toStringAsFixed(1) : '0.0'}%',
              icon: Icons.check_circle,
              color: Colors.orange,
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade700],
              ),
              trend: provider.getAttendanceTrend(),
              onTap: () => Navigator.pushNamed(context, '/attendance'),
            ),
            _buildEnhancedStatCard(
              title: 'Active Classes',
              value: studentProvider.studentsByClass.length.toString(),
              icon: Icons.class_,
              color: Colors.purple,
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade700],
              ),
              trend: '0%',
              onTap: () => Navigator.pushNamed(context, '/manage-students'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Gradient gradient,
    required dynamic trend, // CHANGED: from String to dynamic
    VoidCallback? onTap,
  }) {
    // Convert trend to String if it's a List
    String trendText;
    if (trend is List) {
      // Calculate growth percentage from trend data
      if (trend.isEmpty) {
        trendText = '0%';
      } else {
        final first = trend.first['value'] ?? 0;
        final last = trend.last['value'] ?? 0;
        final growth = first == 0 ? 0 : ((last - first) / first * 100);
        trendText = growth >= 0 ? '+${growth.toStringAsFixed(1)}%' : '${growth.toStringAsFixed(1)}%';
      }
    } else {
      trendText = trend.toString();
    }

    final isPositive = trendText.startsWith('+');
    final isNeutral = trendText == '0%' || trendText == '0.0%';

    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isNeutral)
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            size: 14,
                            color: Colors.white,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          trendText,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealTimeAttendanceSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.people_alt,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Today\'s School Attendance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Consumer<AttendanceProvider>(
              builder: (context, attendanceProvider, child) {
                return FutureBuilder<Map<String, dynamic>>(
                  future: attendanceProvider.getAttendanceStatistics(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text('No attendance data available'),
                      );
                    }

                    final stats = snapshot.data!;
                    final totalStudents = stats['total_students'] ?? 0;
                    final presentToday = stats['present_today'] ?? 0;
                    final absentToday = stats['absent_today'] ?? 0;
                    final lateToday = stats['late_today'] ?? 0;
                    final avgAttendance = stats['average_attendance'] ?? 0.0;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              'Present',
                              presentToday.toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                            _buildStat(
                              'Absent',
                              absentToday.toString(),
                              Icons.cancel,
                              Colors.red,
                            ),
                            _buildStat(
                              'Late',
                              lateToday.toString(),
                              Icons.access_time,
                              Colors.orange,
                            ),
                            _buildStat(
                              'Total',
                              totalStudents.toString(),
                              Icons.people,
                              Colors.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.trending_up, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Average Attendance: ${avgAttendance.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.person_add,
        'label': 'Add Student',
        'color': Colors.blue,
        'route': '/add-student'
      },
      {
        'icon': Icons.school,
        'label': 'Add Teacher',
        'color': Colors.green,
        'route': '/add-teacher'
      },
      {
        'icon': Icons.list_alt,
        'label': 'Students',
        'color': Colors.indigo,
        'route': '/manage-students'
      },
      {
        'icon': Icons.people_alt,
        'label': 'Teachers',
        'color': Colors.teal,
        'route': '/manage-teachers'
      },
      {
        'icon': Icons.announcement,
        'label': 'Post News',
        'color': Colors.orange,
        'route': '/create-announcement'
      },
      {
        'icon': Icons.event,
        'label': 'Events',
        'color': Colors.purple,
        'route': '/events'
      },
      {
        'icon': Icons.assessment,
        'label': 'Reports',
        'color': Colors.red,
        'route': '/reports'
      },
      {
        'icon': Icons.payment,
        'label': 'Fees',
        'color': Colors.cyan,
        'route': '/fees'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.bolt,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildEnhancedActionCard(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              color: action['color'] as Color,
              onTap: () {
                final route = action['route'] as String?;
                if (route != null) {
                  Navigator.pushNamed(context, route);
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsDashboard(BuildContext context, stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.show_chart,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Analytics Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildAttendanceChart(context, stats)),
            const SizedBox(width: 12),
            Expanded(child: _buildFeeChart(context, stats)),
          ],
        ),
      ],
    );
  }

  // FIX LINES 416, 427, 438: Convert List count to String

  Widget _buildStudentManagementSection(BuildContext context, StudentProvider studentProvider) {
    // Calculate gender counts safely
    int boysCount = 0;
    int girlsCount = 0;

    try {
      final students = studentProvider.allStudents;
      if (students != null) {
        boysCount = students.where((s) => s.gender == 'Male').length;
        girlsCount = students.where((s) => s.gender == 'Female').length;
      }
    } catch (e) {
      boysCount = 0;
      girlsCount = 0;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.people, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Student Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/manage-students'),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  'Total',
                  '${studentProvider.totalStudents}',
                  Icons.people,
                  Colors.blue,
                ),
                _buildStat(
                  'Classes',
                  '${studentProvider.studentsByClass.length}',
                  Icons.class_,
                  Colors.green,
                ),
                _buildStat(
                  'Boys',
                  boysCount.toString(),
                  Icons.boy,
                  Colors.cyan,
                ),
                _buildStat(
                  'Girls',
                  girlsCount.toString(),
                  Icons.girl,
                  Colors.pink,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _buildClassWiseBreakdown(studentProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherManagementSection(BuildContext context, TeacherProvider teacherProvider) {
    // Calculate gender counts safely
    int maleCount = 0;
    int femaleCount = 0;

    try {
      final teachers = teacherProvider.teachers;
      if (teachers != null) {
        maleCount = teachers.where((t) => t['gender'] == 'Male').length;
        femaleCount = teachers.where((t) => t['gender'] == 'Female').length;
      }
    } catch (e) {
      maleCount = 0;
      femaleCount = 0;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.school, color: Colors.green, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Teacher Overview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/manage-teachers'),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  'Total',
                  '${teacherProvider.totalTeachers}',
                  Icons.school,
                  Colors.green,
                ),
                _buildStat(
                  'Subjects',
                  '${teacherProvider.teachersBySubject.length}',
                  Icons.subject,
                  Colors.purple,
                ),
                _buildStat(
                  'Male',
                  maleCount.toString(),
                  Icons.man,
                  Colors.blue,
                ),
                _buildStat(
                  'Female',
                  femaleCount.toString(),
                  Icons.woman,
                  Colors.pink,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _buildSubjectWiseBreakdown(teacherProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildClassWiseBreakdown(StudentProvider studentProvider) {
    final classList = studentProvider.studentsByClass.entries.take(5).toList();

    if (classList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No student data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class-wise Distribution (Top 5)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        ...classList.map((entry) {
          final percentage = (entry.value / 30).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.blue.shade600],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${entry.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubjectWiseBreakdown(TeacherProvider teacherProvider) {
    final subjectList = teacherProvider.teachersBySubject.entries.take(5).toList();

    if (subjectList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No teacher data available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final colors = [
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject-wise Distribution (Top 5)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        ...subjectList.asMap().entries.map((entry) {
          final index = entry.key;
          final subject = entry.value;
          final color = colors[index % colors.length];
          final percentage = (subject.value / 10).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Container(
                  width: 110,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.8), color],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    subject.key.length > 12
                        ? '${subject.key.substring(0, 10)}..'
                        : subject.key,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color.withOpacity(0.8), color],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${subject.value}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAttendanceChart(BuildContext context, stats) {
    // Add null safety check for weeklyAttendance
    final weeklyAttendanceList = stats != null && stats is Map && stats.containsKey('weeklyAttendance')
        ? (stats['weeklyAttendance'] as List<dynamic>?)
        : null;

    // Create default data if no data is available
    final defaultWeeklyData = [
      {'day': 'Mon', 'percentage': 85.0},
      {'day': 'Tue', 'percentage': 88.0},
      {'day': 'Wed', 'percentage': 90.0},
      {'day': 'Thu', 'percentage': 87.0},
      {'day': 'Fri', 'percentage': 92.0},
    ];

    // Use actual data if available, otherwise use default
    final attendanceData = weeklyAttendanceList ?? defaultWeeklyData;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.orange.shade50.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Weekly Attendance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < attendanceData.length) {
                            final dayData = attendanceData[value.toInt()];
                            final day = dayData is Map
                                ? (dayData['day'] ?? '')
                                : (dayData.day ?? '');
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                day.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        attendanceData.length,
                            (i) {
                          final data = attendanceData[i];
                          final percentage = data is Map
                              ? (data['percentage'] ?? 85.0)
                              : (data.percentage ?? 85.0);
                          return FlSpot(
                            i.toDouble(),
                            (percentage is num ? percentage.toDouble() : 85.0),
                          );
                        },
                      ),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.orange.shade700,
                        ],
                      ),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.orange.shade700,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.3),
                            Colors.orange.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: 80,
                  maxY: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeChart(BuildContext context, stats) {
    // Add null safety checks for fee-related properties
    final totalFeesCollected = stats != null && stats is Map
        ? (stats['totalFeesCollected'] ?? 0.0)
        : 0.0;

    final totalFeesPending = stats != null && stats is Map
        ? (stats['totalFeesPending'] ?? 0.0)
        : 0.0;

    final feeCollectionRate = stats != null && stats is Map
        ? (stats['feeCollectionRate'] ?? 0.0)
        : 0.0;

    // Calculate percentages safely
    final collectedPercentage = feeCollectionRate is num ? feeCollectionRate.toDouble() : 0.0;
    final pendingPercentage = 100.0 - collectedPercentage;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.green.shade50.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Fee Collection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: totalFeesCollected is num ? totalFeesCollected.toDouble() : 70.0,
                          color: Colors.green.shade600,
                          title: '${collectedPercentage.toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          badgeWidget: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          badgePositionPercentageOffset: 1.3,
                        ),
                        PieChartSectionData(
                          value: totalFeesPending is num ? totalFeesPending.toDouble() : 30.0,
                          color: Colors.red.shade400,
                          title: '${pendingPercentage.toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          badgeWidget: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.pending,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          badgePositionPercentageOffset: 1.3,
                        ),
                      ],
                      sectionsSpace: 3,
                      centerSpaceRadius: 35,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payments,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityAndAnnouncementsRow(
      BuildContext context,
      List recentActivities,
      List recentAnnouncements,
      DashboardProvider dashboardProvider,
      AnnouncementProvider announcementProvider,
      ) {
    return Column(
      children: [
        if (recentActivities.isNotEmpty) ...[
          _buildRecentActivities(context, recentActivities, dashboardProvider),
          const SizedBox(height: 24),
        ],
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.campaign,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Recent Announcements',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/announcements'),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('View All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (announcementProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (recentAnnouncements.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.announcement_outlined,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No announcements available',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentAnnouncements.length,
                    separatorBuilder: (context, index) => const Divider(height: 20),
                    itemBuilder: (context, index) {
                      return AnnouncementCard(
                        announcement: recentAnnouncements[index],
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/announcement-detail',
                          arguments: recentAnnouncements[index],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(
      BuildContext context,
      List recentActivities,
      DashboardProvider provider,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recent Activities',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentActivities.length > 5 ? 5 : recentActivities.length,
              separatorBuilder: (context, index) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final activity = recentActivities[index];
                final iconData = _getActivityIcon(activity.type);
                final color = _getActivityColor(activity.type);

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.8), color],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(iconData, color: Colors.white, size: 22),
                  ),
                  title: Text(
                    activity.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      activity.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      provider.getTimeAgo(activity.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'student':
        return Icons.person_add;
      case 'teacher':
        return Icons.school;
      case 'announcement':
        return Icons.announcement;
      case 'attendance':
        return Icons.check_circle;
      case 'fee':
        return Icons.payment;
      case 'event':
        return Icons.event;
      case 'exam':
        return Icons.quiz;
      case 'library':
        return Icons.book;
      case 'meeting':
        return Icons.people;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'student':
        return Colors.blue;
      case 'teacher':
        return Colors.green;
      case 'announcement':
        return Colors.orange;
      case 'attendance':
        return Colors.purple;
      case 'fee':
        return Colors.teal;
      case 'event':
        return Colors.pink;
      case 'exam':
        return Colors.red;
      case 'library':
        return Colors.brown;
      case 'meeting':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}