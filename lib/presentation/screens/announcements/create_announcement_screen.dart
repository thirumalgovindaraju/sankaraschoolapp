// lib/presentation/screens/announcements/create_announcement_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/announcement_provider.dart';

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
  String _selectedPriority = 'medium';
  List<String> _selectedAudience = ['all'];
  List<String> _selectedClasses = [];
  DateTime? _expiryDate;
  bool _isLoading = false;
  bool _sendPushNotification = true; // NEW: Toggle for notifications
  bool _pinAnnouncement = false; // NEW: Toggle for pinning

  final List<String> _types = ['academic', 'general', 'urgent', 'event', 'holiday'];
  final List<String> _priorities = ['high', 'medium', 'low'];
  final List<String> _audiences = ['all', 'student', 'parent', 'teacher'];
  final List<String> _classes = [
    'Pre-KG', 'LKG', 'UKG', 'Grade 1', 'Grade 2', 'Grade 3',
    'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8',
    'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _createAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found. Please login again.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final success = await context.read<AnnouncementProvider>().createAnnouncement(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: _selectedType,
        priority: _selectedPriority,
        targetAudience: _selectedAudience,
        targetClasses: _selectedClasses.isEmpty ? null : _selectedClasses,
        createdBy: user.id,
        createdByName: user.name,
        createdByRole: user.role?.name ?? 'admin',
        expiryDate: _expiryDate,
        sendNotifications: _sendPushNotification, // NEW: Pass notification preference
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _sendPushNotification
                    ? 'Announcement created and notifications sent!'
                    : 'Announcement created successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create announcement'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Announcement'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Title
                  TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'Enter announcement title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Message
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message *',
                    hintText: 'Enter announcement message',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.message),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Type
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _types.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedType = value!);
                  },
                ),
                const SizedBox(height: 16),

                // Priority
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: _priorities.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: priority == 'high'
                                ? Colors.red
                                : priority == 'medium'
                                ? Colors.orange
                                : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(priority.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedPriority = value!);
                  },
                ),
                const SizedBox(height: 16),

                // Target Audience
                const Text(
                  'Target Audience *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _audiences.map((audience) {
                    final isSelected = _selectedAudience.contains(audience);
                    return FilterChip(
                      label: Text(audience.toUpperCase()),
                      selected: isSelected,
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      onSelected: (selected) {
                        setState(() {
                          if (audience == 'all') {
                            _selectedAudience = selected ? ['all'] : [];
                          } else {
                            _selectedAudience.remove('all');
                            if (selected) {
                              _selectedAudience.add(audience);
                            } else {
                              _selectedAudience.remove(audience);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Target Classes (Optional)
                const Text(
                  'Target Classes (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text(
                  'Leave empty to send to all classes',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _classes.map((className) {
                    final isSelected = _selectedClasses.contains(className);
                    return FilterChip(
                      label: Text(className),
                      selected: isSelected,
                      selectedColor: Theme.of(context).colorScheme.secondaryContainer,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedClasses.add(className);
                          } else {
                            _selectedClasses.remove(className);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Expiry Date (Optional)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Expiry Date (Optional)'),
                    subtitle: Text(
                      _expiryDate != null
                          ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                          : 'No expiry date',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_expiryDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _expiryDate = null);
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit_calendar),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(const Duration(days: 7)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => _expiryDate = date);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Options Section
                const Text(
                    'Options',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                    const SizedBox(height: 8),

                    // Pin Announcement Toggle
                    Card(
                      child: SwitchListTile(
                        secondary: const Icon(Icons.push_pin),
                        title: const Text('Pin Announcement'),
                        subtitle: const Text('Keep at top of the list'),
                        value: _pinAnnouncement,
                        onChanged: (value) {
                          setState(() => _pinAnnouncement = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Send Push Notification Toggle
                    Card(
                      child: SwitchListTile(
                        secondary: const Icon(Icons.notifications_active),
                        title: const Text('Send Push Notification'),
                        subtitle: Text(
                          _sendPushNotification
                              ? 'Users will receive notifications'
                              : 'No notifications will be sent',
                        ),
                        value: _sendPushNotification,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() => _sendPushNotification = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _createAnnouncement,
                        icon: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.send),
                        label: Text(
                          _isLoading ? 'Creating...' : 'Create Announcement',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Card
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _sendPushNotification
                                    ? 'Notifications will be sent to all selected audiences immediately'
                                    : 'Announcement will be created without sending notifications',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ),
        ),
    );
  }
}