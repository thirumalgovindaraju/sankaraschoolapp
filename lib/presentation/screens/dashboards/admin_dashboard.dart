// lib/presentation/screens/dashboards/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/dashboard/announcement_card.dart';
import '../../widgets/dashboard/notification_badge.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    await dashboardProvider.refreshDashboard();

    await Future.wait([
      context.read<DashboardProvider>().refreshDashboard(),
      context.read<AnnouncementProvider>().fetchAnnouncements(),
      if (userId != null)
        context.read<NotificationProvider>().fetchNotifications(userId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final announcementProvider = context.watch<AnnouncementProvider>();
    final notificationProvider = context.watch<NotificationProvider>();

    final user = authProvider.currentUser;
    final stats = dashboardProvider.stats;
    final recentActivities = dashboardProvider.recentActivities;
    final recentAnnouncements = announcementProvider.announcements.take(3).toList();
    final unreadNotifications = notificationProvider.unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          NotificationBadge(
            count: unreadNotifications,
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: dashboardProvider.isLoading && stats == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeCard(user?.name ?? 'Admin'),
              const SizedBox(height: 20),

              // Key Statistics
              if (stats != null) ...[
                _buildKeyStatistics(context, stats, dashboardProvider),
                const SizedBox(height: 20),
              ],

              // Quick Actions
              _buildQuickActions(context),
              const SizedBox(height: 20),

              // Attendance & Fee Charts
              if (stats != null) ...[
                _buildChartsRow(context, stats),
                const SizedBox(height: 20),
              ],

              // Recent Activities
              if (recentActivities.isNotEmpty) ...[
                _buildRecentActivities(context, recentActivities, dashboardProvider),
                const SizedBox(height: 20),
              ],

              // Recent Announcements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Announcements',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/announcements'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (announcementProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (recentAnnouncements.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No announcements available'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentAnnouncements.length,
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
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-announcement'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Announcement'),
      ),
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back,',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Manage your school efficiently • ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyStatistics(BuildContext context, stats, DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _buildStatCard(
              title: 'Total Students',
              value: provider.formatNumber(stats.totalStudents),
              icon: Icons.people,
              color: Colors.blue,
              trend: provider.getStudentGrowthTrend(),
            ),
            _buildStatCard(
              title: 'Total Teachers',
              value: stats.totalTeachers.toString(),
              icon: Icons.school,
              color: Colors.green,
              trend: provider.getTeacherGrowthTrend(),
            ),
            _buildStatCard(
              title: 'Avg Attendance',
              value: '${stats.averageAttendance.toStringAsFixed(1)}%',
              icon: Icons.check_circle,
              color: Colors.orange,
              trend: provider.getAttendanceTrend(),
            ),
            _buildStatCard(
              title: 'Active Classes',
              value: stats.totalClasses.toString(),
              icon: Icons.class_,
              color: Colors.purple,
              trend: '0%',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    final isPositive = trend.startsWith('+');
    final isNeutral = trend == '0%';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isNeutral
                        ? Colors.grey[200]
                        : (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isNeutral)
                        Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 12,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      const SizedBox(width: 2),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isNeutral
                              ? Colors.grey[600]
                              : (isPositive ? Colors.green : Colors.red),
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
/*
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.person_add, 'label': 'Add Student', 'color': Colors.blue, 'route': '/add-student'},
      {'icon': Icons.school, 'label': 'Add Teacher', 'color': Colors.green, 'route': '/add-teacher'},
      {'icon': Icons.announcement, 'label': 'Post News', 'color': Colors.orange, 'route': '/create-announcement'},
      {'icon': Icons.event, 'label': 'New Event', 'color': Colors.purple, 'route': null},
      {'icon': Icons.assessment, 'label': 'Reports', 'color': Colors.red, 'route': null},
      {'icon': Icons.payment, 'label': 'Fees', 'color': Colors.teal, 'route': null},
      {'icon': Icons.settings, 'label': 'Settings', 'color': Colors.blueGrey, 'route': null},
      {'icon': Icons.support_agent, 'label': 'Support', 'color': Colors.indigo, 'route': '/contact'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              color: action['color'] as Color,
              onTap: () {
                final route = action['route'] as String?;
                if (route != null) {
                  Navigator.pushNamed(context, route);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${action['label']} feature coming soon')),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
*/
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.person_add, 'label': 'Add Student', 'color': Colors.blue, 'route': '/add-student'},
      {'icon': Icons.school, 'label': 'Add Teacher', 'color': Colors.green, 'route': '/add-teacher'},
      {'icon': Icons.announcement, 'label': 'Post News', 'color': Colors.orange, 'route': '/create-announcement'},
      {'icon': Icons.event, 'label': 'New Event', 'color': Colors.purple, 'route': '/events'}, // Changed
      {'icon': Icons.assessment, 'label': 'Reports', 'color': Colors.red, 'route': '/reports'}, // Changed
      {'icon': Icons.payment, 'label': 'Fees', 'color': Colors.teal, 'route': '/fees'}, // Changed
      {'icon': Icons.settings, 'label': 'Settings', 'color': Colors.blueGrey, 'route': '/settings'}, // Changed
      {'icon': Icons.support_agent, 'label': 'Support', 'color': Colors.indigo, 'route': '/contact'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
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

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsRow(BuildContext context, stats) {
    return Row(
      children: [
        Expanded(child: _buildAttendanceChart(context, stats)),
        const SizedBox(width: 12),
        Expanded(child: _buildFeeChart(context, stats)),
      ],
    );
  }

  Widget _buildAttendanceChart(BuildContext context, stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Attendance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%', style: const TextStyle(fontSize: 8));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < stats.weeklyAttendance.length) {
                            return Text(
                              stats.weeklyAttendance[value.toInt()].day,
                              style: const TextStyle(fontSize: 8),
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
                        stats.weeklyAttendance.length,
                            (i) => FlSpot(i.toDouble(), stats.weeklyAttendance[i].percentage),
                      ),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fee Collection',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: stats.totalFeesCollected,
                      color: Colors.green,
                      title: '${stats.feeCollectionRate.toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: stats.totalFeesPending,
                      color: Colors.red,
                      title: '${(100 - stats.feeCollectionRate).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context, List activities, DashboardProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length > 5 ? 5 : activities.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final activity = activities[index];
              final iconData = _getActivityIcon(activity.type);
              final color = _getActivityColor(activity.type);

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: color, size: 20),
                ),
                title: Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(activity.description, style: const TextStyle(fontSize: 12)),
                trailing: Text(
                  provider.getTimeAgo(activity.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'student': return Icons.person_add;
      case 'teacher': return Icons.school;
      case 'announcement': return Icons.announcement;
      case 'attendance': return Icons.check_circle;
      case 'fee': return Icons.payment;
      case 'event': return Icons.event;
      case 'exam': return Icons.quiz;
      case 'library': return Icons.book;
      case 'meeting': return Icons.people;
      default: return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'student': return Colors.blue;
      case 'teacher': return Colors.green;
      case 'announcement': return Colors.orange;
      case 'attendance': return Colors.purple;
      case 'fee': return Colors.teal;
      case 'event': return Colors.pink;
      case 'exam': return Colors.red;
      case 'library': return Colors.brown;
      case 'meeting': return Colors.indigo;
      default: return Colors.grey;
    }
  }
}