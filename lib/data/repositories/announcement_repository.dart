// lib/data/repositories/announcement_repository.dart (FIXED VERSION)

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';

class AnnouncementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'announcements';

  // ============================================================================
  // CREATE
  // ============================================================================

  Future<bool> createAnnouncement(AnnouncementModel announcement) async {
    try {
      // Generate a unique ID if not provided
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
      );

      await _firestore
          .collection(_collection)
          .doc(docId)
          .set(announcementWithId.toJson());

      print('✅ Announcement created in Firestore: $docId');
      return true;
    } catch (e) {
      print('❌ Error creating announcement: $e');
      return false;
    }
  }

  // ============================================================================
  // READ
  // ============================================================================

  Future<List<AnnouncementModel>> getAnnouncements({
    String? userRole,
    String? userId,
    bool activeOnly = true,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      // Filter by active status
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      // Filter by target audience (role)
      if (userRole != null) {
        query = query.where('targetAudience', arrayContains: userRole);
      }

      // Order by creation date (newest first)
      query = query.orderBy('createdAt', descending: true);

      // Apply pagination
      query = query.limit(limit);
      if (page > 1) {
        query = query.startAfter([(page - 1) * limit]);
      }

      final snapshot = await query.get();

      final announcements = snapshot.docs
          .map((doc) => AnnouncementModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
          .toList();

      print('✅ Fetched ${announcements.length} announcements from Firestore');
      return announcements;
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
      Query query = _firestore.collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('priority', isEqualTo: 'high');

      if (userRole != null) {
        query = query.where('targetAudience', arrayContains: userRole);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => AnnouncementModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
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
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation - consider using Algolia for production
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
      Query query = _firestore.collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('type', isEqualTo: type);

      if (userRole != null) {
        query = query.where('targetAudience', arrayContains: userRole);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => AnnouncementModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
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
      Query query = _firestore.collection(_collection)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (userRole != null) {
        query = query.where('targetAudience', arrayContains: userRole);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => AnnouncementModel.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }))
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

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

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