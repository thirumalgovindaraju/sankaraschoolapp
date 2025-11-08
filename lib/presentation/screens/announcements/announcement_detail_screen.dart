import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';
import '../../../data/models/announcement_model.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final AnnouncementModel announcement;
  final UserModel user;

  const AnnouncementDetailScreen({
    Key? key,
    required this.announcement,
    required this.user,
  }) : super(key: key);

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.user.role == 'admin' ||
        widget.announcement.createdById == widget.user.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareAnnouncement,
          ),
          if (canEdit)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildPriorityBadge(widget.announcement.priority),
                      const SizedBox(width: 8),
                      _buildCategoryChip(widget.announcement.category),
                      const Spacer(),
                      if (widget.announcement.isPinned)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.push_pin,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.announcement.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata
                  _buildMetadataSection(),
                  const SizedBox(height: 24),

                  // Content
                  _buildSectionTitle('Details'),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.announcement.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Target Audience
                  if (widget.announcement.targetAudience.isNotEmpty) ...[
                    _buildSectionTitle('Target Audience'),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.announcement.targetAudience
                              .map((audience) {
                            return Chip(
                              avatar: const CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Icon(
                                  Icons.group,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              label: Text(audience),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Target Classes
                  if (widget.announcement.targetClasses.isNotEmpty) ...[
                    _buildSectionTitle('Target Classes'),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.announcement.targetClasses
                              .map((className) {
                            return Chip(
                              avatar: const CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Icon(
                                  Icons.school,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              label: Text(className),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Attachments (if any)
                  if (widget.announcement.attachments.isNotEmpty) ...[
                    _buildSectionTitle('Attachments'),
                    const SizedBox(height: 8),
                    _buildAttachmentsList(),
                    const SizedBox(height: 24),
                  ],

                  // Additional Info
                  _buildAdditionalInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.person_outline,
              'Posted by',
              widget.announcement.createdByName,
            ),
            const Divider(height: 20),
            _buildInfoRow(
              Icons.badge_outlined,
              'Role',
              widget.announcement.createdByRole.toUpperCase(),
            ),
            const Divider(height: 20),
            _buildInfoRow(
              Icons.access_time,
              'Posted on',
              _formatDate(widget.announcement.createdAt),
            ),
            if (widget.announcement.expiryDate != null) ...[
              const Divider(height: 20),
              _buildInfoRow(
                Icons.event,
                'Expires on',
                _formatDate(widget.announcement.expiryDate!),
              ),
            ],
            if (widget.announcement.updatedAt != null &&
                widget.announcement.updatedAt != widget.announcement.createdAt) ...[
              const Divider(height: 20),
              _buildInfoRow(
                Icons.update,
                'Last updated',
                _formatDate(widget.announcement.updatedAt!),
              ),
            ],
            const Divider(height: 20),
            _buildInfoRow(
              Icons.visibility_outlined,
              'Read by',
              '${widget.announcement.readCount} people',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    IconData icon;

    switch (priority.toLowerCase()) {
      case 'high':
        icon = Icons.priority_high;
        break;
      case 'medium':
        icon = Icons.warning_amber;
        break;
      default:
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            priority.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getTypeIcon(category),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          Text(
            category.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'academic':
        return '📚';
      case 'urgent':
        return '🚨';
      case 'event':
        return '📅';
      case 'holiday':
        return '🏖️';
      default:
        return '📢';
    }
  }

  Widget _buildAttachmentsList() {
    return Card(
      elevation: 2,
      child: Column(
        children: widget.announcement.attachments.map((attachment) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.attach_file, color: Colors.white, size: 20),
            ),
            title: Text(attachment.name),
            subtitle: Text(_getFileSize(attachment.size)),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadAttachment(attachment),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This announcement ${widget.announcement.expiryDate != null ? 'will expire on ${_formatDate(widget.announcement.expiryDate!)}' : 'has no expiry date'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareAnnouncement() {
    final text = '''
${widget.announcement.title}

${widget.announcement.content}

Posted by: ${widget.announcement.createdByName}
Date: ${_formatDate(widget.announcement.createdAt)}
    ''';

    Share.share(text, subject: widget.announcement.title);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editAnnouncement();
        break;
      case 'delete':
        _confirmDelete();
        break;
    }
  }

  void _editAnnouncement() {
    // Navigate to edit screen (implement as needed)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon')),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text(
          'Are you sure you want to delete this announcement? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAnnouncement();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAnnouncement() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final provider = context.read<AnnouncementProvider>();
      await provider.deleteAnnouncement(widget.announcement.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting announcement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _downloadAttachment(Attachment attachment) {
    // Implement attachment download using attachment.url
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${attachment.name}...')),
    );
    // TODO: Implement actual download logic using attachment.url
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getFileSize(int? bytes) {
    if (bytes == null) return 'Unknown size';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}