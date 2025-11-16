// lib/presentation/providers/notification_provider.dart
import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/local_notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final LocalNotificationService _localNotificationService = LocalNotificationService();

  // State
  List<NotificationModel> _notifications = [];
  List<NotificationModel> _unreadNotifications = [];
  NotificationSummary? _summary;
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _selectedType;
  bool _showOnlyUnread = false;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => _unreadNotifications;
  NotificationSummary? get summary => _summary;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedType => _selectedType;
  bool get showOnlyUnread => _showOnlyUnread;

  // Filtered notifications based on current filters
  List<NotificationModel> get filteredNotifications {
    var filtered = _notifications;

    if (_selectedType != null) {
      filtered = filtered.where((n) => n.type == _selectedType).toList();
    }

    if (_showOnlyUnread) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }

    return filtered;
  }

  // ===== FETCH METHODS =====

  /// Fetch all notifications for a user
  Future<void> fetchNotifications(String userId, {int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📥 Fetching notifications for user: $userId');
      _notifications = await _localNotificationService.getUserNotifications(
        userId,
        limit: limit,
      );
      _unreadCount = await _localNotificationService.getUnreadCount(userId);
      _error = null;
      print('✅ Fetched ${_notifications.length} notifications, $_unreadCount unread');
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      _error = e.toString();
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch unread notifications only
  Future<void> fetchUnreadNotifications(String userId) async {
    try {
      _unreadNotifications = await _localNotificationService.getUserNotifications(
        userId,
        unreadOnly: true,
      );
      _unreadCount = _unreadNotifications.length;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Fetch notifications by type
  Future<void> fetchNotificationsByType(String userId, String type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _localNotificationService.getUserNotifications(
        userId,
        type: type,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch notification summary
  Future<void> fetchNotificationSummary(String userId) async {
    try {
      _summary = await _localNotificationService.getNotificationSummary(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Fetch unread count only (lightweight)
  Future<void> fetchUnreadCount(String userId) async {
    try {
      _unreadCount = await _localNotificationService.getUnreadCount(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ===== CREATE METHODS =====

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
      final success = await _localNotificationService.createNotification(
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

      if (success) {
        // Refresh notifications after creating
        await fetchNotifications(userId);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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
      final success = await _localNotificationService.createBulkNotifications(
        userIds: userIds,
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

      if (success) {
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===== MARK AS READ METHODS =====

  /// Mark single notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await _localNotificationService.markAsRead(notificationId);

      if (success) {
        // Update local list
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].markAsRead();
        }

        // Update unread notifications
        _unreadNotifications.removeWhere((n) => n.id == notificationId);

        // Decrease unread count
        if (_unreadCount > 0) _unreadCount--;

        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _localNotificationService.markAllAsRead(userId);

      if (success) {
        // Update all notifications to read
        _notifications = _notifications.map((n) => n.markAsRead()).toList();
        _unreadNotifications = [];
        _unreadCount = 0;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===== DELETE METHODS =====

  /// Delete single notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final success = await _localNotificationService.deleteNotification(notificationId);

      if (success) {
        _notifications.removeWhere((n) => n.id == notificationId);
        _unreadNotifications.removeWhere((n) => n.id == notificationId);

        // Recalculate unread count
        _unreadCount = _notifications.where((n) => !n.isRead).length;

        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete all notifications for a user
  Future<bool> deleteAllNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _localNotificationService.clearAllNotifications(userId);

      if (success) {
        _notifications = [];
        _unreadNotifications = [];
        _unreadCount = 0;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
    try {
      final success = await _localNotificationService.sendAttendanceNotification(
        studentId: studentId,
        parentIds: parentIds,
        studentName: studentName,
        status: status,
        date: date,
        markedBy: markedBy,
      );
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
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
    try {
      final success = await _localNotificationService.sendAnnouncementNotification(
        userIds: userIds,
        title: title,
        message: message,
        announcementId: announcementId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        priority: priority,
      );
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
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
    try {
      final success = await _localNotificationService.sendGradeNotification(
        studentId: studentId,
        parentIds: parentIds,
        studentName: studentName,
        subject: subject,
        grade: grade,
        teacherId: teacherId,
      );
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===== FILTER METHODS =====

  /// Set filter type
  void setFilterType(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  /// Toggle show only unread
  void toggleShowOnlyUnread() {
    _showOnlyUnread = !_showOnlyUnread;
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _selectedType = null;
    _showOnlyUnread = false;
    notifyListeners();
  }

  // ===== UTILITY METHODS =====

  /// Check if there are unread notifications
  bool hasUnreadNotifications() {
    return _unreadCount > 0;
  }

  /// Get notifications count by type
  int getCountByType(String type) {
    return _notifications.where((n) => n.type == type).length;
  }

  /// Clear all data
  void clearData() {
    _notifications = [];
    _unreadNotifications = [];
    _summary = null;
    _unreadCount = 0;
    _error = null;
    _selectedType = null;
    _showOnlyUnread = false;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshAll(String userId) async {
    await Future.wait([
      fetchNotifications(userId),
      fetchUnreadNotifications(userId),
      fetchNotificationSummary(userId),
      fetchUnreadCount(userId),
    ]);
  }

  /// Initialize sample data (call once on first launch)
  Future<bool> initializeSampleData() async {
    try {
      return await _localNotificationService.initializeSampleNotifications();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}