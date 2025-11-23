// lib/data/services/dashboard_integration_service.dart
// This service integrates notifications, announcements, and attendance across all dashboards

import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../models/announcement_model.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import 'local_notification_service.dart';
import 'attendance_service.dart';
import '../repositories/announcement_repository.dart';

class DashboardIntegrationService {
  final LocalNotificationService _notificationService = LocalNotificationService();
  final AttendanceService _attendanceService = AttendanceService();
  final AnnouncementRepository _announcementRepo = AnnouncementRepository();

  // ============================================================================
  // ADMIN DASHBOARD DATA
  // ============================================================================

  /// Get complete admin dashboard data
  Future<Map<String, dynamic>> getAdminDashboardData() async {
    try {
      print('📊 Loading admin dashboard data...');

      final results = await Future.wait([
        _getRecentNotifications('ADM001', limit: 5),
        _getRecentAnnouncements(userRole: 'admin', limit: 5),
        _getTodayAttendanceStats(),
        _getUnreadNotificationsCount('ADM001'),
        _getPendingTasksCount(),
      ]);

      final data = {
        'recent_notifications': results[0],
        'recent_announcements': results[1],
        'attendance_stats': results[2],
        'unread_count': results[3],
        'pending_tasks': results[4],
        'last_updated': DateTime.now().toIso8601String(),
      };

      print('✅ Admin dashboard data loaded successfully');
      return data;
    } catch (e) {
      print('❌ Error loading admin dashboard data: $e');
      return _getEmptyAdminData();
    }
  }

  /// Get today's attendance statistics
  Future<Map<String, dynamic>> _getTodayAttendanceStats() async {
    try {
      final stats = await _attendanceService.getAttendanceStatistics();
      return {
        'total_students': stats['total_students'] ?? 0,
        'present_today': stats['present_today'] ?? 0,
        'absent_today': stats['absent_today'] ?? 0,
        'late_today': stats['late_today'] ?? 0,
        'attendance_percentage': stats['average_attendance'] ?? 0.0,
      };
    } catch (e) {
      print('❌ Error getting attendance stats: $e');
      return {
        'total_students': 0,
        'present_today': 0,
        'absent_today': 0,
        'late_today': 0,
        'attendance_percentage': 0.0,
      };
    }
  }

  /// Get pending tasks count (for admin)
  Future<int> _getPendingTasksCount() async {
    // TODO: Implement actual pending tasks logic
    return 0;
  }

