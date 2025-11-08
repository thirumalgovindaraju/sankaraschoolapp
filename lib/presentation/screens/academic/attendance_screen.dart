// lib/presentation/screens/academic/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/dashboard/attendance_calendar_widget.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';

class AttendanceScreen extends StatefulWidget {
  final UserModel user;

  const AttendanceScreen({
    super.key,
    required this.user,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  void _loadAttendance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final academicProvider = context.read<AcademicProvider>();
      academicProvider.fetchStudentAttendance(
        widget.user.id,
        startDate: _startDate,
        endDate: _endDate,
      );
      academicProvider.fetchAttendanceSummary(
        widget.user.id,
        startDate: _startDate,
        endDate: _endDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<AcademicProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingAttendance) {
            return const LoadingIndicator();
          }

          if (provider.attendanceError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    provider.attendanceError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAttendance,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final attendanceRecords = provider.attendanceRecords;
          final summary = provider.attendanceSummary;

          return RefreshIndicator(
            onRefresh: () async => _loadAttendance(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  if (summary != null) _buildSummaryCard(summary),
                  const SizedBox(height: 24),

                  // Calendar Widget
                  AttendanceCalendarWidget(
                    attendanceRecords: attendanceRecords,
                    selectedMonth: _selectedMonth,
                    onMonthChanged: (month) {
                      setState(() {
                        _selectedMonth = month;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Attendance List
                  const Text(
                    'Attendance History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (attendanceRecords.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No attendance records found',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...attendanceRecords.map((record) {
                      return _buildAttendanceCard(record);
                    }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(summary) {
    final percentage = summary.percentage;
    final presentDays = summary.presentDays;
    final absentDays = summary.absentDays;
    final totalDays = summary.totalDays;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              'Attendance Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Present', presentDays.toString(), Icons.check_circle, Colors.green[300]!),
                _buildStat('Absent', absentDays.toString(), Icons.cancel, Colors.red[300]!),
                _buildStat('Total', totalDays.toString(), Icons.calendar_today, Colors.blue[300]!),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                '${percentage.toStringAsFixed(1)}% Attendance',
                style: TextStyle(
                  color: percentage >= 75 ? Colors.green[700] : Colors.red[700],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(record) {
    Color statusColor;
    IconData statusIcon;

    switch (record.status.toLowerCase()) {
      case 'present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'late':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'half_day':
        statusColor = Colors.blue;
        statusIcon = Icons.timelapse;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          _formatDate(record.date),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Status: ${_capitalizeFirst(record.status)}'),
            if (record.remarks != null && record.remarks!.isNotEmpty)
              Text('Remarks: ${record.remarks}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _capitalizeFirst(record.status),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _showDateDetails(DateTime date, List attendanceRecords) {
    final record = attendanceRecords.firstWhere(
          (r) => r.date.year == date.year && r.date.month == date.month && r.date.day == date.day,
      orElse: () => null,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_formatDate(date)),
        content: record != null
            ? Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${_capitalizeFirst(record.status)}'),
            if (record.remarks != null && record.remarks!.isNotEmpty)
              Text('Remarks: ${record.remarks}'),
          ],
        )
            : const Text('No attendance record for this date'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(_startDate?.toString().split(' ')[0] ?? 'Not set'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                  Navigator.pop(context);
                  _loadAttendance();
                }
              },
            ),
            ListTile(
              title: const Text('End Date'),
              subtitle: Text(_endDate?.toString().split(' ')[0] ?? 'Not set'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                  Navigator.pop(context);
                  _loadAttendance();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
              _loadAttendance();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}