// lib/data/repositories/announcement_repository.dart
// COMPLETE FINAL VERSION WITH EMAIL-BASED NOTIFICATIONS

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';
import '../services/local_notification_service.dart';

class AnnouncementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'announcements';
  final LocalNotificationService _notificationService = LocalNotificationService();

  // ============================================================================
  // CREATE - WITH NOTIFICATION SUPPORT
  // ============================================================================

  Future<bool> createAnnouncement(
      AnnouncementModel announcement, {
        bool sendNotifications = true,
      }) async {
    try {
      final docId = announcement.id.isEmpty
          ? _firestore.collection(_collection).doc().id
          : announcement.id;

      final announcementWithId = AnnouncementModel(
        id: docId,
        title: announcement.title,
        message: announcement.message,
        type: announcement.type,
        priority: announcement.priority,
        targetAudience: announcement.targetAudience,
        targetClasses: announcement.targetClasses,
        createdBy: announcement.createdBy,
        createdByName: announcement.createdByName,
        createdByRole: announcement.createdByRole,
        createdAt: announcement.createdAt,
        expiryDate: announcement.expiryDate,
        attachments: announcement.attachments,
        readBy: announcement.readBy,
        targetStudents: announcement.targetStudents,
        attachmentUrl: announcement.attachmentUrl,
        attachmentName: announcement.attachmentName,
        isActive: announcement.isActive,
        isPinned: announcement.isPinned,
      );

      // Save to Firestore
      await _firestore
          .collection(_collection)
          .doc(docId)
          .set(announcementWithId.toJson());

      print('✅ Announcement created in Firestore: $docId');

      // Create notifications for target users
      if (sendNotifications) {
        await _createNotificationsForAnnouncement(announcementWithId);
      }

      return true;
    } catch (e) {
      print('❌ Error creating announcement: $e');
      return false;
    }
  }

  // ============================================================================
  // NOTIFICATION CREATION HELPER
  // ============================================================================

  Future<void> _createNotificationsForAnnouncement(
      AnnouncementModel announcement,
      ) async {
    try {
      print('📤 Creating notifications for announcement: ${announcement.id}');
      print('🎯 Target Audience: ${announcement.targetAudience}');
      print('🎯 Target Classes: ${announcement.targetClasses}');

      // Get target user emails (using emails as user IDs)
      final targetUserEmails = await _getTargetUserEmails(
        announcement.targetAudience,
        announcement.targetClasses,
      );

      if (targetUserEmails.isEmpty) {
        print('⚠️ No target users found for announcement');
        return;
      }

      print('📨 Sending notifications to ${targetUserEmails.length} users');

      // Create notifications using emails as user IDs
      final success = await _notificationService.createBulkNotifications(
        userIds: targetUserEmails, // Using emails as IDs
        title: announcement.title,
        message: announcement.message.length > 100
            ? '${announcement.message.substring(0, 100)}...'
            : announcement.message,
        type: 'announcement',
        priority: announcement.priority,
        relatedId: announcement.id,
        relatedType: 'announcement',
        actionUrl: '/announcements/${announcement.id}',
        senderId: announcement.createdBy,
        senderName: announcement.createdByName,
        senderRole: announcement.createdByRole,
      );

      if (success) {
        print('✅ Notifications created for ${targetUserEmails.length} users');
      } else {
        print('⚠️ Some notifications may have failed');
      }
    } catch (e) {
      print('❌ Error creating notifications: $e');
    }
  }

  Future<List<String>> _getTargetUserEmails(
      List<String> targetAudience,
      List<String> targetClasses,
      ) async {
    Set<String> userEmails = {};

    try {
      for (String audience in targetAudience) {
        // Normalize the audience string
        final audienceLower = audience.toLowerCase().trim();

        print('🔍 Processing audience: $audience (normalized: $audienceLower)');

        // Check for "all" or complete match
        if (audienceLower == 'all' ||
            audienceLower.contains('all students') ||
            audienceLower.contains('all parents') ||
            audienceLower.contains('all teachers') ||
            audienceLower.contains('all staff')) {

          // Determine which specific group to fetch
          if (audienceLower == 'all') {
            // Fetch everything
            print('📋 Fetching ALL users (students, teachers, parents)...');
            userEmails.addAll(await _getAllStudentEmails());
            userEmails.addAll(await _getAllTeacherEmails());
            userEmails.addAll(await _getAllParentEmails());
          } else if (audienceLower.contains('student')) {
            print('📋 Fetching all students...');
            userEmails.addAll(await _getAllStudentEmails(targetClasses: targetClasses));
          } else if (audienceLower.contains('parent')) {
            print('📋 Fetching all parents...');
            userEmails.addAll(await _getAllParentEmails(targetClasses: targetClasses));
          } else if (audienceLower.contains('teacher') || audienceLower.contains('staff')) {
            print('📋 Fetching all teachers...');
            userEmails.addAll(await _getAllTeacherEmails());
          }
        }
        // Check for individual audience types (without "all" prefix)
        else if (audienceLower == 'student' || audienceLower.contains('student')) {
          print('📋 Fetching students...');
          userEmails.addAll(await _getAllStudentEmails(targetClasses: targetClasses));
        } else if (audienceLower == 'teacher' || audienceLower.contains('teacher') ||
            audienceLower == 'staff' || audienceLower.contains('staff')) {
          print('📋 Fetching teachers...');
          userEmails.addAll(await _getAllTeacherEmails());
        } else if (audienceLower == 'parent' || audienceLower.contains('parent')) {
          print('📋 Fetching parents...');
          userEmails.addAll(await _getAllParentEmails(targetClasses: targetClasses));
        } else {
          print('⚠️ Unknown audience type: $audience');
        }
      }

      print('✅ Found ${userEmails.length} unique target user emails');
      print('📧 Sample emails: ${userEmails.take(5).join(", ")}');
      return userEmails.toList();
    } catch (e) {
      print('❌ Error getting target user emails: $e');
      return [];
    }
  }

  Future<List<String>> _getAllStudentEmails({
    List<String>? targetClasses,
  }) async {
    try {
      Query query = _firestore.collection('students');

      if (targetClasses != null && targetClasses.isNotEmpty) {
        query = query.where('class', whereIn: targetClasses);
        print('🔍 Filtering students by classes: $targetClasses');
      }

      final snapshot = await query.get();
      final emails = snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['email'] as String?;
      })
          .where((email) =>
      email != null && email.isNotEmpty && email != 'null')
          .cast<String>()
          .toList();

      print('✅ Found ${emails.length} student emails');
      return emails;
    } catch (e) {
      print('❌ Error fetching student emails: $e');
      return [];
    }
  }

  Future<List<String>> _getAllTeacherEmails() async {
    try {
      final snapshot = await _firestore.collection('teachers').get();
      final emails = snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['email'] as String?;
      })
          .where((email) =>
      email != null && email.isNotEmpty && email != 'null')
          .cast<String>()
          .toList();

      print('✅ Found ${emails.length} teacher emails');
      return emails;
    } catch (e) {
      print('❌ Error fetching teacher emails: $e');
      return [];
    }
  }

  Future<List<String>> _getAllParentEmails({
    List<String>? targetClasses,
  }) async {
    try {
      Set<String> parentEmails = {};

      Query query = _firestore.collection('students');

      if (targetClasses != null && targetClasses.isNotEmpty) {
        query = query.where('class', whereIn: targetClasses);
        print('🔍 Filtering parent emails by student classes: $targetClasses');
      }

      final snapshot = await query.get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Get parent_details object
        final parentDetails = data['parent_details'] as Map<String, dynamic>?;

        if (parentDetails != null) {
          // Father's email
          final fatherEmail = parentDetails['father_email'] as String?;
          if (fatherEmail != null &&
              fatherEmail.isNotEmpty &&
              fatherEmail != 'null') {
            parentEmails.add(fatherEmail);
          }

          // Mother's email
          final motherEmail = parentDetails['mother_email'] as String?;
          if (motherEmail != null &&
              motherEmail.isNotEmpty &&
              motherEmail != 'null') {
            parentEmails.add(motherEmail);
          }
        }

        // Fallback: Check for direct parent_id field (if exists)
        final parentId = data['parent_id'] as String?;
        if (parentId != null && parentId.isNotEmpty && parentId != 'null') {
          parentEmails.add(parentId);
        }
      }

      print('✅ Found ${parentEmails.length} unique parent emails');
      return parentEmails.toList();
    } catch (e) {
      print('❌ Error fetching parent emails: $e');
      return [];
    }
  }

  // ============================================================================
  // READ - WITH FALLBACK FOR INDEX ISSUES
  // ============================================================================

  Future<List<AnnouncementModel>> getAnnouncements({
    String? userRole,
    String? userId,
    bool activeOnly = true,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // ✅ Try indexed query first (fast but requires index)
      if (activeOnly && userRole != null && userRole.isNotEmpty) {
        try {
          Query query = _firestore
              .collection(_collection)
              .where('isActive', isEqualTo: true)
              .where('targetAudience', arrayContainsAny: [userRole, 'all'])
              .orderBy('createdAt', descending: true)
              .limit(limit);

          final snapshot = await query.get();

          final announcements = snapshot.docs
              .map((doc) => AnnouncementModel.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }))
              .toList();

          print(
              '✅ Fetched ${announcements.length} announcements (indexed query)');
          return announcements;
        } catch (indexError) {
          print('! Index not ready, using fallback query');

          // ✅ FALLBACK: Simple query + memory filtering
          Query fallbackQuery = _firestore
              .collection(_collection)
              .orderBy('createdAt', descending: true)
              .limit(50);

          final snapshot = await fallbackQuery.get();

          // Filter in memory
          final announcements = snapshot.docs
              .map((doc) => AnnouncementModel.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }))
              .where((announcement) {
            // Filter by active status
            if (activeOnly && !announcement.isActive) return false;

            // Filter by target audience
            if (userRole != null) {
              return announcement.targetAudience.contains(userRole) ||
                  announcement.targetAudience.contains('all');
            }

            return true;
          })
              .take(limit)
              .toList();

          print('✅ Fetched ${announcements.length} announcements (fallback)');
          return announcements;
        }
      } else {
        // ✅ Simple query (no filters needed)
        Query query = _firestore
            .collection(_collection)
            .orderBy('createdAt', descending: true)
            .limit(limit);

        final snapshot = await query.get();

        final announcements = snapshot.docs
            .map((doc) => AnnouncementModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        }))
            .toList();

        print('✅ Fetched ${announcements.length} announcements (simple query)');
        return announcements;
      }
    } catch (e) {
      print('❌ Error fetching announcements: $e');
      return [];
    }
  }

  Future<AnnouncementModel?> getAnnouncementById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        print('⚠️ Announcement not found: $id');
        return null;
      }

      return AnnouncementModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });
    } catch (e) {
      print('❌ Error fetching announcement by ID: $e');
      return null;
    }
  }

  Future<List<AnnouncementModel>> getRecentAnnouncements({
    String? userRole,
    String? userId,
    int limit = 5,
  }) async {
    return await getAnnouncements(
      userRole: userRole,
      userId: userId,
      activeOnly: true,
      page: 1,
      limit: limit,
    );
  }

  Future<List<AnnouncementModel>> getUrgentAnnouncements({
    String? userRole,
    String? userId,
  }) async {
    try {
      // Simple query first
      Query query = _firestore
          .collection(_collection)
          .where('priority', isEqualTo: 'high')
          .orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      // Filter in memory
      return snapshot.docs
          .map((doc) => AnnouncementModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
          .where((a) => a.isActive)
          .where((a) =>
      userRole == null ||
          a.targetAudience.contains(userRole) ||
          a.targetAudience.contains('all'))
          .toList();
    } catch (e) {
      print('❌ Error fetching urgent announcements: $e');
      return [];
    }
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  Future<bool> updateAnnouncement({
    required String id,
    required AnnouncementModel announcement,
  }) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(announcement.toJson());

      print('✅ Announcement updated: $id');
      return true;
    } catch (e) {
      print('❌ Error updating announcement: $e');
      return false;
    }
  }

  Future<bool> markAsRead({
    required String announcementId,
    required String userId,
  }) async {
    try {
      await _firestore.collection(_collection).doc(announcementId).update({
        'readBy': FieldValue.arrayUnion([userId]),
      });

      print('✅ Announcement marked as read: $announcementId by $userId');
      return true;
    } catch (e) {
      print('❌ Error marking announcement as read: $e');
      return false;
    }
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  Future<bool> deleteAnnouncement(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      print('✅ Announcement deleted: $id');
      return true;
    } catch (e) {
      print('❌ Error deleting announcement: $e');
      return false;
    }
  }

  // ============================================================================
  // SEARCH & FILTER
  // ============================================================================

  Future<List<AnnouncementModel>> searchAnnouncements({
    required String query,
    String? userRole,
    String? userId,
  }) async {
    try {
      final allAnnouncements = await getAnnouncements(
        userRole: userRole,
        userId: userId,
        activeOnly: true,
      );

      return allAnnouncements
          .where((announcement) =>
      announcement.title.toLowerCase().contains(query.toLowerCase()) ||
          announcement.message
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('❌ Error searching announcements: $e');
      return [];
    }
  }

  Future<List<AnnouncementModel>> getAnnouncementsByType({
    required String type,
    String? userRole,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      // Filter in memory
      return snapshot.docs
          .map((doc) => AnnouncementModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
          .where((a) => a.isActive)
          .where((a) =>
      userRole == null ||
          a.targetAudience.contains(userRole) ||
          a.targetAudience.contains('all'))
          .toList();
    } catch (e) {
      print('❌ Error fetching announcements by type: $e');
      return [];
    }
  }

  Future<List<AnnouncementModel>> getAnnouncementsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userRole,
    String? userId,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      // Filter in memory
      return snapshot.docs
          .map((doc) => AnnouncementModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
          .where((a) =>
      userRole == null ||
          a.targetAudience.contains(userRole) ||
          a.targetAudience.contains('all'))
          .toList();
    } catch (e) {
      print('❌ Error fetching announcements by date range: $e');
      return [];
    }
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final readBy = List<String>.from(data['readBy'] ?? []);
        if (!readBy.contains(userId)) {
          unreadCount++;
        }
      }

      return unreadCount;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  Future<List<AnnouncementModel>> getUnreadAnnouncements({
    required String userId,
    String? userRole,
  }) async {
    try {
      final allAnnouncements = await getAnnouncements(
        userRole: userRole,
        userId: userId,
        activeOnly: true,
      );

      return allAnnouncements
          .where((announcement) => !announcement.isReadBy(userId))
          .toList();
    } catch (e) {
      print('❌ Error fetching unread announcements: $e');
      return [];
    }
  }

  Future<bool> hasUnreadAnnouncements(String userId) async {
    try {
      final count = await getUnreadCount(userId);
      return count > 0;
    } catch (e) {
      print('❌ Error checking unread announcements: $e');
      return false;
    }
  }

  Future<List<AnnouncementModel>> getAcademicAnnouncements({
    String? userId,
    String? userRole,
  }) async {
    return await getAnnouncementsByType(
      type: 'academic',
      userRole: userRole,
    );
  }
}