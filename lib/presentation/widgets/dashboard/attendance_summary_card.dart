// lib/presentation/widgets/dashboard/attendance_summary_card.dart

import 'package:flutter/material.dart';
import '../../../data/models/attendance_summary_model.dart';
import '../../../core/constants/app_colors.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final AttendanceSummaryModel? summary;
  final bool isLoading;
  final double attendancePercentage; // 0.0..1.0
  final int presentDays;
  final int totalDays;
  final int absentDays;
  final VoidCallback? onTap;

  const AttendanceSummaryCard({
    super.key,
    required this.attendancePercentage,
    required this.presentDays,
    required this.totalDays,
    required this.absentDays,
    required this.isLoading,
    required this.summary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (summary == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No attendance data available')),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    color: _getPercentageColor(summary!.attendancePercentage)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${summary!.attendancePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getPercentageColor(summary!.attendancePercentage),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Present',
                    summary!.presentDays.toString(),
                    AppColors.present,
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Absent',
                    summary!.absentDays.toString(),
                    AppColors.absent,
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
                    summary!.lateDays.toString(),
                    AppColors.late,
                    Icons.access_time,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Excused',
                    summary!.excusedDays.toString(),
                    AppColors.excused,
                    Icons.event_note,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Days',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  summary!.totalDays.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 75) return AppColors.info;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }
}