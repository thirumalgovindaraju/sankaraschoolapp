import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart'; // Add this import
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedCategory = 'general';
  String _selectedPriority = 'medium';
  bool _isPinned = false;
  bool _sendNotification = true;
  DateTime? _expiryDate;
  List<String> _selectedAudiences = [];
  bool _isSubmitting = false;

  final List<String> _categories = [
    'general',
    'academic',
    'events',
    'holidays',
    'emergency',
    'exam',
    'sports',
    'cultural',
  ];

  final List<String> _priorities = ['low', 'medium', 'high'];

  final List<String> _audiences = [
    'All Students',
    'All Parents',
    'All Teachers',
    'All Staff',
    'Class 1-5',
    'Class 6-10',
    'Class 11-12',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get user from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Check if user is null
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Announcement'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('User not found. Please log in again.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter announcement title',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                if (value.length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Content
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                hintText: 'Enter announcement details',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Icon(Icons.description),
                ),
              ),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter content';
                }
                if (value.length < 10) {
                  return 'Content must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Category
            _buildSectionTitle('Category'),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Priority
            _buildSectionTitle('Priority Level'),
            Row(
              children: _priorities.map((priority) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildPriorityButton(priority),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Target Audience
            _buildSectionTitle('Target Audience'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _audiences.map((audience) {
                final isSelected = _selectedAudiences.contains(audience);
                return FilterChip(
                  label: Text(audience),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAudiences.add(audience);
                      } else {
                        _selectedAudiences.remove(audience);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withOpacity(0.3),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Options
            _buildSectionTitle('Options'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Pin Announcement'),
                    subtitle: const Text('Keep at top of the list'),
                    value: _isPinned,
                    onChanged: (value) {
                      setState(() {
                        _isPinned = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Send Push Notification'),
                    subtitle: const Text('Notify all selected audiences'),
                    value: _sendNotification,
                    onChanged: (value) {
                      setState(() {
                        _sendNotification = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Expiry Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Expiry Date (Optional)'),
                subtitle: Text(
                  _expiryDate != null
                      ? _formatDate(_expiryDate!)
                      : 'No expiry date',
                ),
                trailing: _expiryDate != null
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _expiryDate = null;
                    });
                  },
                )
                    : null,
                onTap: _selectExpiryDate,
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitAnnouncement(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Publish Announcement',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityButton(String priority) {
    final isSelected = _selectedPriority == priority;
    Color color;
    IconData icon;

    switch (priority) {
      case 'high':
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.warning_amber;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info_outline;
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey[200],
          border: Border.all(
            color: isSelected ? color : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              priority.toUpperCase(),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _submitAnnouncement(UserModel user) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAudiences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one target audience'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<AnnouncementProvider>();

      await provider.createAnnouncement(
        title: _titleController.text.trim(),
        message: _contentController.text.trim(),
        type: _selectedCategory,
        priority: _selectedPriority,
        targetAudience: _selectedAudiences,
        createdBy: user.name,
        createdByName: user.name,
        createdByRole: user.role.toString().split('.').last,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement published successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error publishing announcement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}