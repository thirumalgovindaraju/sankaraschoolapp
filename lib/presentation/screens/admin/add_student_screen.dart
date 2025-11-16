// lib/presentation/screens/admin/add_student_screen.dart (UPDATED)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../data/models/student_model.dart';
import '../../../data/services/activity_service.dart';


class AddStudentScreen extends StatefulWidget {
  final Map<String, dynamic>? studentData;

  const AddStudentScreen({Key? key, this.studentData}) : super(key: key);

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _rollNumberController = TextEditingController();

  // Parent Details
  final _fatherNameController = TextEditingController();
  final _fatherPhoneController = TextEditingController();
  final _fatherEmailController = TextEditingController();
  final _fatherOccupationController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _motherPhoneController = TextEditingController();
  final _motherEmailController = TextEditingController();
  final _motherOccupationController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedClass = 'Pre-KG';
  String _selectedSection = 'A';
  String _selectedGender = 'Male';
  bool _isLoading = false;

  final List<String> _classes = [
    'Pre-KG', 'LKG', 'UKG', '1st', '2nd', '3rd', '4th',
    '5th', '6th', '7th', '8th', '9th', '10th'
  ];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    if (widget.studentData != null) {
      _loadStudentData();
    }
    if (_bloodGroupController.text.isEmpty) {
      _bloodGroupController.text = 'A+';
    }
  }

  void _loadStudentData() {
    final data = widget.studentData!;
    _nameController.text = data['name'] ?? '';
    _emailController.text = data['email'] ?? '';
    _dobController.text = data['date_of_birth'] ?? '';
    _bloodGroupController.text = data['blood_group'] ?? 'A+';
    _rollNumberController.text = data['roll_number']?.toString() ?? '';
    _selectedClass = data['class'] ?? 'Pre-KG';
    _selectedSection = data['section'] ?? 'A';
    _selectedGender = data['gender'] ?? 'Male';

    final parentDetails = data['parent_details'] ?? {};
    _fatherNameController.text = parentDetails['father_name'] ?? '';
    _fatherPhoneController.text = parentDetails['father_phone'] ?? '';
    _fatherEmailController.text = parentDetails['father_email'] ?? '';
    _fatherOccupationController.text = parentDetails['father_occupation'] ?? '';
    _motherNameController.text = parentDetails['mother_name'] ?? '';
    _motherPhoneController.text = parentDetails['mother_phone'] ?? '';
    _motherEmailController.text = parentDetails['mother_email'] ?? '';
    _motherOccupationController.text = parentDetails['mother_occupation'] ?? '';
    _addressController.text = data['address'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _bloodGroupController.dispose();
    _rollNumberController.dispose();
    _fatherNameController.dispose();
    _fatherPhoneController.dispose();
    _fatherEmailController.dispose();
    _fatherOccupationController.dispose();
    _motherNameController.dispose();
    _motherPhoneController.dispose();
    _motherEmailController.dispose();
    _motherOccupationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  String _generateStudentId() {
    final now = DateTime.now();
    return 'STU${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecond.toString().padLeft(3, '0')}';
  }
/*
  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final studentProvider = context.read<StudentProvider>();
      final activityService = ActivityService(); // 🔥 NEW

      final parentDetails = ParentDetails(
        fatherName: _fatherNameController.text.trim(),
        fatherPhone: _fatherPhoneController.text.trim(),
        fatherEmail: _fatherEmailController.text.trim(),
        fatherOccupation: _fatherOccupationController.text.trim(),
        motherName: _motherNameController.text.trim(),
        motherPhone: _motherPhoneController.text.trim(),
        motherEmail: _motherEmailController.text.trim(),
        motherOccupation: _motherOccupationController.text.trim(),
      );

      bool success = await studentProvider.addStudent(newStudent);
      // 🔥 ADD THIS BLOCK
      if (success && widget.studentData == null) {  // Only for new students
        await activityService.logStudentAdmission(
          _nameController.text.trim(),
          '$_selectedClass-$_selectedSection',
        );

        if (mounted) {
          await context.read<DashboardProvider>().refreshDashboard();
        }
      }

      final studentName = _nameController.text.trim();
      final className = '$_selectedClass-$_selectedSection';

      if (widget.studentData != null) {
        // UPDATE existing student
        final updatedStudent = StudentModel(
          studentId: widget.studentData!['student_id'],
          name: studentName,
          email: _emailController.text.trim(),
          className: _selectedClass,
          section: _selectedSection,
          rollNumber: int.tryParse(_rollNumberController.text.trim()) ?? 1,
          dateOfBirth: _dobController.text.trim(),
          bloodGroup: _bloodGroupController.text.trim(),
          gender: _selectedGender,
          address: _addressController.text.trim(),
          admissionDate: widget.studentData!['admission_date'] ?? DateTime.now().toIso8601String().split('T')[0],
          parentDetails: parentDetails,
        );

        success = await studentProvider.updateStudent(updatedStudent);
      } else {
        // ADD new student
        final newStudent = StudentModel(
          studentId: _generateStudentId(),
          name: studentName,
          email: _emailController.text.trim(),
          className: _selectedClass,
          section: _selectedSection,
          rollNumber: int.tryParse(_rollNumberController.text.trim()) ?? 1,
          dateOfBirth: _dobController.text.trim(),
          bloodGroup: _bloodGroupController.text.trim(),
          gender: _selectedGender,
          address: _addressController.text.trim(),
          admissionDate: DateTime.now().toIso8601String().split('T')[0],
          parentDetails: parentDetails,
        );

        success = await studentProvider.addStudent(newStudent);

        // 🔥 NEW: Log activity for new student admission
        if (success) {
          await activityService.logStudentAdmission(studentName, className);
        }
      }

      // 🔥 NEW: Refresh dashboard after success
      if (success && mounted) {
        await context.read<DashboardProvider>().refreshDashboard();
      }

      setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(widget.studentData != null
                    ? 'Student updated successfully'
                    : 'Student added successfully'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text('Failed to ${widget.studentData != null ? 'update' : 'add'} student'),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
*/
  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final studentProvider = context.read<StudentProvider>();
      final activityService = ActivityService();

      final parentDetails = ParentDetails(
        fatherName: _fatherNameController.text.trim(),
        fatherPhone: _fatherPhoneController.text.trim(),
        fatherEmail: _fatherEmailController.text.trim(),
        fatherOccupation: _fatherOccupationController.text.trim(),
        motherName: _motherNameController.text.trim(),
        motherPhone: _motherPhoneController.text.trim(),
        motherEmail: _motherEmailController.text.trim(),
        motherOccupation: _motherOccupationController.text.trim(),
      );

      final studentName = _nameController.text.trim();
      final className = '$_selectedClass-$_selectedSection';
      bool success;

      if (widget.studentData != null) {
        // UPDATE existing student
        final updatedStudent = StudentModel(
          studentId: widget.studentData!['student_id'],
          name: studentName,
          email: _emailController.text.trim(),
          className: _selectedClass,
          section: _selectedSection,
          rollNumber: int.tryParse(_rollNumberController.text.trim()) ?? 1,
          dateOfBirth: _dobController.text.trim(),
          bloodGroup: _bloodGroupController.text.trim(),
          gender: _selectedGender,
          address: _addressController.text.trim(),
          admissionDate: widget.studentData!['admission_date'] ?? DateTime.now().toIso8601String().split('T')[0],
          parentDetails: parentDetails,
        );

        success = await studentProvider.updateStudent(updatedStudent);
      } else {
        // ADD new student
        final newStudent = StudentModel(
          studentId: _generateStudentId(),
          name: studentName,
          email: _emailController.text.trim(),
          className: _selectedClass,
          section: _selectedSection,
          rollNumber: int.tryParse(_rollNumberController.text.trim()) ?? 1,
          dateOfBirth: _dobController.text.trim(),
          bloodGroup: _bloodGroupController.text.trim(),
          gender: _selectedGender,
          address: _addressController.text.trim(),
          admissionDate: DateTime.now().toIso8601String().split('T')[0],
          parentDetails: parentDetails,
        );

        success = await studentProvider.addStudent(newStudent);

        // Log activity for new student admission
        if (success) {
          await activityService.logStudentAdmission(studentName, className);
        }
      }

      // Refresh dashboard after success
      if (success && mounted) {
        await context.read<DashboardProvider>().refreshDashboard();
      }

      setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(widget.studentData != null
                    ? 'Student updated successfully'
                    : 'Student added successfully'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text('Failed to ${widget.studentData != null ? 'update' : 'add'} student'),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.studentData != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Student' : 'Add New Student'),
        elevation: 0,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Student Information Section
            _buildSectionHeader('Student Information', Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter name' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter email';
                if (!value!.contains('@')) return 'Please enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: _selectedClass,
                    label: 'Class',
                    items: _classes,
                    onChanged: (value) => setState(() => _selectedClass = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    value: _selectedSection,
                    label: 'Section',
                    items: _sections,
                    onChanged: (value) => setState(() => _selectedSection = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _rollNumberController,
                    label: 'Roll Number',
                    icon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter roll number' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    value: _selectedGender,
                    label: 'Gender',
                    items: _genders,
                    onChanged: (value) => setState(() => _selectedGender = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: _dobController,
                  label: 'Date of Birth',
                  icon: Icons.calendar_today,
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Please select date of birth' : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              value: _bloodGroupController.text.isEmpty ? 'A+' : _bloodGroupController.text,
              label: 'Blood Group',
              items: _bloodGroups,
              onChanged: (value) {
                setState(() => _bloodGroupController.text = value!);
              },
            ),

            const SizedBox(height: 32),

            // Parent Information Section
            _buildSectionHeader('Father\'s Information', Icons.man),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _fatherNameController,
              label: 'Father\'s Name',
              icon: Icons.person,
              validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter father\'s name' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _fatherPhoneController,
              label: 'Father\'s Phone',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter phone number' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _fatherEmailController,
              label: 'Father\'s Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _fatherOccupationController,
              label: 'Father\'s Occupation',
              icon: Icons.work,
            ),

            const SizedBox(height: 32),

            _buildSectionHeader('Mother\'s Information', Icons.woman),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _motherNameController,
              label: 'Mother\'s Name',
              icon: Icons.person,
              validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter mother\'s name' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _motherPhoneController,
              label: 'Mother\'s Phone',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _motherEmailController,
              label: 'Mother\'s Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _motherOccupationController,
              label: 'Mother\'s Occupation',
              icon: Icons.work,
            ),

            const SizedBox(height: 32),

            _buildSectionHeader('Address', Icons.home),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Complete Address',
              icon: Icons.home,
              maxLines: 3,
              validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter address' : null,
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
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
                  : Text(
                isEditing ? 'Update Student' : 'Add Student',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}