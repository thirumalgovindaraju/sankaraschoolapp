// lib/data/services/local_notification_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class LocalNotificationService {
  static const String _notificationsKey = 'local_notifications_v2';
  static const String _notificationIdCounterKey = 'notification_id_counter_v2';

  // ===== GET METHODS =====

  /// Get all notifications from local storage
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> notificationsList = json.decode(notificationsJson);
        return notificationsList
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Error loading notifications: $e');
      return [];
    }
  }

  Future<bool> createNotificationByEmail({
    required String userEmail,
    required String title,
    required String message,
    required String type,
    String priority = 'medium',
    String? relatedId,
    String? relatedType,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? senderId,
    String? senderName,
    String? senderRole,
  }) async {
    // Use email as the userId
    return await createNotification(
      userId: userEmail,
      title: title,
      message: message,
      type: type,
      priority: priority,
      relatedId: relatedId,
      relatedType: relatedType,
      data: data,
      actionUrl: actionUrl,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
    );
  }
  /// Get notifications for a specific user
  Future<List<NotificationModel>> getUserNotifications(
      String userId, {
        bool unreadOnly = false,
        String? type,
        int? limit,
      }) async {
    try {
      final allNotifications = await getAllNotifications();
      var userNotifications =
      allNotifications.where((n) => n.userId == userId).toList();

      // Filter by unread
      if (unreadOnly) {
        userNotifications = userNotifications.where((n) => !n.isRead).toList();
      }

      // Filter by type
      if (type != null && type.isNotEmpty) {
        userNotifications = userNotifications.where((n) => n.type == type).toList();
      }

      // Sort by date (newest first)
      userNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Apply limit
      if (limit != null && limit > 0) {
        userNotifications = userNotifications.take(limit).toList();
      }

      return userNotifications;
    } catch (e) {
      print('❌ Error getting user notifications: $e');
      return [];
    }
  }

  /// Get unread count for user
  Future<int> getUnreadCount(String userId) async {
    try {
      final notifications = await getUserNotifications(userId, unreadOnly: true);
      return notifications.length;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Get notification summary
  Future<NotificationSummary> getNotificationSummary(String userId) async {
    try {
      final allNotifications = await getUserNotifications(userId);
      final unreadNotifications = allNotifications.where((n) => !n.isRead).toList();
      final recentNotifications = allNotifications.take(10).toList();

      return NotificationSummary(
        totalCount: allNotifications.length,
        unreadCount: unreadNotifications.length,
        attendanceCount: allNotifications.where((n) => n.type == 'attendance').length,
        announcementCount: allNotifications.where((n) => n.type == 'announcement').length,
        gradeCount: allNotifications.where((n) => n.type == 'grade').length,
        eventCount: allNotifications.where((n) => n.type == 'event').length,
        leaveCount: allNotifications.where((n) => n.type == 'leave').length,
        recentNotifications: recentNotifications,
      );
    } catch (e) {
      print('❌ Error getting notification summary: $e');
      return NotificationSummary();
    }
  }

  // ===== CREATE METHODS =====

  /// Create a single notification
  Future<bool> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String priority = 'medium',
    String? relatedId,
    String? relatedType,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? imageUrl,
    String? senderId,
    String? senderName,
    String? senderRole,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = await getAllNotifications();

      // Generate unique ID
      int counter = prefs.getInt(_notificationIdCounterKey) ?? 1;
      final notificationId = 'NOTIF_${counter.toString().padLeft(6, '0')}';
      await prefs.setInt(_notificationIdCounterKey, counter + 1);

      final notification = NotificationModel(
        id: notificationId,
        userId: userId,
        title: title,
        message: message,
        type: type,
        priority: priority,
        createdAt: DateTime.now(),
        isRead: false,
        relatedId: relatedId,
        relatedType: relatedType,
        data: data,
        actionUrl: actionUrl,
        imageUrl: imageUrl,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
      );

      notifications.insert(0, notification);
      print('✅ Created notification: $notificationId for user: $userId');
      return await _saveAllNotifications(notifications);
    } catch (e) {
      print('❌ Error creating notification: $e');
      return false;
    }
  }

  /// Create bulk notifications for multiple users
  Future<bool> createBulkNotifications({
    required List<String> userIds,
    required String title,
    required String message,
    required String type,
    String priority = 'medium',
    String? relatedId,
    String? relatedType,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? senderId,
    String? senderName,
    String? senderRole,
  }) async {
    try {
      bool allSuccess = true;
      for (String userId in userIds) {
        final success = await createNotification(
          userId: userId,
          title: title,
          message: message,
          type: type,
          priority: priority,
          relatedId: relatedId,
          relatedType: relatedType,
          data: data,
          actionUrl: actionUrl,
          senderId: senderId,
          senderName: senderName,
          senderRole: senderRole,
        );
        if (!success) allSuccess = false;
      }
      print('✅ Created bulk notifications for ${userIds.length} users');
      return allSuccess;
    } catch (e) {
      print('❌ Error creating bulk notifications: $e');
      return false;
    }
  }

  // ===== UPDATE METHODS =====

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final notifications = await getAllNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);

      if (index != -1) {
        notifications[index] = notifications[index].markAsRead();
        print('✅ Marked notification as read: $notificationId');
        return await _saveAllNotifications(notifications);
      }
      return false;
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all user notifications as read
  Future<bool> markAllAsRead(String userId) async {
    try {
      final notifications = await getAllNotifications();
      bool hasChanges = false;

      for (int i = 0; i < notifications.length; i++) {
        if (notifications[i].userId == userId && !notifications[i].isRead) {
          notifications[i] = notifications[i].markAsRead();
          hasChanges = true;
        }
      }

      if (hasChanges) {
        print('✅ Marked all notifications as read for user: $userId');
        return await _saveAllNotifications(notifications);
      }
      return true;
    } catch (e) {
      print('❌ Error marking all as read: $e');
      return false;
    }
  }

  // ===== DELETE METHODS =====

  /// Delete a single notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final notifications = await getAllNotifications();
      notifications.removeWhere((n) => n.id == notificationId);
      print('✅ Deleted notification: $notificationId');
      return await _saveAllNotifications(notifications);
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return false;
    }
  }

  /// Clear all user notifications
  Future<bool> clearAllNotifications(String userId) async {
    try {
      final notifications = await getAllNotifications();
      notifications.removeWhere((n) => n.userId == userId);
      print('✅ Cleared all notifications for user: $userId');
      return await _saveAllNotifications(notifications);
    } catch (e) {
      print('❌ Error clearing notifications: $e');
      return false;
    }
  }

  // ===== SPECIFIC NOTIFICATION TYPES =====

  /// Send attendance notification
  Future<bool> sendAttendanceNotification({
    required String studentId,
    required List<String> parentIds,
    required String studentName,
    required String status,
    required String date,
    required String markedBy,
  }) async {
    final title = 'Attendance Update';
    final message = '$studentName was marked $status on $date';

    return await createBulkNotifications(
      userIds: parentIds,
      title: title,
      message: message,
      type: 'attendance',
      priority: status.toLowerCase() == 'absent' ? 'high' : 'medium',
      relatedId: studentId,
      relatedType: 'student',
      data: {
        'student_id': studentId,
        'student_name': studentName,
        'status': status,
        'date': date,
        'marked_by': markedBy,
      },
      actionUrl: '/attendance',
      senderId: markedBy,
      senderName: 'Teacher',
      senderRole: 'teacher',
    );
  }

  /// Send announcement notification
  Future<bool> sendAnnouncementNotification({
    required List<String> userIds,
    required String title,
    required String message,
    required String announcementId,
    required String senderId,
    required String senderName,
    required String senderRole,
    String priority = 'medium',
  }) async {
    return await createBulkNotifications(
      userIds: userIds,
      title: title,
      message: message,
      type: 'announcement',
      priority: priority,
      relatedId: announcementId,
      relatedType: 'announcement',
      actionUrl: '/announcements/$announcementId',
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
    );
  }

  /// Send grade notification
  Future<bool> sendGradeNotification({
    required String studentId,
    required List<String> parentIds,
    required String studentName,
    required String subject,
    required String grade,
    required String teacherId,
  }) async {
    final title = 'New Grade Posted';
    final message = '$studentName received $grade in $subject';

    return await createBulkNotifications(
      userIds: parentIds,
      title: title,
      message: message,
      type: 'grade',
      priority: 'medium',
      relatedId: studentId,
      relatedType: 'student',
      data: {
        'student_id': studentId,
        'student_name': studentName,
        'subject': subject,
        'grade': grade,
      },
      actionUrl: '/grades',
      senderId: teacherId,
      senderName: 'Teacher',
      senderRole: 'teacher',
    );
  }

  // ===== PRIVATE HELPER METHODS =====

  /// Save all notifications to local storage
  Future<bool> _saveAllNotifications(List<NotificationModel> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson =
      json.encode(notifications.map((n) => n.toJson()).toList());
      return await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      print('❌ Error saving notifications: $e');
      return false;
    }
  }

  // ===== INITIALIZATION =====

  /// Initialize with sample notifications (call once during setup)
  Future<bool> initializeSampleNotifications() async {
    try {
      final existingNotifications = await getAllNotifications();
      if (existingNotifications.isNotEmpty) {
        print('ℹ️ Sample notifications already exist');
        return true;
      }

      print('🚀 Initializing sample notifications...');

      final now = DateTime.now();
      final sampleNotifications = [
        // Admin notifications
        NotificationModel(
          id: 'NOTIF_000001',
          userId: 'ADM001',
          title: 'Welcome to Sri Sankara Global School',
          message: 'Your admin dashboard is ready. Start managing students, staff, and school operations.',
          type: 'general',
          priority: 'high',
          createdAt: now.subtract(const Duration(hours: 2)),
          isRead: false,
          actionUrl: '/admin-dashboard',
          senderId: 'SYSTEM',
          senderName: 'System',
          senderRole: 'system',
        ),
        NotificationModel(
          id: 'NOTIF_000002',
          userId: 'ADM001',
          title: 'New Student Admissions',
          message: '5 new students have been admitted to Class 1-A. Please review their details.',
          type: 'announcement',
          priority: 'high',
          createdAt: now.subtract(const Duration(hours: 5)),
          isRead: false,
          actionUrl: '/manage-students',
          relatedType: 'students',
          senderId: 'ADM001',
          senderName: 'Admin',
          senderRole: 'admin',
        ),
        NotificationModel(
          id: 'NOTIF_000003',
          userId: 'ADM001',
          title: 'Fee Payment Reminder',
          message: '15 students have pending fee payments for November 2025.',
          type: 'announcement',
          priority: 'medium',
          createdAt: now.subtract(const Duration(days: 1)),
          isRead: false,
          actionUrl: '/fees',
        ),
        NotificationModel(
          id: 'NOTIF_000004',
          userId: 'ADM001',
          title: 'System Maintenance Scheduled',
          message: 'System maintenance is scheduled for this weekend. All services will be unavailable for 2 hours.',
          type: 'announcement',
          priority: 'low',
          createdAt: now.subtract(const Duration(days: 2)),
          isRead: true,
          readAt: now.subtract(const Duration(days: 1, hours: 12)),
        ),
        NotificationModel(
          id: 'NOTIF_000005',
          userId: 'ADM001',
          title: 'Staff Meeting Tomorrow',
          message: 'All teaching staff meeting scheduled for tomorrow at 9:00 AM in the conference room.',
          type: 'event',
          priority: 'high',
          createdAt: now.subtract(const Duration(hours: 8)),
          isRead: false,
          actionUrl: '/events',
        ),

        // Teacher notifications
        NotificationModel(
          id: 'NOTIF_000006',
          userId: 'TCH001',
          title: 'Class Schedule Updated',
          message: 'Your class schedule for next week has been updated. Please check the timetable.',
          type: 'announcement',
          priority: 'medium',
          createdAt: now.subtract(const Duration(hours: 3)),
          isRead: false,
          actionUrl: '/timetable',
        ),
        NotificationModel(
          id: 'NOTIF_000007',
          userId: 'TCH001',
          title: 'Assignment Deadline',
          message: 'Please submit student assessments for Class 5-B by tomorrow.',
          type: 'announcement',
          priority: 'high',
          createdAt: now.subtract(const Duration(hours: 8)),
          isRead: false,
        ),

        // Parent notifications
        NotificationModel(
          id: 'NOTIF_000008',
          userId: 'PAR001',
          title: 'Parent-Teacher Meeting',
          message: 'Parent-Teacher meeting is scheduled on 20th November 2025 at 10:00 AM.',
          type: 'event',
          priority: 'high',
          createdAt: now.subtract(const Duration(hours: 4)),
          isRead: false,
          actionUrl: '/events',
        ),
        NotificationModel(
          id: 'NOTIF_000009',
          userId: 'PAR001',
          title: 'Student Progress Report',
          message: 'Rahul Kumar\'s progress report for Term 1 is now available.',
          type: 'grade',
          priority: 'medium',
          createdAt: now.subtract(const Duration(days: 1)),
          isRead: false,
          actionUrl: '/grades',
          relatedId: 'STU001',
          relatedType: 'student',
        ),
        NotificationModel(
          id: 'NOTIF_000010',
          userId: 'PAR001',
          title: 'Attendance Alert',
          message: 'Your child was marked absent today. Please contact the school if this is incorrect.',
          type: 'attendance',
          priority: 'high',
          createdAt: now.subtract(const Duration(hours: 6)),
          isRead: true,
          readAt: now.subtract(const Duration(hours: 5)),
          actionUrl: '/attendance',
        ),
      ];

      final success = await _saveAllNotifications(sampleNotifications);
      if (success) {
        print('✅ Sample notifications initialized successfully');
      }
      return success;
    } catch (e) {
      print('❌ Error initializing sample notifications: $e');
      return false;
    }
  }

  /// Clear all data (for testing/reset)
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
      await prefs.remove(_notificationIdCounterKey);
      print('✅ All notification data cleared');
      return true;
    } catch (e) {
      print('❌ Error clearing data: $e');
      return false;
    }
  }
}