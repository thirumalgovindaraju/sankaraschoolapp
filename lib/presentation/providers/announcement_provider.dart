// lib/presentation/providers/announcement_provider.dart
import 'package:flutter/material.dart';
import '../../data/models/announcement_model.dart';
import '../../data/repositories/announcement_repository.dart';

class AnnouncementProvider extends ChangeNotifier {
  final AnnouncementRepository _repository = AnnouncementRepository();

  // State
  List<AnnouncementModel> _announcements = [];
  List<AnnouncementModel> _urgentAnnouncements = [];
  List<AnnouncementModel> _recentAnnouncements = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _selectedType;
  bool _showOnlyUnread = false;

  // Getters
  List<AnnouncementModel> get announcements => _announcements;
  List<AnnouncementModel> get urgentAnnouncements => _urgentAnnouncements;
  List<AnnouncementModel> get recentAnnouncements => _recentAnnouncements;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedType => _selectedType;
  bool get showOnlyUnread => _showOnlyUnread;

  // Filtered announcements based on current filters
  List<AnnouncementModel> get filteredAnnouncements {
    var filtered = _announcements;

    if (_selectedType != null) {
      filtered = filtered.where((a) => a.type == _selectedType).toList();
    }

    if (_showOnlyUnread) {
      filtered = filtered.where((a) => !_isAnnouncementRead(a)).toList();
    }

    return filtered;
  }

  // Helper to check if announcement is read by checking readBy list
  bool _isAnnouncementRead(AnnouncementModel announcement) {
    // This will be checked against current user ID in actual implementation
    return announcement.readBy.isNotEmpty;
  }

