// lib/presentation/widgets/academic/attendance_calendar_widget.dart

import 'package:flutter/material.dart';
import '../../../data/models/attendance_model.dart';
import '../../../core/constants/app_colors.dart';

class AttendanceCalendarWidget extends StatelessWidget {
  final List<AttendanceModel> attendanceRecords;
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChanged;

  const AttendanceCalendarWidget({
    Key? key,
    required this.attendanceRecords,
    required this.selectedMonth,
    required this.onMonthChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthSelector(),
            const SizedBox(height: 16),
            _buildWeekdayHeaders(),
            const SizedBox(height: 8),
            _buildCalendarGrid(),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final newMonth = DateTime(
              selectedMonth.year,
              selectedMonth.month - 1,
            );
            onMonthChanged(newMonth);
          },
        ),
        Text(
          _getMonthYearString(selectedMonth),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            final newMonth = DateTime(
              selectedMonth.year,
              selectedMonth.month + 1,
            );
            onMonthChanged(newMonth);
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(selectedMonth);
    final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    final List<Widget> dayWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 1; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(selectedMonth.year, selectedMonth.month, day);
      final attendance = _getAttendanceForDate(date);
      dayWidgets.add(_buildDayCell(day, attendance, date));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(int day, AttendanceModel? attendance, DateTime date) {
    final isToday = _isToday(date);
    final isFuture = date.isAfter(DateTime.now());

    Color? backgroundColor;
    Color? textColor;

    if (attendance != null && !isFuture) {
      switch (attendance.status.toLowerCase()) {
        case 'present':
          backgroundColor = AppColors.present.withOpacity(0.2);
          textColor = AppColors.present;
          break;
        case 'absent':
          backgroundColor = AppColors.absent.withOpacity(0.2);
          textColor = AppColors.absent;
          break;
        case 'late':
          backgroundColor = AppColors.late.withOpacity(0.2);
          textColor = AppColors.late;
          break;
        case 'excused':
          backgroundColor = AppColors.excused.withOpacity(0.2);
          textColor = AppColors.excused;
          break;
      }
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            color: textColor ?? (isFuture ? Colors.grey[400] : Colors.black),
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Present', AppColors.present),
        _buildLegendItem('Absent', AppColors.absent),
        _buildLegendItem('Late', AppColors.late),
        _buildLegendItem('Excused', AppColors.excused),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  AttendanceModel? _getAttendanceForDate(DateTime date) {
    try {
      return attendanceRecords.firstWhere(
            (record) =>
        record.date.year == date.year &&
            record.date.month == date.month &&
            record.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}