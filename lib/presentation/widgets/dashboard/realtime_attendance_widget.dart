// lib/presentation/widgets/dashboard/realtime_attendance_widget.dart
// Add this widget to all dashboards (Admin, Teacher, Student, Parent)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';

class RealtimeAttendanceWidget extends StatefulWidget {
  final String? studentId; // For student/parent dashboards
  final String? classId;   // For teacher/admin dashboards

  const RealtimeAttendanceWidget({
    Key? key,
    this.studentId,
    this.classId,
  }) : super(key: key);

  @override
  State<RealtimeAttendanceWidget> createState() => _RealtimeAttendanceWidgetState();
}

class _RealtimeAttendanceWidgetState extends State<RealtimeAttendanceWidget> {
  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    final attendanceProvider = context.read<AttendanceProvider>();

    if (widget.studentId != null) {
      // Load student-specific attendance
      await attendanceProvider.fetchAttendanceSummary(
        studentId: widget.studentId!,
      );
      await attendanceProvider.fetchStudentAttendance(
        studentId: widget.studentId!,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );
    } else if (widget.classId != null) {
      // Load class attendance for today
      await attendanceProvider.fetchClassAttendance(
        classId: widget.classId!,
        date: DateTime.now(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        if (attendanceProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (widget.studentId != null) {
          return _buildStudentAttendanceCard(attendanceProvider);
        } else if (widget.classId != null) {
          return _buildClassAttendanceCard(attendanceProvider);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStudentAttendanceCard(AttendanceProvider provider) {
    final summary = provider.attendanceSummary;

    if (summary == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No attendance data available'),
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Summary',
                  style: TextStyle(
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
                    color: _getPercentageColor(summary.attendancePercentage)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${summary.attendancePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getPercentageColor(summary.attendancePercentage),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Present',
                    summary.presentDays.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Absent',
                    summary.absentDays.toString(),
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Late',
                    summary.lateDays.toString(),
                    Colors.orange,
                    Icons.access_time,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    summary.totalDays.toString(),
                    Colors.blue,
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassAttendanceCard(AttendanceProvider provider) {
    final records = provider.classAttendanceRecords;

    final presentCount = records.where((r) => r.status == 'present').length;
    final absentCount = records.where((r) => r.status == 'absent').length;
    final lateCount = records.where((r) => r.status == 'late').length;
    final totalCount = records.length;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Attendance",
                  style: TextStyle(
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
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Present',
                    presentCount.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Absent',
                    absentCount.toString(),
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Late',
                    lateCount.toString(),
                    Colors.orange,
                    Icons.access_time,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    totalCount.toString(),
                    Colors.blue,
                    Icons.people,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label,
      String value,
      Color color,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
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
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 75) return Colors.blue;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}

// ==================== HOW TO USE IN DASHBOARDS ====================

/*
// FOR ADMIN DASHBOARD - Add after Key Performance Indicators:
RealtimeAttendanceWidget(
  classId: null, // null means all classes
),

// FOR TEACHER DASHBOARD - Add after Quick Actions:
RealtimeAttendanceWidget(
  classId: '10-A', // teacher's class
),

// FOR STUDENT DASHBOARD - Add after Quick Actions:
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return RealtimeAttendanceWidget(
      studentId: authProvider.currentUser?.id,
    );
  },
),

// FOR PARENT DASHBOARD - Add after Children Selector:
RealtimeAttendanceWidget(
  studentId: _selectedChildId,
),
*/