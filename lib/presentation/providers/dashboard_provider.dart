// lib/presentation/providers/dashboard_provider.dart
// FIXED VERSION - Properly integrates notifications, announcements, and attendance

import 'package:flutter/material.dart';
import '../../data/services/dashboard_integration_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/announcement_model.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardIntegrationService _integrationService = DashboardIntegrationService();

  // State
  Map<String, dynamic> _dashboardData = {};
  List<NotificationModel> _recentNotifications = [];
  List<AnnouncementModel> _recentAnnouncements = [];
  Map<String, dynamic> _attendanceStats = {};
  List<Map<String, dynamic>> _recentActivities = [];

  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  DateTime? _lastUpdated;

  // Getters
  Map<String, dynamic> get dashboardData => _dashboardData;
  Map<String, dynamic> get stats => _dashboardData; // Alias for compatibility
  List<NotificationModel> get recentNotifications => _recentNotifications;
  List<AnnouncementModel> get recentAnnouncements => _recentAnnouncements;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  Map<String, dynamic> get attendanceStats => _attendanceStats;

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  int get unreadNotificationsCount {
    return _dashboardData['unread_count'] ?? 0;
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize real-time updates (called from main.dart)
  void initializeRealTimeUpdates() {
    // This method is called when the provider is created
    // Can be used to set up any listeners if needed
    debugPrint('✅ DashboardProvider initialized');
  }

  // ============================================================================
  // LOAD DASHBOARD DATA
  // ============================================================================

  /// Load dashboard data based on user role
  Future<void> loadDashboardData(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('📊 Loading dashboard for ${user.role?.name}: ${user.name}');

      final data = await _integrationService.refreshDashboardData(user);

      _dashboardData = data;
      _recentNotifications = _parseNotifications(data['recent_notifications']);
      _recentAnnouncements = _parseAnnouncements(data['recent_announcements']);
      _attendanceStats = data['attendance_stats'] ?? data['attendance_summary'] ?? {};
      _recentActivities = _parseActivities(data['recent_activities']);
      _lastUpdated = DateTime.now();
      _error = null;

      debugPrint('✅ Dashboard loaded successfully');
    } catch (e) {
      _error = 'Failed to load dashboard: ${e.toString()}';
      debugPrint('❌ Error loading dashboard: $e');
      _dashboardData = {};
      _recentNotifications = [];
      _recentAnnouncements = [];
      _attendanceStats = {};
      _recentActivities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh dashboard data (pull to refresh)
  Future<void> refreshDashboard(UserModel user) async {
    _isRefreshing = true;
    notifyListeners();

    try {
      await loadDashboardData(user);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Refresh method for compatibility
  Future<void> refresh(UserModel? user) async {
    if (user != null) {
      await refreshDashboard(user);
    }
  }

  // ============================================================================
  // ADMIN DASHBOARD
  // ============================================================================

  /// Load admin-specific dashboard data
  Future<void> loadAdminDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _integrationService.getAdminDashboardData();

      _dashboardData = data;
      _recentNotifications = _parseNotifications(data['recent_notifications']);
      _recentAnnouncements = _parseAnnouncements(data['recent_announcements']);
      _attendanceStats = data['attendance_stats'] ?? {};
      _recentActivities = _parseActivities(data['recent_activities']);
      _lastUpdated = DateTime.now();
      _error = null;

      debugPrint('✅ Admin dashboard loaded');
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading admin dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get today's attendance statistics (for admin)
  Map<String, dynamic> getTodayAttendanceStats() {
    return _attendanceStats.isNotEmpty
        ? _attendanceStats
        : {
      'total_students': 0,
      'present_today': 0,
      'absent_today': 0,
      'late_today': 0,
      'attendance_percentage': 0.0,
    };
  }

  /// Get pending tasks count
  int getPendingTasksCount() {
    return _dashboardData['pending_tasks'] ?? 0;
  }

  // ============================================================================
  // TEACHER DASHBOARD
  // ============================================================================

  /// Load teacher-specific dashboard data
  Future<void> loadTeacherDashboard({
    required String teacherId,
    required String teacherName,
    required String teacherEmail, // ✅ ADD THIS PARAMETER
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _integrationService.getTeacherDashboardData(
        teacherId: teacherId,
        teacherName: teacherName,
        teacherEmail: teacherEmail, // ✅ PASS EMAIL
      );

      _dashboardData = data;
      _recentNotifications = _parseNotifications(data['recent_notifications']);
      _recentAnnouncements = _parseAnnouncements(data['recent_announcements']);
      _lastUpdated = DateTime.now();
      _error = null;

      debugPrint('✅ Teacher dashboard loaded');
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading teacher dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get assigned classes (for teacher)
  List<Map<String, dynamic>> getAssignedClasses() {
    return List<Map<String, dynamic>>.from(
      _dashboardData['assigned_classes'] ?? [],
    );
  }

  /// Get attendance marking status (for teacher)
  Map<String, dynamic> getAttendanceStatus() {
    return _dashboardData['attendance_status'] ?? {
      'classes_total': 0,
      'attendance_marked': 0,
      'attendance_pending': 0,
    };
  }

  // ============================================================================
  // STUDENT DASHBOARD
  // ============================================================================

  /// Load student-specific dashboard data
  Future<void> loadStudentDashboard({
    required String studentId,
    required String studentName,
    required String className,
    required String studentEmail, // ✅ ALREADY HAS THIS
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _integrationService.getStudentDashboardData(
        studentId: studentId,
        studentName: studentName,
        className: className,
        studentEmail: studentEmail, // ✅ ALREADY PASSES EMAIL
      );

      _dashboardData = data;
      _recentNotifications = _parseNotifications(data['recent_notifications']);
      _recentAnnouncements = _parseAnnouncements(data['recent_announcements']);
      _attendanceStats = data['attendance_summary'] ?? {};
      _lastUpdated = DateTime.now();
      _error = null;

      debugPrint('✅ Student dashboard loaded');
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading student dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get student's attendance summary
  Map<String, dynamic> getStudentAttendanceSummary() {
    return _attendanceStats.isNotEmpty
        ? _attendanceStats
        : {
      'total_days': 0,
      'present_days': 0,
      'absent_days': 0,
      'late_days': 0,
      'attendance_percentage': 0.0,
    };
  }

  /// Get today's attendance (for student)
  Map<String, dynamic>? getTodayAttendance() {
    return _dashboardData['today_attendance'];
  }

  // ============================================================================
  // PARENT DASHBOARD
  // ============================================================================

  /// Load parent-specific dashboard data
  Future<void> loadParentDashboard({
    required String parentId,
    required String parentEmail, // ✅ ADD THIS PARAMETER
    required List<Map<String, dynamic>> children,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _integrationService.getParentDashboardData(
        parentId: parentId,
        parentEmail: parentEmail, // ✅ PASS EMAIL
        children: children,
      );

      _dashboardData = data;
      _recentNotifications = _parseNotifications(data['recent_notifications']);
      _recentAnnouncements = _parseAnnouncements(data['recent_announcements']);
      _lastUpdated = DateTime.now();
      _error = null;

      debugPrint('✅ Parent dashboard loaded');
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading parent dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get children's attendance summary (for parent)
  List<Map<String, dynamic>> getChildrenAttendance() {
    return List<Map<String, dynamic>>.from(
      _dashboardData['children_attendance'] ?? [],
    );
  }

  /// Get children info (for parent)
  List<Map<String, dynamic>> getChildren() {
    return List<Map<String, dynamic>>.from(
      _dashboardData['children'] ?? [],
    );
  }

  // ============================================================================
  // CHART DATA METHODS (for admin_dashboard.dart)
  // ============================================================================

  /// Get student growth trend data for charts
  List<Map<String, dynamic>> getStudentGrowthTrend() {
    return List<Map<String, dynamic>>.from(
      _dashboardData['student_growth_trend'] ?? _generateDummyTrend(),
    );
  }

  /// Get teacher growth trend data for charts
  List<Map<String, dynamic>> getTeacherGrowthTrend() {
    return List<Map<String, dynamic>>.from(
      _dashboardData['teacher_growth_trend'] ?? _generateDummyTrend(),
    );
  }

  /// Get attendance trend data for charts
  List<Map<String, dynamic>> getAttendanceTrend() {
    return List<Map<String, dynamic>>.from(
      _dashboardData['attendance_trend'] ?? _generateDummyTrend(),
    );
  }

  /// Generate dummy trend data for charts
  List<Map<String, dynamic>> _generateDummyTrend() {
    return [
      {'label': 'Jan', 'value': 100},
      {'label': 'Feb', 'value': 150},
      {'label': 'Mar', 'value': 200},
      {'label': 'Apr', 'value': 250},
      {'label': 'May', 'value': 300},
      {'label': 'Jun', 'value': 350},
    ];
  }

  // ============================================================================
  // TIME FORMATTING
  // ============================================================================

  /// Get time ago string for notifications/announcements
  String getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      DateTime dateTime;

      if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else {
        return 'Unknown';
      }

      final Duration difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      debugPrint('Error parsing timestamp: $e');
      return 'Unknown';
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Parse notifications from dashboard data
  List<NotificationModel> _parseNotifications(dynamic data) {
    if (data == null) return [];

    try {
      if (data is List<NotificationModel>) {
        return data;
      }

      if (data is List) {
        return data
            .map((item) => item is NotificationModel
            ? item
            : NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error parsing notifications: $e');
      return [];
    }
  }

  /// Parse announcements from dashboard data
  List<AnnouncementModel> _parseAnnouncements(dynamic data) {
    if (data == null) return [];

    try {
      if (data is List<AnnouncementModel>) {
        return data;
      }

      if (data is List) {
        return data
            .map((item) => item is AnnouncementModel
            ? item
            : AnnouncementModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error parsing announcements: $e');
      return [];
    }
  }

  /// Parse activities from dashboard data
  List<Map<String, dynamic>> _parseActivities(dynamic data) {
    if (data == null) return [];

    try {
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error parsing activities: $e');
      return [];
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if data is stale (older than 5 minutes)
  bool get isDataStale {
    if (_lastUpdated == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated!);
    return difference.inMinutes > 5;
  }

  /// Clear all dashboard data
  void clearData() {
    _dashboardData = {};
    _recentNotifications = [];
    _recentAnnouncements = [];
    _attendanceStats = {};
    _recentActivities = [];
    _error = null;
    _lastUpdated = null;
    notifyListeners();
  }

  /// Get time since last update
  String getTimeSinceLastUpdate() {
    if (_lastUpdated == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(_lastUpdated!);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Get formatted attendance percentage
  String getFormattedAttendancePercentage() {
    final percentage = _attendanceStats['attendance_percentage'] ?? 0.0;
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Check if there are any urgent notifications
  bool hasUrgentNotifications() {
    return _recentNotifications.any((n) => n.priority == 'high' && !n.isRead);
  }

  /// Check if there are any urgent announcements
  bool hasUrgentAnnouncements() {
    return _recentAnnouncements.any((a) => a.priority == 'high');
  }

  /// Get count of items needing attention
  int getItemsNeedingAttention() {
    int count = 0;

    // Unread notifications
    count += unreadNotificationsCount;

    // Pending tasks (admin only)
    count += getPendingTasksCount();

    // Pending attendance (teacher only)
    final attendanceStatus = getAttendanceStatus();
    count += (attendanceStatus['attendance_pending'] ?? 0) as int;

    return count;
  }

  @override
  void dispose() {
    clearData();
    super.dispose();
  }
}