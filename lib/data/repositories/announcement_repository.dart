// lib/data/repositories/announcement_repository.dart

import '../models/announcement_model.dart';
import '../services/announcement_service.dart';

class AnnouncementRepository {
  final AnnouncementService _announcementService;

  AnnouncementRepository({AnnouncementService? announcementService})
      : _announcementService = announcementService ?? AnnouncementService();

  // Create announcement - returns bool
  Future<bool> createAnnouncement(AnnouncementModel announcement) async {
    try {
      final result = await _announcementService.createAnnouncement(
        title: announcement.title,
        message: announcement.message,
        type: announcement.type,
        priority: announcement.priority,
        targetAudience: announcement.targetAudience,
        targetClasses: announcement.targetClasses.isNotEmpty ? announcement.targetClasses : null,
        targetStudents: announcement.targetStudents,
        expiryDate: announcement.expiryDate,
        attachmentUrl: announcement.attachmentUrl,
        attachmentName: announcement.attachmentName,
      );
      return result['success'] == true;
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return false;
    }
  }

  // Get announcements with filtering
  Future<List<AnnouncementModel>> getAnnouncements({
    String? userRole,
    String? userId,
    bool activeOnly = true,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await _announcementService.getAnnouncements(
        userRole: userRole,
        userId: userId,
        activeOnly: activeOnly,
        page: page,
        limit: limit,
      );

      if (result['success'] == true && result['announcements'] != null) {
        return result['announcements'] as List<AnnouncementModel>;
      }
      return [];
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Get announcement by ID
  Future<AnnouncementModel?> getAnnouncementById(String id) async {
    try {
      final result = await _announcementService.getAnnouncementById(id);

      if (result['success'] == true && result['announcement'] != null) {
        return result['announcement'] as AnnouncementModel;
      }
      return null;
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return null;
    }
  }

  // Get announcements by type
  Future<List<AnnouncementModel>> getAnnouncementsByType({
    required String type,
    String? userRole,
  }) async {
    try {
      final result = await _announcementService.getAnnouncementsByType(type);

      if (result['success'] == true && result['announcements'] != null) {
        return result['announcements'] as List<AnnouncementModel>;
      }
      return [];
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Mark announcement as read
  Future<bool> markAsRead({
    required String announcementId,
    required String userId,
  }) async {
    try {
      final result = await _announcementService.markAsRead(announcementId, userId);
      return result['success'] == true;
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return false;
    }
  }

  // Update announcement - returns bool
  Future<bool> updateAnnouncement({
    required String id,
    required AnnouncementModel announcement,
  }) async {
    try {
      final result = await _announcementService.updateAnnouncement(
        id: id,
        title: announcement.title,
        message: announcement.message,
        type: announcement.type,
        priority: announcement.priority,
        targetAudience: announcement.targetAudience,
        targetClasses: announcement.targetClasses.isNotEmpty ? announcement.targetClasses : null,
        expiryDate: announcement.expiryDate,
        isActive: announcement.isActive,
      );
      return result['success'] == true;
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return false;
    }
  }

  // Delete announcement - returns bool
  Future<bool> deleteAnnouncement(String id) async {
    try {
      final result = await _announcementService.deleteAnnouncement(id);
      return result['success'] == true;
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return false;
    }
  }

  // Get unread announcements count
  Future<int> getUnreadCount(String userId) async {
    try {
      final result = await _announcementService.getUnreadCount(userId);
      if (result['success'] == true) {
        return result['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return 0;
    }
  }

  // Get recent announcements (for dashboard)
  Future<List<AnnouncementModel>> getRecentAnnouncements({
    String? userRole,
    String? userId,
    int limit = 5,
  }) async {
    try {
      return await getAnnouncements(
        userRole: userRole,
        userId: userId,
        activeOnly: true,
        page: 1,
        limit: limit,
      );
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Get urgent announcements
  Future<List<AnnouncementModel>> getUrgentAnnouncements({
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
      announcement.priority == 'high' ||
          announcement.type == 'urgent')
          .toList();
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Get academic announcements
  Future<List<AnnouncementModel>> getAcademicAnnouncements({
    String? userId,
    String? userRole,
  }) async {
    try {
      return await getAnnouncementsByType(
        type: 'academic',
        userRole: userRole,
      );
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Search announcements
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
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Get announcements by date range
  Future<List<AnnouncementModel>> getAnnouncementsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userRole,
    String? userId,
  }) async {
    try {
      final allAnnouncements = await getAnnouncements(
        userRole: userRole,
        userId: userId,
        activeOnly: false,
      );

      return allAnnouncements
          .where((announcement) =>
      announcement.createdAt.isAfter(startDate) &&
          announcement.createdAt.isBefore(endDate))
          .toList();
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Get unread announcements
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
      print('Repository Error: ${e.toString()}');
      return [];
    }
  }

  // Check if user has unread announcements
  Future<bool> hasUnreadAnnouncements(String userId) async {
    try {
      final count = await getUnreadCount(userId);
      return count > 0;
    } catch (e) {
      print('Repository Error: ${e.toString()}');
      return false;
    }
  }
}