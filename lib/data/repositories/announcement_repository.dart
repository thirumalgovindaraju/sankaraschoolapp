// lib/data/repositories/announcement_repository.dart
// FIXED VERSION - Proper audience filtering

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';
import '../services/local_notification_service.dart';

class AnnouncementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'announcements';
  final LocalNotificationService _notificationService = LocalNotificationService();

  // ============================================================================
  // READ - FIXED: Proper audience matching
  // ============================================================================

  Future<List<AnnouncementModel>> getAnnouncements({
    String? userRole,
    String? userId,
    bool activeOnly = true,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('📥 Fetching announcements for role: $userRole (activeOnly: $activeOnly)');

      // ✅ ADMIN/PRINCIPAL: Always see ALL announcements
      if (userRole == 'admin' || userRole == 'principal') {
        Query query = _firestore
            .collection(_collection)
            .orderBy('created_at', descending: true)
            .limit(100); // Get more for admin

        final snapshot = await query.get();

        final announcements = snapshot.docs
            .map((doc) {
          try {
            return AnnouncementModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            });
          } catch (e) {
            print('⚠️ Error parsing announcement ${doc.id}: $e');
            return null;
          }
        })
            .where((announcement) => announcement != null)
            .map((announcement) => announcement!)
            .where((announcement) {
          // For admin, only filter by active status if requested
          if (activeOnly && !announcement.isActive) return false;
          return true;
        })
            .toList();

        print('✅ Admin fetched ${announcements.length} announcements');
        return announcements;
      }

      // ✅ NON-ADMIN: Fetch all and filter in memory (works with any Firestore schema)
      Query query = _firestore
          .collection(_collection)
          .orderBy('created_at', descending: true)
          .limit(100);

      final snapshot = await query.get();

      final announcements = snapshot.docs
          .map((doc) {
        try {
          return AnnouncementModel.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          });
        } catch (e) {
          print('⚠️ Error parsing announcement ${doc.id}: $e');
          return null;
        }
      })
          .where((announcement) => announcement != null)
          .map((announcement) => announcement!)
          .where((announcement) {
        // Filter by active status
        if (activeOnly && !announcement.isActive) return false;

        // Filter by target audience with FLEXIBLE MATCHING
        if (userRole != null) {
          final matchesAudience = _matchesTargetAudience(
            announcement.targetAudience,
            userRole,
          );
          if (!matchesAudience) return false;
        }

        return true;
      })
          .take(limit)
          .toList();

      print('✅ Fetched ${announcements.length} announcements for role: $userRole');
      return announcements;
    } catch (e) {
      print('❌ Error fetching announcements: $e');
      return [];
    }
  }

  // ✅ NEW: Flexible audience matching that handles both formats
  bool _matchesTargetAudience(List<String> targetAudience, String userRole) {
    if (targetAudience.isEmpty) return false;

    final roleLower = userRole.toLowerCase().trim();

    for (String audience in targetAudience) {
      final audienceLower = audience.toLowerCase().trim();

      // Match "all" or "All"
      if (audienceLower == 'all') return true;

      // Match "All Students", "All Parents", "All Teachers", "All Staff"
      if (audienceLower.contains('all')) {
        if (audienceLower.contains('student') && roleLower == 'student') return true;
        if (audienceLower.contains('parent') && roleLower == 'parent') return true;
        if (audienceLower.contains('teacher') && roleLower == 'teacher') return true;
        if (audienceLower.contains('staff') && roleLower == 'teacher') return true;
      }

      // Direct role match: "student", "parent", "teacher"
      if (audienceLower == roleLower) return true;

      // Class-specific targeting (e.g., "Class 1-5")
      if (audienceLower.startsWith('class')) return true;
    }

    return false;
  }

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
      print('📋 Target Audience: ${announcement.targetAudience}');

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

      final targetUserEmails = await _getTargetUserEmails(
        announcement.targetAudience,
        announcement.targetClasses,
      );

      if (targetUserEmails.isEmpty) {
        print('⚠️ No target users found for announcement');
        return;
      }

      print('📨 Sending notifications to ${targetUserEmails.length} users');

      final success = await _notificationService.createBulkNotifications(
        userIds: targetUserEmails,
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
        final audienceLower = audience.toLowerCase().trim();
        print('🔍 Processing audience: $audience (normalized: $audienceLower)');

        // Handle "All" or "all"
        if (audienceLower == 'all') {
          print('📋 Fetching ALL users (students, teachers, parents)...');
          userEmails.addAll(await _getAllStudentEmails());
          userEmails.addAll(await _getAllTeacherEmails());
          userEmails.addAll(await _getAllParentEmails());
          continue;
        }

        // Handle "All Students", "All Parents", "All Teachers", "All Staff"
        if (audienceLower.contains('all')) {
          if (audienceLower.contains('student')) {
            print('📋 Fetching all students...');
            userEmails.addAll(await _getAllStudentEmails(targetClasses: targetClasses));
          } else if (audienceLower.contains('parent')) {
            print('📋 Fetching all parents...');
            userEmails.addAll(await _getAllParentEmails(targetClasses: targetClasses));
          } else if (audienceLower.contains('teacher') || audienceLower.contains('staff')) {
            print('📋 Fetching all teachers...');
            userEmails.addAll(await _getAllTeacherEmails());
          }
          continue;
        }

        // Handle direct role names
        if (audienceLower == 'student' || audienceLower.contains('student')) {
          print('📋 Fetching students...');
          userEmails.addAll(await _getAllStudentEmails(targetClasses: targetClasses));
        } else if (audienceLower == 'teacher' || audienceLower.contains('teacher') ||
            audienceLower == 'staff' || audienceLower.contains('staff')) {
          print('📋 Fetching teachers...');
          userEmails.addAll(await _getAllTeacherEmails());
        } else if (audienceLower == 'parent' || audienceLower.contains('parent')) {
          print('📋 Fetching parents...');
          userEmails.addAll(await _getAllParentEmails(targetClasses: targetClasses));
        } else if (audienceLower.startsWith('class')) {
          // Handle class-specific targeting
          print('📋 Fetching users for class: $audience');
          final className = audience.replaceAll('Class ', '').trim();
          userEmails.addAll(await _getAllStudentEmails(targetClasses: [className]));
          userEmails.addAll(await _getAllParentEmails(targetClasses: [className]));
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

  Future<List<String>> _getAllStudentEmails({List<String>? targetClasses}) async {
    try {
      Query query = _firestore.collection('students');

      if (targetClasses != null && targetClasses.isNotEmpty) {
        query = query.where('class', whereIn: targetClasses);
      }

      final snapshot = await query.get();
      final emails = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['email'] as String?)
          .where((email) => email != null && email.isNotEmpty && email != 'null')
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
          .map((doc) => (doc.data() as Map<String, dynamic>)['email'] as String?)
          .where((email) => email != null && email.isNotEmpty && email != 'null')
          .cast<String>()
          .toList();

      print('✅ Found ${emails.length} teacher emails');
      return emails;
    } catch (e) {
      print('❌ Error fetching teacher emails: $e');
      return [];
    }
  }

  Future<List<String>> _getAllParentEmails({List<String>? targetClasses}) async {
    try {
      Set<String> parentEmails = {};
      Query query = _firestore.collection('students');

      if (targetClasses != null && targetClasses.isNotEmpty) {
        query = query.where('class', whereIn: targetClasses);
      }

      final snapshot = await query.get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final parentDetails = data['parent_details'] as Map<String, dynamic>?;

        if (parentDetails != null) {
          final fatherEmail = parentDetails['father_email'] as String?;
          if (fatherEmail != null && fatherEmail.isNotEmpty && fatherEmail != 'null') {
            parentEmails.add(fatherEmail);
          }

          final motherEmail = parentDetails['mother_email'] as String?;
          if (motherEmail != null && motherEmail.isNotEmpty && motherEmail != 'null') {
            parentEmails.add(motherEmail);
          }
        }

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
  // OTHER METHODS (unchanged from original)
  // ============================================================================

  Future<AnnouncementModel?> getAnnouncementById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;

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
      limit: limit,
    );
  }

  Future<List<AnnouncementModel>> getUrgentAnnouncements({
    String? userRole,
    String? userId,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('priority', isEqualTo: 'high')
          .orderBy('created_at', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => AnnouncementModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
          .where((a) => a.isActive)
          .where((a) =>
      userRole == null ||
          userRole == 'admin' ||
          _matchesTargetAudience(a.targetAudience, userRole))
          .toList();
    } catch (e) {
      print('❌ Error fetching urgent announcements: $e');
      return [];
    }
  }

  Future<bool> updateAnnouncement({
    required String id,
    required AnnouncementModel announcement,
  }) async {
    try {
      await _firestore.collection(_collection).doc(id).update(announcement.toJson());
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
        'read_by': FieldValue.arrayUnion([userId]),
      });
      print('✅ Announcement marked as read: $announcementId by $userId');
      return true;
    } catch (e) {
      print('❌ Error marking announcement as read: $e');
      return false;
    }
  }

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
          announcement.message.toLowerCase().contains(query.toLowerCase()))
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
          .orderBy('created_at', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => AnnouncementModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
          .where((a) => a.isActive)
          .where((a) =>
      userRole == null ||
          userRole == 'admin' ||
          _matchesTargetAudience(a.targetAudience, userRole))
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
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('created_at', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => AnnouncementModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
          .where((a) =>
      userRole == null ||
          userRole == 'admin' ||
          _matchesTargetAudience(a.targetAudience, userRole))
          .toList();
    } catch (e) {
      print('❌ Error fetching announcements by date range: $e');
      return [];
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot =
      await _firestore.collection(_collection).where('is_active', isEqualTo: true).get();

      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final readBy = List<String>.from(data['read_by'] ?? []);
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

      return allAnnouncements.where((announcement) => !announcement.isReadBy(userId)).toList();
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