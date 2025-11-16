// lib/data/services/activity_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_stats_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'activities';

  /// Log a new activity
  Future<bool> logActivity({
    required String title,
    required String description,
    required String type,
    required String userName,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final activity = {
        'id': _firestore.collection(_collection).doc().id,
        'title': title,
        'description': description,
        'type': type,
        'userName': userName,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection(_collection).add(activity);
      print('✅ Activity logged: $title');
      return true;
    } catch (e) {
      print('❌ Error logging activity: $e');
      return false;
    }
  }

  /// Get recent activities
  Future<List<RecentActivity>> getRecentActivities({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return RecentActivity(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          type: data['type'] ?? 'info',
          userName: data['userName'] ?? 'Unknown',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching activities: $e');
      return [];
    }
  }

  /// Get activities by type
  Future<List<RecentActivity>> getActivitiesByType({
    required String type,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('type', isEqualTo: type)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return RecentActivity(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          type: data['type'] ?? 'info',
          userName: data['userName'] ?? 'Unknown',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('❌ Error fetching activities by type: $e');
      return [];
    }
  }

  /// Get activities stream (real-time updates)
  Stream<List<RecentActivity>> getActivitiesStream({int limit = 10}) {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return RecentActivity(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          type: data['type'] ?? 'info',
          userName: data['userName'] ?? 'Unknown',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  /// Delete old activities (cleanup)
  Future<void> deleteOldActivities({int daysToKeep = 90}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final snapshot = await _firestore
          .collection(_collection)
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('✅ Deleted ${snapshot.docs.length} old activities');
    } catch (e) {
      print('❌ Error deleting old activities: $e');
    }
  }

  // ==================== QUICK LOG METHODS ====================

  /// Log student admission
  Future<void> logStudentAdmission(String studentName, String className) async {
    await logActivity(
      title: 'New Student Admission',
      description: '$studentName enrolled in $className',
      type: 'student',
      userName: studentName,
    );
  }

  /// Log teacher assignment
  Future<void> logTeacherAssignment(String teacherName, String subject, String className) async {
    await logActivity(
      title: 'Teacher Assignment Updated',
      description: '$teacherName assigned to teach $subject in $className',
      type: 'teacher',
      userName: teacherName,
    );
  }

  /// Log announcement creation
  Future<void> logAnnouncementCreated(String title, String createdBy) async {
    await logActivity(
      title: 'Announcement Posted',
      description: title,
      type: 'announcement',
      userName: createdBy,
    );
  }

  /// Log attendance marking
  Future<void> logAttendanceMarked(String className, int present, int total) async {
    await logActivity(
      title: 'Attendance Marked',
      description: '$className attendance marked - $present/$total present',
      type: 'attendance',
      userName: 'Teacher',
    );
  }

  /// Log fee payment
  Future<void> logFeePayment(String studentName, String className, double amount) async {
    await logActivity(
      title: 'Fee Payment Received',
      description: 'Monthly fee (₹${amount.toStringAsFixed(0)}) paid by $studentName ($className)',
      type: 'fee',
      userName: studentName,
    );
  }

  /// Log event creation
  Future<void> logEventCreated(String eventName, DateTime eventDate) async {
    await logActivity(
      title: 'Event Created',
      description: '$eventName scheduled for ${eventDate.day}/${eventDate.month}/${eventDate.year}',
      type: 'event',
      userName: 'Admin',
    );
  }

  /// Log exam schedule
  Future<void> logExamScheduled(String examName, DateTime examDate) async {
    await logActivity(
      title: 'Exam Schedule Published',
      description: '$examName scheduled for ${examDate.day}/${examDate.month}/${examDate.year}',
      type: 'exam',
      userName: 'Admin',
    );
  }

  /// Log library transaction
  Future<void> logLibraryTransaction(String studentName, String bookName, String action) async {
    await logActivity(
      title: 'Library Book $action',
      description: '$bookName $action to $studentName',
      type: 'library',
      userName: studentName,
    );
  }

  /// Log meeting scheduled
  Future<void> logMeetingScheduled(String meetingTitle, DateTime meetingDate) async {
    await logActivity(
      title: 'Meeting Scheduled',
      description: '$meetingTitle scheduled for ${meetingDate.day}/${meetingDate.month}/${meetingDate.year}',
      type: 'meeting',
      userName: 'Admin',
    );
  }
}