  Map<String, dynamic> _getEmptyAdminData() {
    return {
      'recent_notifications': [],
      'recent_announcements': [],
      'attendance_stats': {
        'total_students': 0,
        'present_today': 0,
        'absent_today': 0,
        'late_today': 0,
        'attendance_percentage': 0.0,
      },
      'unread_count': 0,
      'pending_tasks': 0,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // ============================================================================
  // TEACHER DASHBOARD DATA
  // ============================================================================

  /// Get complete teacher dashboard data
  Future<Map<String, dynamic>> getTeacherDashboardData({
    required String teacherId,
    required String teacherName,
  }) async {
    try {
      print('👨‍🏫 Loading teacher dashboard data for: $teacherName');

      final results = await Future.wait([
        _getRecentNotifications(teacherId, limit: 5),
        _getRecentAnnouncements(userRole: 'teacher', limit: 5),
        _getTeacherClasses(teacherId),
        _getUnreadNotificationsCount(teacherId),
        _getTodayClassAttendanceStatus(teacherId),
      ]);

      final data = {
        'recent_notifications': results[0],
        'recent_announcements': results[1],
        'assigned_classes': results[2],
        'unread_count': results[3],
        'attendance_status': results[4],
        'teacher_id': teacherId,
        'teacher_name': teacherName,
        'last_updated': DateTime.now().toIso8601String(),
      };

      print('✅ Teacher dashboard data loaded successfully');
      return data;
    } catch (e) {
      print('❌ Error loading teacher dashboard data: $e');
      return _getEmptyTeacherData(teacherId, teacherName);
    }
  }

  /// Get teacher's assigned classes
  Future<List<Map<String, dynamic>>> _getTeacherClasses(String teacherId) async {
    // TODO: Implement actual teacher classes fetching
    return [];
  }

  /// Get today's class attendance status for teacher
  Future<Map<String, dynamic>> _getTodayClassAttendanceStatus(String teacherId) async {
    try {
      // Check if attendance is marked for teacher's classes today
      final today = DateTime.now();
      // TODO: Implement actual logic based on teacher's assigned classes
      return {
        'classes_total': 0,
        'attendance_marked': 0,
        'attendance_pending': 0,
      };
    } catch (e) {
      print('❌ Error getting class attendance status: $e');
      return {
        'classes_total': 0,
        'attendance_marked': 0,
        'attendance_pending': 0,
      };
    }
  }

  Map<String, dynamic> _getEmptyTeacherData(String teacherId, String teacherName) {
    return {
      'recent_notifications': [],
      'recent_announcements': [],
      'assigned_classes': [],
      'unread_count': 0,
      'attendance_status': {
        'classes_total': 0,
        'attendance_marked': 0,
        'attendance_pending': 0,
      },
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // ============================================================================
  // STUDENT DASHBOARD DATA
  // ============================================================================

  /// Get complete student dashboard data
  Future<Map<String, dynamic>> getStudentDashboardData({
    required String studentId,
    required String studentName,
    required String className,
  }) async {
    try {
      print('👨‍🎓 Loading student dashboard data for: $studentName');

      final results = await Future.wait([
        _getRecentNotifications(studentId, limit: 5),
        _getRecentAnnouncements(userRole: 'student', limit: 5),
        _getStudentAttendanceSummary(studentId),
        _getUnreadNotificationsCount(studentId),
        _getTodayStudentAttendance(studentId),
      ]);

      final data = {
        'recent_notifications': results[0],
        'recent_announcements': results[1],
        'attendance_summary': results[2],
        'unread_count': results[3],
        'today_attendance': results[4],
        'student_id': studentId,
        'student_name': studentName,
        'class_name': className,
        'last_updated': DateTime.now().toIso8601String(),
      };

      print('✅ Student dashboard data loaded successfully');
      return data;
    } catch (e) {
      print('❌ Error loading student dashboard data: $e');
      return _getEmptyStudentData(studentId, studentName, className);
    }
  }

  /// Get student's attendance summary
  Future<Map<String, dynamic>> _getStudentAttendanceSummary(String studentId) async {
    try {
      final summary = await _attendanceService.getAttendanceSummary(
        studentId: studentId,
      );

      if (summary == null) {
        return {
          'total_days': 0,
          'present_days': 0,
          'absent_days': 0,
          'late_days': 0,
          'attendance_percentage': 0.0,
        };
      }

      return {
        'total_days': summary.totalDays,
        'present_days': summary.presentDays,
        'absent_days': summary.absentDays,
        'late_days': summary.lateDays,
        'attendance_percentage': summary.attendancePercentage,
      };
    } catch (e) {
      print('❌ Error getting student attendance summary: $e');
      return {
        'total_days': 0,
        'present_days': 0,
        'absent_days': 0,
        'late_days': 0,
        'attendance_percentage': 0.0,
      };
    }
  }

  /// Get today's attendance for student
  Future<Map<String, dynamic>?> _getTodayStudentAttendance(String studentId) async {
    try {
      final attendance = await _attendanceService.getTodayAttendance(studentId);

      if (attendance == null) {
        return null;
      }

      return {
        'status': attendance.status,
        'marked_at': attendance.markedAt.toIso8601String(),
        'marked_by': attendance.markedByName,
        'remarks': attendance.remarks,
      };
    } catch (e) {
      print('❌ Error getting today\'s attendance: $e');
      return null;
    }
  }

  Map<String, dynamic> _getEmptyStudentData(
      String studentId,
      String studentName,
      String className,
      ) {
    return {
      'recent_notifications': [],
      'recent_announcements': [],
      'attendance_summary': {
        'total_days': 0,
        'present_days': 0,
        'absent_days': 0,
        'late_days': 0,
        'attendance_percentage': 0.0,
      },
      'unread_count': 0,
      'today_attendance': null,
      'student_id': studentId,
      'student_name': studentName,
      'class_name': className,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // ============================================================================
  // PARENT DASHBOARD DATA
  // ============================================================================

  /// Get complete parent dashboard data
  Future<Map<String, dynamic>> getParentDashboardData({
    required String parentId,
    required List<Map<String, dynamic>> children,
  }) async {
    try {
      print('👨‍👩‍👧‍👦 Loading parent dashboard data for parent: $parentId');

      final results = await Future.wait([
        _getRecentNotifications(parentId, limit: 5),
        _getRecentAnnouncements(userRole: 'parent', limit: 5),
        _getUnreadNotificationsCount(parentId),
        _getChildrenAttendanceSummary(children),
      ]);

      final data = {
        'recent_notifications': results[0],
        'recent_announcements': results[1],
        'unread_count': results[2],
        'children_attendance': results[3],
        'children': children,
        'parent_id': parentId,
        'last_updated': DateTime.now().toIso8601String(),
      };

      print('✅ Parent dashboard data loaded successfully');
      return data;
    } catch (e) {
      print('❌ Error loading parent dashboard data: $e');
      return _getEmptyParentData(parentId, children);
    }
  }

  /// Get attendance summary for all children
  Future<List<Map<String, dynamic>>> _getChildrenAttendanceSummary(
      List<Map<String, dynamic>> children,
      ) async {
    try {
      final summaries = <Map<String, dynamic>>[];

      for (var child in children) {
        final studentId = child['student_id'] as String;
        final summary = await _getStudentAttendanceSummary(studentId);
        final todayAttendance = await _getTodayStudentAttendance(studentId);

        summaries.add({
          'student_id': studentId,
          'student_name': child['name'],
          'class': child['class'],
          'summary': summary,
          'today_attendance': todayAttendance,
        });
      }

      return summaries;
    } catch (e) {
      print('❌ Error getting children attendance: $e');
      return [];
    }
  }

  Map<String, dynamic> _getEmptyParentData(
      String parentId,
      List<Map<String, dynamic>> children,
      ) {
    return {
      'recent_notifications': [],
      'recent_announcements': [],
      'unread_count': 0,
      'children_attendance': [],
      'children': children,
      'parent_id': parentId,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // ============================================================================
  // SHARED HELPER METHODS
  // ============================================================================

  /// Get recent notifications for a user
  Future<List<NotificationModel>> _getRecentNotifications(
      String userId, {
        int limit = 5,
      }) async {
    try {
      return await _notificationService.getUserNotifications(
        userId,
        limit: limit,
      );
    } catch (e) {
      print('❌ Error getting recent notifications: $e');
      return [];
    }
  }

  /// Get recent announcements
  Future<List<AnnouncementModel>> _getRecentAnnouncements({
    String? userRole,
    int limit = 5,
  }) async {
    try {
      return await _announcementRepo.getRecentAnnouncements(
        userRole: userRole,
        limit: limit,
      );
    } catch (e) {
      print('❌ Error getting recent announcements: $e');
      return [];
    }
  }

  /// Get unread notifications count
  Future<int> _getUnreadNotificationsCount(String userId) async {
    try {
      return await _notificationService.getUnreadCount(userId);
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  // ============================================================================
  // REAL-TIME UPDATES
  // ============================================================================

  /// Send notification when attendance is marked
  Future<void> notifyAttendanceMarked({
    required String studentId,
    required String studentName,
    required String status,
    required String markedBy,
    required String className,
    List<String>? parentIds,
  }) async {
    try {
      final date = DateTime.now();
      final formattedDate = '${date.day}/${date.month}/${date.year}';

      // Create notification for student
      await _notificationService.createNotification(
        userId: studentId,
        title: 'Attendance Marked',
        message: 'Your attendance for today ($formattedDate) has been marked as $status',
        type: 'attendance',
        priority: status.toLowerCase() == 'absent' ? 'high' : 'medium',
        senderId: markedBy,
        senderRole: 'teacher',
      );

      // Create notifications for parents
      if (parentIds != null && parentIds.isNotEmpty) {
        await _notificationService.sendAttendanceNotification(
          studentId: studentId,
          parentIds: parentIds,
          studentName: studentName,
          status: status,
          date: formattedDate,
          markedBy: markedBy,
        );
      }

      print('✅ Attendance notifications sent successfully');
    } catch (e) {
      print('❌ Error sending attendance notifications: $e');
    }
  }

  /// Send notification when announcement is created
  Future<void> notifyAnnouncementCreated({
    required AnnouncementModel announcement,
    required List<String> targetUserIds,
  }) async {
    try {
      await _notificationService.sendAnnouncementNotification(
        userIds: targetUserIds,
        title: announcement.title,
        message: announcement.message,
        announcementId: announcement.id,
        senderId: announcement.createdBy,
        senderName: announcement.createdByName,
        senderRole: announcement.createdByRole,
        priority: announcement.priority,
      );

      print('✅ Announcement notifications sent to ${targetUserIds.length} users');
    } catch (e) {
      print('❌ Error sending announcement notifications: $e');
    }
  }

  // ============================================================================
  // DASHBOARD REFRESH
  // ============================================================================

  /// Refresh dashboard data based on user role
  Future<Map<String, dynamic>> refreshDashboardData(UserModel user) async {
    switch (user.role?.name) {
      case 'admin':
        return await getAdminDashboardData();
      case 'teacher':
        return await getTeacherDashboardData(
          teacherId: user.id,
          teacherName: user.name,
        );
      case 'student':
      // Assuming student has class info in metadata
        final className = user.email.split('@')[0]; // Placeholder
        return await getStudentDashboardData(
          studentId: user.id,
          studentName: user.name,
          className: className,
        );
      case 'parent':
      // TODO: Get actual children data
        return await getParentDashboardData(
          parentId: user.id,
          children: [],
        );
      default:
        return {};
    }
  }
}