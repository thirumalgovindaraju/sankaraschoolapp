// lib/data/services/notification_service.dart

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService(this._apiService);

  // ============================================================================
  // BASIC NOTIFICATION METHODS
  // ============================================================================

  /// Fetch notifications for a specific user
  Future<List<NotificationModel>> fetchNotifications(
      String userId, {
        bool unreadOnly = false,
        String? type,
        int page = 1,
        int limit = 50,
      }) async {
    try {
      final queryParams = {
        'user_id': userId,
        'unread_only': unreadOnly.toString(),
        if (type != null) 'type': type,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiService.get('/notifications?$queryString');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different response structures
        final notificationsList = data['data'] ?? data['notifications'] ?? [];

        return (notificationsList as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _apiService.get(
        '/notifications/unread-count?user_id=${Uri.encodeComponent(userId)}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']?['count'] ?? data['count'] ?? 0;
      }

      return 0;
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
      return 0;
    }
  }

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    try {
      final response = await _apiService.get('/notifications/$notificationId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notificationData = data['data'] ?? data;
        return NotificationModel.fromJson(notificationData);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching notification: $e');
      return null;
    }
  }

  /// Get notification summary
  Future<NotificationSummary?> getNotificationSummary(String userId) async {
    try {
      final response = await _apiService.get(
        '/notifications/summary?user_id=${Uri.encodeComponent(userId)}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NotificationSummary.fromJson(data['data'] ?? data);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching notification summary: $e');
      return null;
    }
  }

  // ============================================================================
  // NOTIFICATION ACTIONS
  // ============================================================================

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.put(
        '/notifications/$notificationId/read',
        {},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read for a user
  Future<bool> markAllAsRead(String userId) async {
    try {
      final response = await _apiService.put(
        '/notifications/mark-all-read',
        {'user_id': userId},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService.delete(
        '/notifications/$notificationId',
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  // ============================================================================
  // SEND NOTIFICATIONS
  // ============================================================================

  /// Create single notification
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
    String? senderId,
    String? senderName,
    String? senderRole,
  }) async {
    try {
      final response = await _apiService.post(
        '/notifications',
        {
          'user_id': userId,
          'title': title,
          'message': message,
          'type': type,
          'priority': priority,
          if (relatedId != null) 'related_id': relatedId,
          if (relatedType != null) 'related_type': relatedType,
          if (data != null) 'data': data,
          if (actionUrl != null) 'action_url': actionUrl,
          if (senderId != null) 'sender_id': senderId,
          if (senderName != null) 'sender_name': senderName,
          if (senderRole != null) 'sender_role': senderRole,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating notification: $e');
      return false;
    }
  }

  /// Create bulk notifications
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
      final response = await _apiService.post(
        '/notifications/bulk',
        {
          'user_ids': userIds,
          'title': title,
          'message': message,
          'type': type,
          'priority': priority,
          if (relatedId != null) 'related_id': relatedId,
          if (relatedType != null) 'related_type': relatedType,
          if (data != null) 'data': data,
          if (actionUrl != null) 'action_url': actionUrl,
          if (senderId != null) 'sender_id': senderId,
          if (senderName != null) 'sender_name': senderName,
          if (senderRole != null) 'sender_role': senderRole,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating bulk notifications: $e');
      return false;
    }
  }

  /// Send notification (simple version for admin/teacher)
  Future<bool> sendNotification({
    required String title,
    required String message,
    required List<String> recipientIds,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _apiService.post(
        '/notifications/send',
        {
          'title': title,
          'message': message,
          'recipient_ids': recipientIds,
          'type': type ?? 'general',
          if (data != null) 'data': data,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }

  // ============================================================================
  // HELPER METHODS FOR SPECIFIC NOTIFICATION TYPES
  // ============================================================================

  /// Send attendance notification
  Future<bool> sendAttendanceNotification({
    required String studentId,
    required List<String> parentIds,
    required String studentName,
    required String status,
    required String date,
    required String markedBy,
  }) async {
    return await createBulkNotifications(
      userIds: [studentId, ...parentIds],
      title: 'Attendance Update',
      message: '$studentName was marked $status on $date',
      type: 'attendance',
      priority: status.toLowerCase() == 'absent' ? 'high' : 'medium',
      relatedType: 'attendance',
      senderId: markedBy,
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
      title: 'New Announcement: $title',
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
    return await createBulkNotifications(
      userIds: [studentId, ...parentIds],
      title: 'Grade Updated',
      message: '$studentName received $grade in $subject',
      type: 'grade',
      priority: 'medium',
      relatedType: 'grade',
      senderId: teacherId,
      senderRole: 'teacher',
    );
  }

  /// Send fee reminder notification
  Future<bool> sendFeeReminderNotification({
    required String studentId,
    required List<String> parentIds,
    required String studentName,
    required String amount,
    required String dueDate,
  }) async {
    return await createBulkNotifications(
      userIds: [studentId, ...parentIds],
      title: 'Fee Payment Reminder',
      message: 'Fee payment of $amount for $studentName is due on $dueDate',
      type: 'fee',
      priority: 'high',
      relatedType: 'fee',
    );
  }

  /// Send exam schedule notification
  Future<bool> sendExamScheduleNotification({
    required List<String> userIds,
    required String examName,
    required String subject,
    required String date,
    required String time,
  }) async {
    return await createBulkNotifications(
      userIds: userIds,
      title: 'Exam Schedule: $examName',
      message: '$subject exam scheduled on $date at $time',
      type: 'exam',
      priority: 'high',
      relatedType: 'exam',
    );
  }

  /// Send leave approval/rejection notification
  Future<bool> sendLeaveStatusNotification({
    required String userId,
    required String status,
    required String leaveType,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    final statusText = status.toLowerCase() == 'approved' ? 'approved' : 'rejected';
    return await createNotification(
      userId: userId,
      title: 'Leave Request ${statusText.toUpperCase()}',
      message: 'Your $leaveType leave from $startDate to $endDate has been $statusText${reason != null ? '. Reason: $reason' : ''}',
      type: 'leave',
      priority: 'medium',
      relatedType: 'leave',
    );
  }
}