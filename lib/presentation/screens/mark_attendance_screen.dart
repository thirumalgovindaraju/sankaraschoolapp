// lib/presentation/screens/attendance/mark_attendance_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/attendance_model.dart';
import '../../presentation//providers/academic_provider.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final String classId;
  final String section;

  const MarkAttendanceScreen({
    super.key,
    required this.classId,
    required this.section,
  });

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _attendanceStatus = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);

    final provider = context.read<AcademicProvider>();
    await provider.fetchClassAttendance(widget.classId, _selectedDate);

    // Initialize status map
    for (var record in provider.attendanceRecords) {
      _attendanceStatus[record.studentId] = record.status;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadAttendance();
    }
  }

  Future<void> _submitAttendance() async {
    if (_attendanceStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please mark attendance for at least one student')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<AcademicProvider>();
    final students = provider.attendanceRecords.map((record) {
      return StudentAttendanceEntry(
        studentId: record.studentId,
        studentName: record.studentName,
        rollNumber: record.rollNumber,
        status: _attendanceStatus[record.studentId] ?? 'present',
      );
    }).toList();

    final success = await provider.markBulkAttendance(
      classId: widget.classId,
      className: widget.classId,
      section: widget.section,
      date: _selectedDate,
      markedBy: 'TEACHER_ID', // Replace with actual teacher ID
      markedByName: 'Teacher Name', // Replace with actual teacher name
      students: students,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance marked successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to mark attendance')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Attendance - ${widget.classId} ${widget.section}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<AcademicProvider>(
        builder: (context, provider, child) {
          if (provider.attendanceRecords.isEmpty) {
            return const Center(
              child: Text('No students found for this class'),
            );
          }

          return Column(
            children: [
              // Date selector
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _selectDate,
                      child: const Text('Change Date'),
                    ),
                  ],
                ),
              ),

              // Quick action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            for (var record in provider.attendanceRecords) {
                              _attendanceStatus[record.studentId] = 'present';
                            }
                          });
                        },
                        child: const Text('Mark All Present'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            for (var record in provider.attendanceRecords) {
                              _attendanceStatus[record.studentId] = 'absent';
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Mark All Absent'),
                      ),
                    ),
                  ],
                ),
              ),

              // Student list
              Expanded(
                child: ListView.builder(
                  itemCount: provider.attendanceRecords.length,
                  itemBuilder: (context, index) {
                    final student = provider.attendanceRecords[index];
                    final currentStatus = _attendanceStatus[student.studentId] ?? 'present';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(student.rollNumber),
                        ),
                        title: Text(student.studentName),
                        subtitle: Text('Roll No: ${student.rollNumber}'),
                        trailing: DropdownButton<String>(
                          value: currentStatus,
                          items: const [
                            DropdownMenuItem(
                              value: 'present',
                              child: Text('Present'),
                            ),
                            DropdownMenuItem(
                              value: 'absent',
                              child: Text('Absent'),
                            ),
                            DropdownMenuItem(
                              value: 'late',
                              child: Text('Late'),
                            ),
                            DropdownMenuItem(
                              value: 'excused',
                              child: Text('Excused'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _attendanceStatus[student.studentId] = value;
                              });
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Submit button
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitAttendance,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Submit Attendance',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}