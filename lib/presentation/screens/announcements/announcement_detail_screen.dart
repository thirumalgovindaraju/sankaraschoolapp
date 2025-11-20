import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/announcement_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/announcement_provider.dart';
import 'package:intl/intl.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final AnnouncementModel announcement;

  const AnnouncementDetailScreen({
    Key? key,
    required this.announcement,
  }) : super(key: key);

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  Future<void> _markAsRead() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      await context.read<AnnouncementProvider>().markAsRead(
        widget.announcement.id,
        userId,
      );
    }
  }

  Future<void> _deleteAnnouncement() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text('Are you sure you want to delete this announcement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await context.read<AnnouncementProvider>()
          .deleteAnnouncement(widget.announcement.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Color _getPriorityColor() {
    switch (widget.announcement.priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.announcement.type) {
      case 'academic':
        return Icons.school;
      case 'urgent':
        return Icons.warning;
      case 'event':
        return Icons.event;
      case 'holiday':
        return Icons.beach_access;
      default:
        return Icons.announcement;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.currentUser?.role?.name == 'admin';
    final isCreator = authProvider.currentUser?.id == widget.announcement.createdBy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          if (isAdmin || isCreator) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit-announcement',
                  arguments: widget.announcement,
                ).then((_) {
                  // Refresh when coming back
                  if (mounted) setState(() {});
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteAnnouncement,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority and Type Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPriorityColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getPriorityColor()),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: _getPriorityColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.announcement.priority.toUpperCase(),
                        style: TextStyle(
                          color: _getPriorityColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTypeIcon(),
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.announcement.type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              widget.announcement.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Meta Information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Posted by ${widget.announcement.createdByName}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy - hh:mm a').format(widget.announcement.createdAt),
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  if (widget.announcement.targetAudience.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'For: ${widget.announcement.targetAudience.join(", ").toUpperCase()}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Message
            const Text(
              'Message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.announcement.message,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // Target Classes (if any)
            if (widget.announcement.targetClasses.isNotEmpty) ...[
              const Text(
                'Target Classes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.announcement.targetClasses.map((className) {
                  return Chip(
                    label: Text(className),
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Attachments (if any)
            if (widget.announcement.attachments.isNotEmpty) ...[
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...widget.announcement.attachments.map((attachment) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.attachment),
                    title: Text(attachment.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        // TODO: Implement download
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download feature coming soon')),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ],

            // Read Count
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.visibility, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.announcement.readCount} people have read this announcement',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}