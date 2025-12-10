// lib/presentation/screens/dashboards/teacher_dashboard.dart
// ✅ COMPLETE VERSION with Worksheets Section

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/worksheet_generator_provider.dart'; // ✅ ADDED
import '../../widgets/dashboard/attendance_summary_card.dart';
import '../../widgets/dashboard/announcement_card.dart';
import '../../widgets/dashboard/notification_badge.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/worksheet_generator_model.dart'; // ✅ ADDED
import '../../providers/attendance_provider.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  bool _attendanceLoaded = false;

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
    final userEmail = authProvider.currentUser?.email;
    final userRole = authProvider.currentUser?.role?.name;
    print('📊 Loading teacher dashboard for: $userId');
    print('📧 Teacher email: $userEmail');

    if (!_attendanceLoaded) {
      final classId = '10-A';
      await context.read<AttendanceProvider>().fetchClassAttendance(
        classId: classId,
        date: DateTime.now(),
      );
      if (mounted) {
        setState(() {
          _attendanceLoaded = true;
        });
      }
    }

    await Future.wait([
      context.read<AnnouncementProvider>().fetchAnnouncements(
        userRole: userRole ?? 'teacher',
        userId: userId,
      ),
      if (userEmail != null && userEmail.isNotEmpty)
        context.read<NotificationProvider>().fetchNotifications(userEmail)
      else if (userId != null)
        context.read<NotificationProvider>().fetchNotifications(userId),
      // ✅ Load worksheets
      context.read<WorksheetGeneratorProvider>().loadWorksheets(),
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
        onRefresh: () async {
          setState(() {
            _attendanceLoaded = false;
          });
          await _loadDashboardData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(user?.name ?? 'Teacher'),
              const SizedBox(height: 20),
              _buildQuickActions(context),
              const SizedBox(height: 20),
              _buildTodaysSchedule(context),
              const SizedBox(height: 20),
              Text(
                'Today\'s Attendance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<AttendanceProvider>(
                builder: (context, attendanceProvider, child) {
                  final classId = '10-A';

                  if (!_attendanceLoaded && attendanceProvider.isLoading) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final records = attendanceProvider.classAttendanceRecords;
                  final presentCount = records.where((r) => r.status == 'present').length;
                  final absentCount = records.where((r) => r.status == 'absent').length;
                  final lateCount = records.where((r) => r.status == 'late').length;
                  final totalCount = records.length;

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade50,
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Class $classId',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$totalCount Students',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn('Present', presentCount, Colors.green),
                              _buildStatColumn('Absent', absentCount, Colors.red),
                              _buildStatColumn('Late', lateCount, Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/teacher-attendance-entry',
                              ),
                              icon: const Icon(Icons.edit),
                              label: const Text('Update Attendance'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ✅ MY WORKSHEETS SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Worksheets',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/worksheet-generator'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create New'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Consumer<WorksheetGeneratorProvider>(
                builder: (context, worksheetProvider, child) {
                  if (worksheetProvider.isLoading) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (worksheetProvider.worksheets.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.description, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No worksheets yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create AI-generated worksheets in seconds',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/worksheet-generator'),
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Create Worksheet'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final recentWorksheets = worksheetProvider.worksheets.take(3).toList();

                  return Column(
                    children: [
                      ...recentWorksheets.map((worksheet) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _showWorksheetDetailDialog(worksheet, worksheetProvider),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.purple[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.description,
                                          color: Colors.purple[700],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              worksheet.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              //worksheet.textbookTitle,
                                              worksheet.textbookTitle ?? 'Unknown Textbook',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.download),
                                        onPressed: () {
                                          worksheetProvider.generatePDF(worksheet);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Generating PDF...'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildWorksheetStat(Icons.quiz, '${worksheet.questions.length} Qs', Colors.blue),
                                      const SizedBox(width: 16),
                                      _buildWorksheetStat(Icons.star, '${worksheet.totalMarks} marks', Colors.orange),
                                      const SizedBox(width: 16),
                                      _buildWorksheetStat(Icons.timer, '${worksheet.durationMinutes} min', Colors.green),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      if (worksheetProvider.worksheets.length > 3)
                        TextButton(
                          onPressed: () => _showAllWorksheetsDialog(worksheetProvider),
                          child: const Text('View All Worksheets'),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

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

  // ✅ WORKSHEET HELPER METHODS
  Widget _buildWorksheetStat(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showWorksheetDetailDialog(WorksheetModel worksheet, WorksheetGeneratorProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.description, color: Colors.purple[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(worksheet.title, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Textbook', worksheet.textbookTitle ?? 'Unknown Textbook'),
              _buildDetailRow('Questions', '${worksheet.questions.length}'),
              _buildDetailRow('Total Marks', '${worksheet.totalMarks}'),
              _buildDetailRow('Duration', '${worksheet.durationMinutes} minutes'),
              _buildDetailRow('Difficulty', worksheet.overallDifficulty.toString().split('.').last),
              const SizedBox(height: 16),
              const Text('Topics Covered:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...worksheet.topicNames.map((name) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(child: Text(name)),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              provider.generatePDF(worksheet);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Generating PDF...'), backgroundColor: Colors.green),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  void _showAllWorksheetsDialog(WorksheetGeneratorProvider provider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          child: Column(
            children: [
              AppBar(
                title: const Text('All Worksheets'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.worksheets.length,
                  itemBuilder: (context, index) {
                    final worksheet = provider.worksheets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(Icons.description, color: Colors.purple[700]),
                        title: Text(worksheet.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${worksheet.questions.length} questions • ${worksheet.totalMarks} marks'),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => provider.generatePDF(worksheet),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showWorksheetDetailDialog(worksheet, provider);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(
            label == 'Present' ? Icons.check_circle : label == 'Absent' ? Icons.cancel : Icons.access_time,
            color: color,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildWelcomeCard(String name) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 4),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Ready to inspire minds today!', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
              icon: Icons.auto_awesome,
              label: 'AI Worksheet',
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/worksheet-generator'),
            ),
            _buildActionCard(icon: Icons.grade, label: 'Grades', color: Colors.orange, onTap: () {}),
            _buildActionCard(icon: Icons.schedule, label: 'Timetable', color: Colors.purple.shade300, onTap: () {}),
            _buildActionCard(icon: Icons.assignment, label: 'Assignments', color: Colors.red, onTap: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700])),
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
        Text("Today's Schedule", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  child: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(schedule['subject']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(schedule['class']!),
                trailing: Text(schedule['time']!, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
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
        Text('Class Statistics', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(title: 'Total Students', value: '156', icon: Icons.people, color: Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(title: 'Classes', value: '5', icon: Icons.class_, color: Colors.green)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(title: 'Avg Attendance', value: '92%', icon: Icons.check_circle, color: Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(title: 'Pending Work', value: '12', icon: Icons.pending_actions, color: Colors.red)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}