// lib/data/models/notification_model.dart

class NotificationModel {
  final String id;
  final String userId; // Recipient user ID
  final String title;
  final String message;
  final String type; // 'attendance', 'announcement', 'grade', 'event', 'leave', 'general'
  final String priority; // 'high', 'medium', 'low'
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final String? relatedId; // ID of related entity (announcement, attendance, etc.)
  final String? relatedType; // Type of related entity
  final Map<String, dynamic>? data; // Additional data
  final String? actionUrl; // Deep link or route to navigate
  final String? imageUrl;
  final String? senderId; // Who triggered this notification
  final String? senderName;
  final String? senderRole;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.priority = 'medium',
    required this.createdAt,
    this.isRead = false,
    this.readAt,
    this.relatedId,
    this.relatedType,
    this.data,
    this.actionUrl,
    this.imageUrl,
    this.senderId,
    this.senderName,
    this.senderRole,
  });

  // From JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      priority: json['priority'] ?? 'medium',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      relatedId: json['related_id'],
      relatedType: json['related_type'],
      data: json['data'],
      actionUrl: json['action_url'],
      imageUrl: json['image_url'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderRole: json['sender_role'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'related_id': relatedId,
      'related_type': relatedType,
      'data': data,
      'action_url': actionUrl,
      'image_url': imageUrl,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
    };
  }

  // Copy with
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? priority,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
    String? relatedId,
    String? relatedType,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? imageUrl,
    String? senderId,
    String? senderName,
    String? senderRole,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
    );
  }

  // Mark as read
  NotificationModel markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  // Get type icon
  String get typeIcon {
    switch (type) {
      case 'attendance':
        return '📋';
      case 'announcement':
        return '📢';
      case 'grade':
        return '📊';
      case 'event':
        return '📅';
      case 'leave':
        return '🏖️';
      case 'curriculum':
        return '📚';
      default:
        return '🔔';
    }
  }

  // Get priority color
  String get priorityColor {
    switch (priority) {
      case 'high':
        return '#F44336';
      case 'medium':
        return '#FF9800';
      case 'low':
        return '#4CAF50';
      default:
        return '#2196F3';
    }
  }

  // Check if notification is recent (within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }
}

// Notification Summary Model (for dashboard)
class NotificationSummary {
  final int totalCount;
  final int unreadCount;
  final int attendanceCount;
  final int announcementCount;
  final int gradeCount;
  final int eventCount;
  final int leaveCount;
  final List<NotificationModel> recentNotifications;

  NotificationSummary({
    this.totalCount = 0,
    this.unreadCount = 0,
    this.attendanceCount = 0,
    this.announcementCount = 0,
    this.gradeCount = 0,
    this.eventCount = 0,
    this.leaveCount = 0,
    this.recentNotifications = const [],
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      totalCount: json['total_count'] ?? 0,
      unreadCount: json['unread_count'] ?? 0,
      attendanceCount: json['attendance_count'] ?? 0,
      announcementCount: json['announcement_count'] ?? 0,
      gradeCount: json['grade_count'] ?? 0,
      eventCount: json['event_count'] ?? 0,
      leaveCount: json['leave_count'] ?? 0,
      recentNotifications: json['recent_notifications'] != null
          ? (json['recent_notifications'] as List)
          .map((n) => NotificationModel.fromJson(n))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'unread_count': unreadCount,
      'attendance_count': attendanceCount,
      'announcement_count': announcementCount,
      'grade_count': gradeCount,
      'event_count': eventCount,
      'leave_count': leaveCount,
      'recent_notifications':
      recentNotifications.map((n) => n.toJson()).toList(),
    };
  }
}