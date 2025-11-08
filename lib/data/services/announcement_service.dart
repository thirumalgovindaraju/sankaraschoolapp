// lib/data/services/announcement_service.dart

import 'dart:convert';
import '../models/announcement_model.dart';
import 'api_service.dart';

class AnnouncementService {
  final ApiService _apiService;

  AnnouncementService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Create announcement (Admin/Teacher)
  Future<Map<String, dynamic>> createAnnouncement({
    required String title,
    required String message,
    required String type,
    required String priority,
    required List<String> targetAudience,
    List<String>? targetClasses,
    List<String>? targetStudents,
    DateTime? expiryDate,
    String? attachmentUrl,
    String? attachmentName,
  }) async {
    try {
      final response = await _apiService.post(
        '/announcements',
        {
          'title': title,
          'message': message,
          'type': type,
          'priority': priority,
          'target_audience': targetAudience,
          'target_classes': targetClasses,
          'target_students': targetStudents,
          'expiry_date': expiryDate?.toIso8601String(),
          'attachment_url': attachmentUrl,
          'attachment_name': attachmentName,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Announcement created successfully',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create announcement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get announcements for user
  Future<Map<String, dynamic>> getAnnouncements({
    String? userRole,
    String? userId,
    bool activeOnly = true,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        if (userRole != null) 'user_role': userRole,
        if (userId != null) 'user_id': userId,
        'active_only': activeOnly.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiService.get(
        '/announcements',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final announcements = (data['announcements'] as List)
            .map((json) => AnnouncementModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'announcements': announcements,
          'total': data['total'] ?? announcements.length,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch announcements',
          'announcements': <AnnouncementModel>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'announcements': <AnnouncementModel>[],
      };
    }
  }

  // Get announcement by ID
  Future<Map<String, dynamic>> getAnnouncementById(String id) async {
    try {
      final response = await _apiService.get('/announcements/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final announcement = AnnouncementModel.fromJson(data);

        return {
          'success': true,
          'announcement': announcement,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch announcement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Mark announcement as read
  Future<Map<String, dynamic>> markAsRead(String announcementId, String userId) async {
    try {
      final response = await _apiService.post(
        '/announcements/$announcementId/read',
        {'user_id': userId},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Marked as read',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to mark as read',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Update announcement
  Future<Map<String, dynamic>> updateAnnouncement({
    required String id,
    String? title,
    String? message,
    String? type,
    String? priority,
    List<String>? targetAudience,
    List<String>? targetClasses,
    DateTime? expiryDate,
    bool? isActive,
  }) async {
    try {
      final response = await _apiService.put(
        '/announcements/$id',
        {
          if (title != null) 'title': title,
          if (message != null) 'message': message,
          if (type != null) 'type': type,
          if (priority != null) 'priority': priority,
          if (targetAudience != null) 'target_audience': targetAudience,
          if (targetClasses != null) 'target_classes': targetClasses,
          if (expiryDate != null) 'expiry_date': expiryDate.toIso8601String(),
          if (isActive != null) 'is_active': isActive,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Announcement updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update announcement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Delete announcement
  Future<Map<String, dynamic>> deleteAnnouncement(String id) async {
    try {
      final response = await _apiService.delete('/announcements/$id');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Announcement deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete announcement',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get announcements by type
  Future<Map<String, dynamic>> getAnnouncementsByType(String type) async {
    try {
      final response = await _apiService.get('/announcements/type/$type');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final announcements = (data['announcements'] as List)
            .map((json) => AnnouncementModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'announcements': announcements,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch announcements',
          'announcements': <AnnouncementModel>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'announcements': <AnnouncementModel>[],
      };
    }
  }

  // Get unread announcements count
  Future<Map<String, dynamic>> getUnreadCount(String userId) async {
    try {
      final response = await _apiService.get(
        '/announcements/unread/count',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'count': data['count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'count': 0,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'count': 0,
      };
    }
  }
}