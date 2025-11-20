// lib/presentation/screens/academic/teacher_attendance_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/student_provider.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/attendance_model.dart';

class TeacherAttendanceEntryScreen extends StatefulWidget {
  const TeacherAttendanceEntryScreen({Key? key}) : super(key: key);

  @override
  State<TeacherAttendanceEntryScreen> createState() => _TeacherAttendanceEntryScreenState();
}

class _TeacherAttendanceEntryScreenState extends State<TeacherAttendanceEntryScreen> {
  // Form controllers
  String? _selectedClass;
  String? _selectedSection;
  DateTime _selectedDate = DateTime.now();
  String? _selectedSubject;
  int? _selectedPeriod;

  // Available options
  final List<String> _classes = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  final List<String> _subjects = ['Mathematics', 'Science', 'English', 'Hindi', 'Social Studies', 'Computer Science'];
  final List<int> _periods = [1, 2, 3, 4, 5, 6, 7, 8];

  // Student attendance tracking
  Map<String, String> _studentAttendanceStatus = {};
  Map<String, String> _studentRemarks = {};
  List<StudentModel> _filteredStudents = [];

  bool _isLoading = false;
  bool _attendanceAlreadyMarked = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
    });
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);

    final studentProvider = context.read<StudentProvider>();
    await studentProvider.loadStudents();

    setState(() => _isLoading = false);
  }

  void _filterStudents() {
    final studentProvider = context.read<StudentProvider>();

    if (_selectedClass != null && _selectedSection != null) {
      _filteredStudents = studentProvider.allStudents.where((student) {
        bool matchesClass = student.className == _selectedClass;
        bool matchesSection = student.section == _selectedSection;
        bool matchesSearch = _searchQuery.isEmpty ||
            student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            student.rollNumber.toString().contains(_searchQuery);

        return matchesClass && matchesSection && matchesSearch;
      }).toList();

      // Sort by roll number
      _filteredStudents.sort((a, b) => a.rollNumber.compareTo(b.rollNumber));

      // Initialize attendance status for new students
      for (var student in _filteredStudents) {
        _studentAttendanceStatus[student.studentId] ??= 'present';
      }

      // Check if attendance is already marked
      _checkExistingAttendance();
    } else {
      _filteredStudents = [];
    }

    setState(() {});
  }

  Future<void> _checkExistingAttendance() async {
    if (_selectedClass == null || _selectedSection == null) return;

    final attendanceProvider = context.read<AttendanceProvider>();
    final classId = '$_selectedClass-$_selectedSection';

    final isMarked = await attendanceProvider.isAttendanceMarked(
      classId: classId,
      date: _selectedDate,
      subject: _selectedSubject,
      period: _selectedPeriod?.toString(),
    );

    setState(() {
      _attendanceAlreadyMarked = isMarked;
    });

    if (isMarked) {
      // Load existing attendance
      await _loadExistingAttendance();
    }
  }

  Future<void> _loadExistingAttendance() async {
    final attendanceProvider = context.read<AttendanceProvider>();
    final classId = '$_selectedClass-$_selectedSection';

    await attendanceProvider.fetchClassAttendance(
      classId: classId,
      date: _selectedDate,
      subject: _selectedSubject,
      period: _selectedPeriod?.toString(),
    );

    // Pre-fill attendance status from existing records
    for (var record in attendanceProvider.classAttendanceRecords) {
      _studentAttendanceStatus[record.studentId] = record.status;
      if (record.remarks != null) {
        _studentRemarks[record.studentId] = record.remarks!;
      }
    }

    setState(() {});
  }

  void _markAllPresent() {
    for (var student in _filteredStudents) {
      _studentAttendanceStatus[student.studentId] = 'present';
    }
    setState(() {});
  }

  void _markAllAbsent() {
    for (var student in _filteredStudents) {
      _studentAttendanceStatus[student.studentId] = 'absent';
    }
    setState(() {});
  }

  Future<void> _submitAttendance() async {
    if (_selectedClass == null || _selectedSection == null) {
      _showErrorDialog('Please select class and section');
      return;
    }

    if (_filteredStudents.isEmpty) {
      _showErrorDialog('No students found for the selected class');
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      _showErrorDialog('User not authenticated');
      setState(() => _isLoading = false);
      return;
    }

    // Prepare student entries
    final List<StudentAttendanceEntry> studentEntries = _filteredStudents.map((student) {
      return StudentAttendanceEntry(
        studentId: student.studentId,
        studentName: student.name,
        rollNumber: student.rollNumber.toString(),
        status: _studentAttendanceStatus[student.studentId] ?? 'present',
        remarks: _studentRemarks[student.studentId],
      );
    }).toList();

    // Submit attendance
    final success = await attendanceProvider.markBulkAttendance(
      classId: '$_selectedClass-$_selectedSection',
      className: _selectedClass!,
      section: _selectedSection!,
      date: _selectedDate,
      students: studentEntries,
      markedBy: currentUser.id,
      markedByName: currentUser.name,
      subject: _selectedSubject,
      period: _selectedPeriod?.toString(),
    );

    setState(() => _isLoading = false);

    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorDialog(attendanceProvider.error ?? 'Failed to submit attendance');
    }
  }

  Future<bool> _showConfirmationDialog() async {
    final presentCount = _studentAttendanceStatus.values.where((s) => s == 'present').length;
    final absentCount = _studentAttendanceStatus.values.where((s) => s == 'absent').length;
    final lateCount = _studentAttendanceStatus.values.where((s) => s == 'late').length;

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Class: $_selectedClass-$_selectedSection'),
            Text('Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}'),
            if (_selectedSubject != null) Text('Subject: $_selectedSubject'),
            if (_selectedPeriod != null) Text('Period: $_selectedPeriod'),
            const SizedBox(height: 16),
            const Text('Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Present: $presentCount', style: const TextStyle(color: Colors.green)),
            Text('Absent: $absentCount', style: const TextStyle(color: Colors.red)),
            Text('Late: $lateCount', style: const TextStyle(color: Colors.orange)),
            const SizedBox(height: 16),
            Text(
              _attendanceAlreadyMarked
                  ? 'This will update existing attendance records.'
                  : 'Do you want to submit attendance?',
              style: TextStyle(
                color: _attendanceAlreadyMarked ? Colors.orange : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Success'),
          ],
        ),
        content: const Text('Attendance submitted successfully!\n\nParents of absent students will be notified.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          if (_filteredStudents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: _markAllPresent,
              tooltip: 'Mark All Present',
            ),
          if (_filteredStudents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: _markAllAbsent,
              tooltip: 'Mark All Absent',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Filter Section
          _buildFilterSection(),

          // Warning banner if already marked
          if (_attendanceAlreadyMarked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Attendance already marked for this date. You can update it.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Search bar
          if (_filteredStudents.isNotEmpty)
            _buildSearchBar(),

          // Student list
          Expanded(
            child: _filteredStudents.isEmpty
                ? _buildEmptyState()
                : _buildStudentList(),
          ),
        ],
      ),
      bottomNavigationBar: _filteredStudents.isNotEmpty
          ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text(
              'Submit Attendance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class and Section Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedClass,
                  decoration: InputDecoration(
                    labelText: 'Class *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _classes.map((cls) {
                    return DropdownMenuItem(
                      value: cls,
                      child: Text('Class $cls'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value;
                      _filterStudents();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSection,
                  decoration: InputDecoration(
                    labelText: 'Section *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _sections.map((section) {
                    return DropdownMenuItem(
                      value: section,
                      child: Text('Section $section'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSection = value;
                      _filterStudents();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date Picker
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                  _checkExistingAttendance();
                });
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              child: Text(
                DateFormat('dd MMM yyyy').format(_selectedDate),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Subject and Period Row (Optional)
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  decoration: InputDecoration(
                    labelText: 'Subject (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Subjects'),
                    ),
                    ..._subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;
                      _checkExistingAttendance();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedPeriod,
                  decoration: InputDecoration(
                    labelText: 'Period (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: [
                    const DropdownMenuItem(
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
                    setState(() {
                      _selectedPeriod = value;
                      _checkExistingAttendance();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by name or roll number...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterStudents();
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedClass == null || _selectedSection == null
                ? 'Please select class and section'
                : 'No students found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        final status = _studentAttendanceStatus[student.studentId] ?? 'present';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _getStatusColor(status).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(status).withOpacity(0.2),
              child: Text(
                student.rollNumber.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(status),
                ),
              ),
            ),
            title: Text(
              student.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'ID: ${student.studentId}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            trailing: _buildStatusChip(status),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mark Attendance:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusButton('present', student.studentId),
                        _buildStatusButton('absent', student.studentId),
                        _buildStatusButton('late', student.studentId),
                        _buildStatusButton('excused', student.studentId),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Remarks (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Add any remarks...',
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        _studentRemarks[student.studentId] = value;
                      },
                      controller: TextEditingController(
                        text: _studentRemarks[student.studentId] ?? '',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusButton(String status, String studentId) {
    final isSelected = _studentAttendanceStatus[studentId] == status;

    return InkWell(
      onTap: () {
        setState(() {
          _studentAttendanceStatus[studentId] = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? _getStatusColor(status)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getStatusColor(status),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          status.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : _getStatusColor(status),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
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