  // Helper to convert List<String> attachments to List<Attachment>
  List<Attachment> _convertToAttachments(List<String>? attachmentUrls) {
    if (attachmentUrls == null || attachmentUrls.isEmpty) return [];

    return attachmentUrls.map((url) {
      return Attachment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: url.split('/').last,
        url: url,
      );
    }).toList();
  }

  // FETCH METHODS

  // Fetch all announcements
  Future<void> fetchAnnouncements({String? userRole, String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _announcements = await _repository.getAnnouncements(
        userRole: userRole,
        userId: userId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _announcements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch recent announcements (for dashboard)
  Future<void> fetchRecentAnnouncements({String? userRole, int limit = 5}) async {
    try {
      _recentAnnouncements = await _repository.getRecentAnnouncements(
        userRole: userRole,
        limit: limit,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Fetch urgent announcements
  Future<void> fetchUrgentAnnouncements({String? userRole}) async {
    try {
      _urgentAnnouncements = await _repository.getUrgentAnnouncements(
        userRole: userRole,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Fetch single announcement by ID
  Future<AnnouncementModel?> fetchAnnouncementById(String id) async {
    try {
      return await _repository.getAnnouncementById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Fetch unread count
  Future<void> fetchUnreadCount(String userId) async {
    try {
      _unreadCount = await _repository.getUnreadCount(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // CREATE/UPDATE/DELETE METHODS

  // Create announcement (admin/teacher only)
  Future<bool> createAnnouncement({
    required String title,
    required String message,
    required String type,
    required String priority,
    required List<String> targetAudience,
    List<String>? targetClasses,
    required String createdBy,
    required String createdByName,
    required String createdByRole,
    DateTime? expiryDate,
    List<String>? attachments,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final announcement = AnnouncementModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        type: type,
        priority: priority,
        targetAudience: targetAudience,
        targetClasses: targetClasses ?? [],
        createdBy: createdBy,
        createdByName: createdByName,
        createdByRole: createdByRole,
        createdAt: DateTime.now(),
        expiryDate: expiryDate,
        attachments: _convertToAttachments(attachments), // FIXED: Convert to Attachment objects
        readBy: [],
      );

      final success = await _repository.createAnnouncement(announcement);

      if (success) {
        // Refresh announcements list
        await fetchAnnouncements(userRole: createdByRole);
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

  // Update announcement
  Future<bool> updateAnnouncement({
    required String id,
    required String title,
    required String message,
    required String type,
    required String priority,
    required List<String> targetAudience,
    List<String>? targetClasses,
    DateTime? expiryDate,
    List<String>? attachments,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find existing announcement to preserve some fields
      final existingIndex = _announcements.indexWhere((a) => a.id == id);
      if (existingIndex == -1) {
        _error = 'Announcement not found';
        return false;
      }

      final existing = _announcements[existingIndex];
      final updatedAnnouncement = AnnouncementModel(
        id: id,
        title: title,
        message: message,
        type: type,
        priority: priority,
        targetAudience: targetAudience,
        targetClasses: targetClasses ?? [],
        createdBy: existing.createdBy,
        createdByName: existing.createdByName,
        createdByRole: existing.createdByRole,
        createdAt: existing.createdAt,
        expiryDate: expiryDate,
        attachments: _convertToAttachments(attachments), // FIXED: Convert to Attachment objects
        readBy: existing.readBy,
      );

      final success = await _repository.updateAnnouncement(
        id: id,
        announcement: updatedAnnouncement,
      );

      if (success) {
        // Update local list
        _announcements[existingIndex] = updatedAnnouncement;
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

  // Delete announcement
  Future<bool> deleteAnnouncement(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _repository.deleteAnnouncement(id);

      if (success) {
        _announcements.removeWhere((a) => a.id == id);
        _recentAnnouncements.removeWhere((a) => a.id == id);
        _urgentAnnouncements.removeWhere((a) => a.id == id);
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

  // Mark announcement as read
  Future<bool> markAsRead(String announcementId, String userId) async {
    try {
      final success = await _repository.markAsRead(
        announcementId: announcementId,
        userId: userId,
      );

      if (success) {
        // Update local lists
        _updateReadStatusInList(_announcements, announcementId, userId);
        _updateReadStatusInList(_recentAnnouncements, announcementId, userId);
        _updateReadStatusInList(_urgentAnnouncements, announcementId, userId);

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

  // Helper method to update read status in a list
  void _updateReadStatusInList(
      List<AnnouncementModel> list,
      String announcementId,
      String userId,
      ) {
    final index = list.indexWhere((a) => a.id == announcementId);
    if (index != -1) {
      final announcement = list[index];
      list[index] = AnnouncementModel(
        id: announcement.id,
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
        readBy: [...announcement.readBy, userId],
      );
    }
  }

  // SEARCH AND FILTER METHODS

  // Search announcements
  Future<void> searchAnnouncements(String query, {String? userRole}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _announcements = await _repository.searchAnnouncements(
        query: query,
        userRole: userRole,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _announcements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get announcements by type
  Future<void> fetchAnnouncementsByType(String type, {String? userRole}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _announcements = await _repository.getAnnouncementsByType(
        type: type,
        userRole: userRole,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _announcements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get announcements by date range
  Future<void> fetchAnnouncementsByDateRange(
      DateTime startDate,
      DateTime endDate, {
        String? userRole,
      }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _announcements = await _repository.getAnnouncementsByDateRange(
        startDate: startDate,
        endDate: endDate,
        userRole: userRole,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _announcements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set filter type
  void setFilterType(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  // Toggle show only unread
  void toggleShowOnlyUnread() {
    _showOnlyUnread = !_showOnlyUnread;
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _selectedType = null;
    _showOnlyUnread = false;
    notifyListeners();
  }

  // UTILITY METHODS

  // Check if there are unread announcements
  bool hasUnreadAnnouncements() {
    return _unreadCount > 0;
  }

  // Get announcements count by type
  int getCountByType(String type) {
    return _announcements.where((a) => a.type == type).length;
  }

  // Get active announcements (not expired)
  List<AnnouncementModel> getActiveAnnouncements() {
    final now = DateTime.now();
    return _announcements.where((a) {
      if (a.expiryDate == null) return true;
      return a.expiryDate!.isAfter(now);
    }).toList();
  }

  // Clear all data
  void clearData() {
    _announcements = [];
    _urgentAnnouncements = [];
    _recentAnnouncements = [];
    _unreadCount = 0;
    _error = null;
    _selectedType = null;
    _showOnlyUnread = false;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAll({String? userRole, String? userId}) async {
    await Future.wait([
      fetchAnnouncements(userRole: userRole, userId: userId),
      fetchRecentAnnouncements(userRole: userRole),
      fetchUrgentAnnouncements(userRole: userRole),
      if (userId != null) fetchUnreadCount(userId),
    ]);
  }
}