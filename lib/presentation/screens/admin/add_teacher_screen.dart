// lib/presentation/screens/admin/add_teacher_screen.dart (COMPLETELY FIXED)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/services/activity_service.dart';

class AddTeacherScreen extends StatefulWidget {
  final Map<String, dynamic>? teacherData;

  const AddTeacherScreen({Key? key, this.teacherData}) : super(key: key);

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _joiningDateController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedSubject = 'Mathematics';
  List<String> _selectedClasses = [];
  String _selectedGender = 'Male';
  bool _isLoading = false;

  final List<String> _subjects = [
    'Mathematics',
    'Science',
    'English',
    'Hindi',
    'Social Studies',
    'Computer Science',
    'Physics',
    'Chemistry',
    'Biology',
    'History',
    'Geography',
    'Economics',
    'Physical Education',
    'Art & Craft',
    'Music',
  ];

  final List<String> _classes = [
    'Pre-KG', 'LKG', 'UKG', '1st', '2nd', '3rd', '4th',
    '5th', '6th', '7th', '8th', '9th', '10th'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.teacherData != null) {
      _loadTeacherData();
    } else {
      _joiningDateController.text = DateTime.now().toIso8601String().split('T')[0];
    }
  }

  void _loadTeacherData() {
    final data = widget.teacherData!;
    _nameController.text = data['name'] ?? '';
    _emailController.text = data['email'] ?? '';
    _phoneController.text = data['phone'] ?? '';
    _qualificationController.text = data['qualification'] ?? '';
    _experienceController.text = data['experience']?.toString() ?? '';
    _joiningDateController.text = data['joining_date'] ?? '';
    _selectedSubject = data['subject'] ?? 'Mathematics';
    _selectedGender = data['gender'] ?? 'Male';
    _addressController.text = data['address'] ?? '';

    if (data['classes_assigned'] != null) {
      _selectedClasses = List<String>.from(data['classes_assigned']);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _joiningDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _joiningDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _showClassSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Select Classes'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _classes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final className = _classes[index];
                    return CheckboxListTile(
                      title: Text(className),
                      value: _selectedClasses.contains(className),
                      onChanged: (bool? checked) {
                        setDialogState(() {
                          if (checked == true) {
                            _selectedClasses.add(className);
                          } else {
                            _selectedClasses.remove(className);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClasses.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one class'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final teacherData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'subject': _selectedSubject,
      'classes_assigned': _selectedClasses,
      'qualification': _qualificationController.text.trim(),
      'experience': int.tryParse(_experienceController.text.trim()) ?? 0,
      'joining_date': _joiningDateController.text.trim(),
      'gender': _selectedGender,
      'address': _addressController.text.trim(),
    };

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final activityService = ActivityService();
      bool success;

      if (widget.teacherData != null) {
        success = await adminProvider.updateTeacher(
          widget.teacherData!['teacher_id'],
          teacherData,
        );
      } else {
        success = await adminProvider.addTeacher(teacherData);

        if (success) {
          await activityService.logTeacherAssignment(
            _nameController.text.trim(),
            _selectedSubject,
            _selectedClasses.join(', '),
          );
        }
      }

      // Refresh admin provider data instead of dashboard provider
      if (success && mounted) {
        await adminProvider.refresh();
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.teacherData != null
                ? 'Teacher updated successfully'
                : 'Teacher added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save teacher'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teacherData != null ? 'Edit Teacher' : 'Add New Teacher'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter name' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    value: _selectedGender,
                    label: 'Gender',
                    items: _genders,
                    onChanged: (value) => setState(() => _selectedGender = value ?? 'Male'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter phone number' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.home,
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Professional Information'),
            const SizedBox(height: 16),
            _buildDropdown(
              value: _selectedSubject,
              label: 'Subject',
              items: _subjects,
              onChanged: (value) => setState(() => _selectedSubject = value ?? 'Mathematics'),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _showClassSelectionDialog,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.class_),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Classes Assigned',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedClasses.isEmpty
                                ? 'Tap to select classes'
                                : _selectedClasses.join(', '),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _qualificationController,
                    label: 'Qualification',
                    icon: Icons.school,
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter qualification' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _experienceController,
                    label: 'Experience (Years)',
                    icon: Icons.work_history,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: _joiningDateController,
                  label: 'Joining Date',
                  icon: Icons.calendar_today,
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Please select joining date' : null,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTeacher,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(
                widget.teacherData != null ? 'Update Teacher' : 'Add Teacher',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
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
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
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
        ),
        filled: true,
        fillColor: Colors.grey[50],
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