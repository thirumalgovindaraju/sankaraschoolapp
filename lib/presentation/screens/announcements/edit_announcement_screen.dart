import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/announcement_model.dart';
import '../../providers/announcement_provider.dart';

class EditAnnouncementScreen extends StatefulWidget {
  final AnnouncementModel announcement;

  const EditAnnouncementScreen({
    Key? key,
    required this.announcement,
  }) : super(key: key);

  @override
  State<EditAnnouncementScreen> createState() => _EditAnnouncementScreenState();
}

class _EditAnnouncementScreenState extends State<EditAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _messageController;

  late String _selectedType;
  late String _selectedPriority;
  late List<String> _selectedAudience;
  late List<String> _selectedClasses;
  DateTime? _expiryDate;
  bool _isLoading = false;

  final List<String> _types = ['academic', 'general', 'urgent', 'event', 'holiday'];
  final List<String> _priorities = ['high', 'medium', 'low'];
  final List<String> _audiences = ['all', 'student', 'parent', 'teacher'];
  final List<String> _classes = [
    'Pre-KG', 'LKG', 'UKG', 'Grade 1', 'Grade 2', 'Grade 3',
    'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8',
    'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement.title);
    _messageController = TextEditingController(text: widget.announcement.message);
    _selectedType = widget.announcement.type;
    _selectedPriority = widget.announcement.priority;
    _selectedAudience = List.from(widget.announcement.targetAudience);
    _selectedClasses = List.from(widget.announcement.targetClasses);
    _expiryDate = widget.announcement.expiryDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _updateAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await context.read<AnnouncementProvider>().updateAnnouncement(
        id: widget.announcement.id,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: _selectedType,
        priority: _selectedPriority,
        targetAudience: _selectedAudience,
        targetClasses: _selectedClasses.isEmpty ? null : _selectedClasses,
        expiryDate: _expiryDate,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update announcement'),
            backgroundColor: Colors.red,
          ),
        );
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
        title: const Text('Edit Announcement'),
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
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
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
                ),
                items: _priorities.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toUpperCase()),
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _audiences.map((audience) {
                  final isSelected = _selectedAudience.contains(audience);
                  return FilterChip(
                    label: Text(audience.toUpperCase()),
                    selected: isSelected,
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

              // Target Classes
              const Text(
                'Target Classes (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _classes.map((className) {
                  final isSelected = _selectedClasses.contains(className);
                  return FilterChip(
                    label: Text(className),
                    selected: isSelected,
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

              // Expiry Date
              ListTile(
                contentPadding: EdgeInsets.zero,
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
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
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
              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateAnnouncement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Update Announcement',
                    style: TextStyle(fontSize: 16),
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