// lib/presentation/screens/teacher/teacher_attendance_entry_screen.dart
// UPDATED VERSION - Matches test_data.json structure

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/student_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';

class TeacherAttendanceEntryScreen extends StatefulWidget {
  const TeacherAttendanceEntryScreen({Key? key}) : super(key: key);

  @override
  State<TeacherAttendanceEntryScreen> createState() => _TeacherAttendanceEntryScreenState();
}

class _TeacherAttendanceEntryScreenState extends State<TeacherAttendanceEntryScreen> {
  String? _selectedClass;
  String? _selectedSection;
  String? _selectedSubject;
  int? _selectedPeriod;
  DateTime _selectedDate = DateTime.now();

  final Map<String, String> _attendanceStatus = {};
  List<StudentModel> _students = [];
  bool _isLoading = false;
  bool _hasLoadedStudents = false;

  // ✅ UPDATED: Match test_data.json structure (Pre-KG to 10th)
  final List<String> _classes = [
    'Pre-KG', 'LKG', 'UKG', '1', '2', '3', '4', '5',
    '6', '7', '8', '9', '10'
  ];
  final List<String> _sections = ['A', 'B'];
  final List<int> _periods = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
  }

  void _initializeDefaults() {
    // Set default class to Pre-KG-A (first class in test_data.json)
    _selectedClass = 'Pre-KG';
    _selectedSection = 'A';
  }

  Future<void> _loadStudents() async {
    if (_selectedClass == null || _selectedSection == null) return;

    setState(() {
      _isLoading = true;
      _hasLoadedStudents = false;
    });

    try {
      final studentProvider = context.read<StudentProvider>();

      // Load all students first
      await studentProvider.loadStudents();

      // Filter students by class and section
      final classId = '$_selectedClass-$_selectedSection';
      final allStudents = studentProvider.allStudents ?? [];

      print('🔍 Filtering students for class: $_selectedClass, section: $_selectedSection');

      // Filter students correctly matching test_data.json structure
      _students = allStudents.where((student) {
        final matchesClass = student.currentClass == _selectedClass;
        final matchesSection = student.section == _selectedSection;

        if (matchesClass && matchesSection) {
          print('✅ Found student: ${student.name} in $_selectedClass-$_selectedSection');
        }

        return matchesClass && matchesSection;
      }).toList();

      // Sort by roll number
      _students.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));

      print('📊 Total students found: ${_students.length}');

      setState(() {
        _hasLoadedStudents = true;

        // Initialize all students as present by default
        _attendanceStatus.clear();
        for (var student in _students) {
          _attendanceStatus[student.studentId] = 'present';
        }
      });

      // Check if attendance is already marked
      final attendanceProvider = context.read<AttendanceProvider>();
      final isMarked = await attendanceProvider.isAttendanceMarked(
        classId: classId,
        date: _selectedDate,
        subject: _selectedSubject,
        period: _selectedPeriod?.toString(),
      );

      if (isMarked && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠️ Attendance already marked for this period'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Edit',
              textColor: Colors.white,
              onPressed: () {
                _loadExistingAttendance();
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error loading students: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading students: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadExistingAttendance() async {
    if (_selectedClass == null || _selectedSection == null) return;

    final attendanceProvider = context.read<AttendanceProvider>();
    await attendanceProvider.fetchClassAttendance(
      classId: '$_selectedClass-$_selectedSection',
      date: _selectedDate,
      subject: _selectedSubject,
      period: _selectedPeriod?.toString(),
    );

    final records = attendanceProvider.classAttendanceRecords;
    setState(() {
      for (var record in records) {
        _attendanceStatus[record.studentId] = record.status;
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _hasLoadedStudents = false;
      });
      if (_selectedClass != null && _selectedSection != null) {
        _loadStudents();
      }
    }
  }

  Future<void> _submitAttendance() async {
    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class first')),
      );
      return;
    }

    if (_attendanceStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please mark attendance for at least one student')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final teacherId = authProvider.currentUser?.id ?? 'unknown';
    final teacherName = authProvider.currentUser?.name ?? 'Unknown Teacher';

    setState(() => _isLoading = true);

    try {
      final attendanceProvider = context.read<AttendanceProvider>();

      final studentEntries = _students.map((student) {
        return StudentAttendanceEntry(
          studentId: student.studentId,
          studentName: student.name,
          rollNumber: student.rollNumber.toString(),
          status: _attendanceStatus[student.studentId] ?? 'present',
        );
      }).toList();

      final success = await attendanceProvider.markBulkAttendance(
        classId: '$_selectedClass-$_selectedSection',
        className: _selectedClass!,
        section: _selectedSection!,
        date: _selectedDate,
        students: studentEntries,
        markedBy: teacherId,
        markedByName: teacherName,
        subject: _selectedSubject,
        period: _selectedPeriod?.toString(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Attendance marked successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(attendanceProvider.error ?? 'Failed to mark attendance'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _markAllPresent() {
    setState(() {
      for (var student in _students) {
        _attendanceStatus[student.studentId] = 'present';
      }
    });
  }

  void _markAllAbsent() {
    setState(() {
      for (var student in _students) {
        _attendanceStatus[student.studentId] = 'absent';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selection Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Date Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.edit),
                      label: const Text('Change'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Class and Section Selection
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: _selectedClass,
                        items: _classes.map((cls) {
                          return DropdownMenuItem(
                            value: cls,
                            child: Text('Class $cls'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClass = value;
                            _hasLoadedStudents = false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Section',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: _selectedSection,
                        items: _sections.map((section) {
                          return DropdownMenuItem(
                            value: section,
                            child: Text('Section $section'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSection = value;
                            _hasLoadedStudents = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subject and Period (Optional)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Subject (Optional)',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          _selectedSubject = value.isEmpty ? null : value;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Period (Optional)',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: _selectedPeriod,
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('All Periods'),
                          ),
                          ..._periods.map((period) {
                            return DropdownMenuItem(
                              value: period,
                              child: Text('Period $period'),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedPeriod = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Load Students Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_selectedClass != null && _selectedSection != null)
                        ? _loadStudents
                        : null,
                    icon: const Icon(Icons.search),
                    label: const Text('Load Students'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Students List
          if (_hasLoadedStudents) ...[
            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _markAllPresent,
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      label: const Text('Mark All Present'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _markAllAbsent,
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text('Mark All Absent'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Student Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Total Students: ${_students.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Students List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _students.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No students found for this class',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _students.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final student = _students[index];
                  final currentStatus = _attendanceStatus[student.studentId] ?? 'present';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(currentStatus),
                        child: Text(
                          student.rollNumber.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('Roll No: ${student.rollNumber} • Class: ${student.currentClass}-${student.section}'),
                      trailing: DropdownButton<String>(
                        value: currentStatus,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'present',
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Text('Present'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'absent',
                            child: Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Absent'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'late',
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.orange, size: 20),
                                SizedBox(width: 8),
                                Text('Late'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'excused',
                            child: Row(
                              children: [
                                Icon(Icons.event_note, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text('Excused'),
                              ],
                            ),
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

            // Submit Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitAttendance,
                  icon: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Submitting...' : 'Submit Attendance'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ] else if (!_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Select class and section, then click "Load Students"',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'excused':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}