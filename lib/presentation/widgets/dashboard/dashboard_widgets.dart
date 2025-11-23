// lib/presentation/widgets/dashboard/dashboard_widgets.dart
// Reusable dashboard widgets that properly display notifications, announcements, and attendance

import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/announcement_model.dart';
import '../../../core/constants/app_colors.dart';

// ============================================================================
// NOTIFICATIONS WIDGET
// ============================================================================

class DashboardNotificationsWidget extends StatelessWidget {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final VoidCallback onViewAll;

  const DashboardNotificationsWidget({
    Key? key,
    required this.notifications,
    required this.unreadCount,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View All'),
                ),
              ],
            ),
            const Divider(),
            if (notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...notifications.take(3).map((notification) {
                return _buildNotificationItem(context, notification);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context,
      NotificationModel notification,
      ) {
    return InkWell(
      onTap: () {
        // Navigate to notification details
        if (notification.actionUrl != null) {
          Navigator.pushNamed(context, notification.actionUrl!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
          color: notification.isRead ? null : Colors.blue.withValues(alpha: 0.05),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getNotificationIcon(notification),
                color: _getNotificationColor(notification),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight:
                      notification.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationModel notification) {
    switch (notification.type) {
      case 'attendance':
        return Colors.blue;
      case 'announcement':
        return Colors.orange;
      case 'grade':
        return Colors.green;
      case 'event':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationModel notification) {
    switch (notification.type) {
      case 'attendance':
        return Icons.check_circle;
      case 'announcement':
        return Icons.campaign;
      case 'grade':
        return Icons.grade;
      case 'event':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }
}

// ============================================================================
// ANNOUNCEMENTS WIDGET
// ============================================================================

class DashboardAnnouncementsWidget extends StatelessWidget {
  final List<AnnouncementModel> announcements;
  final VoidCallback onViewAll;

  const DashboardAnnouncementsWidget({
    Key? key,
    required this.announcements,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.campaign, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Announcements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View All'),
                ),
              ],
            ),
            const Divider(),
            if (announcements.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No announcements yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...announcements.take(3).map((announcement) {
                return _buildAnnouncementItem(context, announcement);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementItem(
      BuildContext context,
      AnnouncementModel announcement,
      ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/announcement-detail',
          arguments: announcement,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getAnnouncementColor(announcement).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getAnnouncementIcon(announcement),
                color: _getAnnouncementColor(announcement),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          announcement.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (announcement.priority == 'high')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    announcement.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        announcement.createdByName,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      Text(
                        _formatDate(announcement.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAnnouncementColor(AnnouncementModel announcement) {
    switch (announcement.priority) {
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

  IconData _getAnnouncementIcon(AnnouncementModel announcement) {
    switch (announcement.type) {
      case 'academic':
        return Icons.school;
      case 'urgent':
        return Icons.warning;
      case 'event':
        return Icons.event;
      case 'holiday':
        return Icons.beach_access;
      default:
        return Icons.campaign;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// ============================================================================
// ATTENDANCE SUMMARY WIDGET
// ============================================================================

class DashboardAttendanceWidget extends StatelessWidget {
  final Map<String, dynamic> attendanceData;
  final VoidCallback? onViewDetails;

  const DashboardAttendanceWidget({
    Key? key,
    required this.attendanceData,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalDays = attendanceData['total_days'] ?? 0;
    final presentDays = attendanceData['present_days'] ?? attendanceData['present_today'] ?? 0;
    final absentDays = attendanceData['absent_days'] ?? attendanceData['absent_today'] ?? 0;
    final percentage = attendanceData['attendance_percentage'] ?? 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (onViewDetails != null)
                  TextButton(
                    onPressed: onViewDetails,
                    child: const Text('View Details'),
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Attendance percentage circle
            Center(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getAttendanceColor(percentage),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Present',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  totalDays.toString(),
                  Colors.blue,
                ),
                _buildStatItem(
                  'Present',
                  presentDays.toString(),
                  Colors.green,
                ),
                _buildStatItem(
                  'Absent',
                  absentDays.toString(),
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}