import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/dashboard/attendance_summary_card.dart';
import '../../widgets/dashboard/announcement_card.dart';
import '../../widgets/dashboard/notification_badge.dart';
import '../../../data/models/user_model.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    await Future.wait([
      context.read<AnnouncementProvider>().fetchAnnouncements(),
      if (userId != null)
        context.read<NotificationProvider>().fetchNotifications(userId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final announcementProvider = context.watch<AnnouncementProvider>();
    final notificationProvider = context.watch<NotificationProvider>();

    final user = authProvider.currentUser;
    final recentAnnouncements = announcementProvider.announcements.take(3).toList();
    final unreadNotifications = notificationProvider.unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeCard(user?.name ?? 'Teacher'),
              const SizedBox(height: 20),

              // Quick Actions
              _buildQuickActions(context),
              const SizedBox(height: 20),

              // Today's Schedule
              _buildTodaysSchedule(context),
              const SizedBox(height: 20),

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
              const SizedBox(height: 20),

              // Class Statistics
              _buildClassStatistics(context),
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
            Text(
              'Welcome back,',
              style: const TextStyle(
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
              'Ready to inspire minds today!',
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

  Widget _buildQuickActions(BuildContext context) {
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
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildActionCard(
              icon: Icons.how_to_reg,
              label: 'Mark Attendance',
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/teacher-attendance-entry'),
            ),
            _buildActionCard(
              icon: Icons.announcement,
              label: 'Create Post',
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/create-announcement'),
            ),
            _buildActionCard(
              icon: Icons.grade,
              label: 'Grades',
              color: Colors.orange,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Grades feature coming soon')),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.schedule,
              label: 'Timetable',
              color: Colors.purple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Timetable feature coming soon')),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.assignment,
              label: 'Assignments',
              color: Colors.red,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Assignments feature coming soon')),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.people,
              label: 'My Classes',
              color: Colors.teal,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Classes feature coming soon')),
                );
              },
            ),
          ],
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysSchedule(BuildContext context) {
    final todaySchedule = [
      {'time': '9:00 AM', 'subject': 'Mathematics', 'class': 'Grade 10-A'},
      {'time': '10:30 AM', 'subject': 'Physics', 'class': 'Grade 11-B'},
      {'time': '1:00 PM', 'subject': 'Mathematics', 'class': 'Grade 9-C'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Schedule",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todaySchedule.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final schedule = todaySchedule[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  schedule['subject']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(schedule['class']!),
                trailing: Text(
                  schedule['time']!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassStatistics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Students',
                value: '156',
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Classes',
                value: '5',
                icon: Icons.class_,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Avg Attendance',
                value: '92%',
                icon: Icons.check_circle,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Pending Work',
                value: '12',
                icon: Icons.pending_actions,
                color: Colors.red,
              ),
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
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}