// lib/presentation/screens/announcements/create_announcement_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../data/services/activity_service.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedType = 'general';
  String _selectedPriority = 'normal';
  List<String> _selectedAudience = ['all'];
  List<String> _selectedClasses = [];
  DateTime? _expiryDate;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _types = [
    {'value': 'general', 'label': 'General', 'icon': Icons.info, 'color': Colors.blue},
    {'value': 'academic', 'label': 'Academic', 'icon': Icons.school, 'color': Colors.green},
    {'value': 'event', 'label': 'Event', 'icon': Icons.event, 'color': Colors.orange},
    {'value': 'holiday', 'label': 'Holiday', 'icon': Icons.beach_access, 'color': Colors.purple},
    {'value': 'urgent', 'label': 'Urgent', 'icon': Icons.warning, 'color': Colors.red},
    {'value': 'exam', 'label': 'Exam', 'icon': Icons.quiz, 'color': Colors.indigo},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'value': 'low', 'label': 'Low', 'color': Colors.grey},
    {'value': 'normal', 'label': 'Normal', 'color': Colors.blue},
    {'value': 'high', 'label': 'High', 'color': Colors.orange},
    {'value': 'urgent', 'label': 'Urgent', 'color': Colors.red},
  ];

  final List<String> _audiences = ['all', 'students', 'teachers', 'parents', 'staff'];
  final List<String> _classes = ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5',
    'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _submitAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final announcementProvider = context.read<AnnouncementProvider>();
      final dashboardProvider = context.read<DashboardProvider>();
      final activityService = ActivityService();

      final user = authProvider.currentUser;
      if (user == null) {
        _showErrorSnackbar('User not authenticated');
        setState(() => _isLoading = false);
        return;
      }

      // Create announcement
      final success = await announcementProvider.createAnnouncement(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: _selectedType,
        priority: _selectedPriority,
        targetAudience: _selectedAudience,
        targetClasses: _selectedClasses,
        createdBy: user.id,
        createdByName: user.name,
        createdByRole: user.role.name,
        expiryDate: _expiryDate,
      );

      if (success) {
        // 🔥 Log activity for dashboard
        await activityService.logAnnouncementCreated(
          _titleController.text.trim(),
          user.name,
        );

        // 🔥 Refresh dashboard data
        await dashboardProvider.refreshDashboard();

        // 🔥 Refresh announcements
        await announcementProvider.fetchAnnouncements(
          userRole: user.role.name,
          userId: user.id,
        );

        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        _showErrorSnackbar('Failed to create announcement');
      }
    } catch (e) {
      _showErrorSnackbar('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 32),
            ),
            const SizedBox(width: 16),
            const Text('Success!'),
          ],
        ),
        content: const Text(
          'Announcement created successfully and will be visible to the selected audience.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dashboard
            },
            child: const Text('Back to Dashboard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _resetForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Create Another'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _titleController.clear();
    _messageController.clear();
    setState(() {
      _selectedType = 'general';
      _selectedPriority = 'normal';
      _selectedAudience = ['all'];
      _selectedClasses = [];
      _expiryDate = null;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Colors.orange.shade600,
              ],
            ),
          ),
        ),
        title: const Text(
          'Create Announcement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title Field
            _buildSectionTitle('Announcement Title', Icons.title),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter announcement title',
                prefixIcon: const Icon(Icons.campaign),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                if (value.trim().length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Message Field
            _buildSectionTitle('Message', Icons.message),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Enter announcement message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a message';
                }
                if (value.trim().length < 10) {
                  return 'Message must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Type Selection
            _buildSectionTitle('Announcement Type', Icons.category),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((type) {
                final isSelected = _selectedType == type['value'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        size: 18,
                        color: isSelected ? Colors.white : type['color'],
                      ),
                      const SizedBox(width: 6),
                      Text(type['label'] as String),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedType = type['value'] as String);
                  },
                  selectedColor: type['color'] as Color,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Priority Selection
            _buildSectionTitle('Priority Level', Icons.priority_high),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _priorities.map((priority) {
                final isSelected = _selectedPriority == priority['value'];
                return ChoiceChip(
                  label: Text(priority['label'] as String),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedPriority = priority['value'] as String);
                  },
                  selectedColor: priority['color'] as Color,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Target Audience
            _buildSectionTitle('Target Audience', Icons.group),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _audiences.map((audience) {
                final isSelected = _selectedAudience.contains(audience);
                return FilterChip(
                  label: Text(audience.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (audience == 'all') {
                        _selectedAudience = ['all'];
                      } else {
                        _selectedAudience.remove('all');
                        if (selected) {
                          _selectedAudience.add(audience);
                        } else {
                          _selectedAudience.remove(audience);
                        }
                        if (_selectedAudience.isEmpty) {
                          _selectedAudience = ['all'];
                        }
                      }
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Expiry Date
            _buildSectionTitle('Expiry Date (Optional)', Icons.calendar_today),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectExpiryDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      _expiryDate == null
                          ? 'Select expiry date'
                          : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _expiryDate == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                    if (_expiryDate != null) ...[
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => setState(() => _expiryDate = null),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitAnnouncement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Publish Announcement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}