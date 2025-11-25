// lib/presentation/providers/announcement_provider.dart
// FIXED VERSION - Proper refresh logic

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

  bool _isAnnouncementRead(AnnouncementModel announcement) {
    return announcement.readBy.isNotEmpty;
  }

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

  // ============================================================================
  // FETCH METHODS - FIXED
  // ============================================================================

  /// Fetch all announcements with proper error handling
  Future<void> fetchAnnouncements({
    required String userRole,
    String? userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📥 [PROVIDER] Fetching announcements for role: $userRole');

      final announcements = await _repository.getAnnouncements(
        userRole: userRole,
        userId: userId,
        activeOnly: true,
        limit: 50,
      );

      _announcements = announcements;
      print('✅ [PROVIDER] Fetched ${_announcements.length} announcements');

      // Log sample for debugging
      if (_announcements.isNotEmpty) {
        print('📋 Sample announcement:');
        print('   - Title: ${_announcements.first.title}');
        print('   - Target: ${_announcements.first.targetAudience}');
      }

      _error = null;
    } catch (e) {
      print('❌ [PROVIDER] Error fetching announcements: $e');
      _error = e.toString();
      _announcements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch recent announcements (for dashboard)
  Future<void> fetchRecentAnnouncements({
    String? userRole,
    int limit = 5,
  }) async {
    try {
      print('📥 [PROVIDER] Fetching recent announcements for role: $userRole');

      _recentAnnouncements = await _repository.getRecentAnnouncements(
        userRole: userRole,
        limit: limit,
      );

      print('✅ [PROVIDER] Fetched ${_recentAnnouncements.length} recent announcements');
      notifyListeners();
    } catch (e) {
      print('❌ [PROVIDER] Error fetching recent announcements: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Fetch urgent announcements
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

  /// Fetch single announcement by ID
  Future<AnnouncementModel?> fetchAnnouncementById(String id) async {
    try {
      return await _repository.getAnnouncementById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Fetch unread count
  Future<void> fetchUnreadCount(String userId) async {
    try {
      _unreadCount = await _repository.getUnreadCount(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ============================================================================
  // CREATE/UPDATE/DELETE METHODS - FIXED
  // ============================================================================

  /// Create announcement with automatic refresh
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
    bool sendNotifications = true,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📤 [PROVIDER] Creating announcement...');
      print('   Title: $title');
      print('   Target Audience: $targetAudience');

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
        attachments: _convertToAttachments(attachments),
        readBy: [],
      );

      final success = await _repository.createAnnouncement(
        announcement,
        sendNotifications: sendNotifications,
      );

      if (success) {
        print('✅ [PROVIDER] Announcement created successfully');

        // ✅ IMPORTANT: Refresh announcements immediately after creation
        await fetchAnnouncements(
          userRole: createdByRole,
          userId: createdBy,
        );
      }

      return success;
    } catch (e) {
      print('❌ [PROVIDER] Error in createAnnouncement: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update announcement
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
        attachments: _convertToAttachments(attachments),
        readBy: existing.readBy,
      );

      final success = await _repository.updateAnnouncement(
        id: id,
        announcement: updatedAnnouncement,
      );

      if (success) {
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

  /// Delete announcement
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

  /// Mark announcement as read
  Future<bool> markAsRead(String announcementId, String userId) async {
    try {
      final success = await _repository.markAsRead(
        announcementId: announcementId,
        userId: userId,
      );

      if (success) {
        _updateReadStatusInList(_announcements, announcementId, userId);
        _updateReadStatusInList(_recentAnnouncements, announcementId, userId);
        _updateReadStatusInList(_urgentAnnouncements, announcementId, userId);

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

  // ============================================================================
  // SEARCH AND FILTER METHODS
  // ============================================================================

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

  void setFilterType(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  void toggleShowOnlyUnread() {
    _showOnlyUnread = !_showOnlyUnread;
    notifyListeners();
  }

  void clearFilters() {
    _selectedType = null;
    _showOnlyUnread = false;
    notifyListeners();
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  bool hasUnreadAnnouncements() {
    return _unreadCount > 0;
  }

  int getCountByType(String type) {
    return _announcements.where((a) => a.type == type).length;
  }

  List<AnnouncementModel> getActiveAnnouncements() {
    final now = DateTime.now();
    return _announcements.where((a) {
      if (a.expiryDate == null) return true;
      return a.expiryDate!.isAfter(now);
    }).toList();
  }

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

  /// Refresh all data
  Future<void> refreshAll({String? userRole, String? userId}) async {
    final role = userRole ?? 'student';

    await Future.wait([
      fetchAnnouncements(userRole: role, userId: userId),
      fetchRecentAnnouncements(userRole: role),
      fetchUrgentAnnouncements(userRole: role),
      if (userId != null) fetchUnreadCount(userId),
    ]);
  }
}