// lib/data/models/announcement_model.dart
// FIXED VERSION - All type errors resolved

import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String priority;
  final String createdBy;
  final String createdByName;
  final String createdByRole;
  final List<String> targetAudience;
  final List<String> targetClasses;
  final List<String>? targetStudents;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? expiryDate;
  final bool isActive;
  final bool isPinned;
  final String? attachmentUrl;
  final String? attachmentName;
  final List<Attachment> attachments;
  final Map<String, dynamic>? metadata;
  final int readCount;
  final List<String> readBy;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.createdBy,
    required this.createdByName,
    required this.createdByRole,
    required this.targetAudience,
    this.targetClasses = const [],
    this.targetStudents,
    required this.createdAt,
    this.updatedAt,
    this.expiryDate,
    this.isActive = true,
    this.isPinned = false,
    this.attachmentUrl,
    this.attachmentName,
    this.attachments = const [],
    this.metadata,
    this.readCount = 0,
    this.readBy = const [],
  });

  // Getters for backward compatibility
  String get content => message;
  String get category => type;
  String get createdById => createdBy;

  // ============================================================================
  // FROM JSON - FIXED: All type errors resolved
  // ============================================================================

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      priority: json['priority'] ?? 'medium',

      createdBy: json['createdBy'] ?? json['created_by'] ?? '',
      createdByName: json['createdByName'] ?? json['created_by_name'] ?? '',
      createdByRole: json['createdByRole'] ?? json['created_by_role'] ?? '',

      // ✅ FIXED: Returns non-nullable List<String>
      targetAudience: _parseStringList(
        json['targetAudience'] ?? json['target_audience'],
        defaultValue: ['all'],
      ) ?? ['all'], // Double safety

      // ✅ FIXED: Returns non-nullable List<String>
      targetClasses: _parseStringList(
        json['targetClasses'] ?? json['target_classes'],
        defaultValue: [],
      ) ?? [], // Double safety

      // ✅ This one is nullable, so it's fine
      targetStudents: _parseStringList(
        json['targetStudents'] ?? json['target_students'],
        defaultValue: null,
      ),

      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
      expiryDate: _parseDateTime(json['expiryDate'] ?? json['expiry_date']),

      isActive: json['isActive'] ?? json['is_active'] ?? true,
      isPinned: json['isPinned'] ?? json['is_pinned'] ?? false,

      attachmentUrl: json['attachmentUrl'] ?? json['attachment_url'],
      attachmentName: json['attachmentName'] ?? json['attachment_name'],

      attachments: _parseAttachments(
        json['attachments'],
        fallbackName: json['attachmentName'] ?? json['attachment_name'],
      ),

      metadata: json['metadata'],
      readCount: json['readCount'] ?? json['read_count'] ?? 0,

      // ✅ FIXED: Returns non-nullable List<String>
      readBy: _parseStringList(
        json['readBy'] ?? json['read_by'],
        defaultValue: [],
      ) ?? [], // Double safety
    );
  }

  // ============================================================================
  // HELPER METHODS - FIXED: Better null handling
  // ============================================================================

  /// Parse field that can be String, List, or null
  /// Returns List<String>? to allow null for optional fields
  static List<String>? _parseStringList(dynamic value, {required List<String>? defaultValue}) {
    if (value == null) return defaultValue;

    // If it's already a List
    if (value is List) {
      try {
        return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      } catch (e) {
        print('⚠️ Error parsing list: $e');
        return defaultValue;
      }
    }

    // If it's a String, convert to single-item list
    if (value is String) {
      if (value.isEmpty) return defaultValue;
      // Check if it's a comma-separated string
      if (value.contains(',')) {
        return value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
      return [value];
    }

    return defaultValue;
  }

  /// Parse DateTime from various formats
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    // Firestore Timestamp
    if (value is Timestamp) {
      return value.toDate();
    }

    // ISO String
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }

    // Milliseconds since epoch
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  /// Parse attachments safely
  static List<Attachment> _parseAttachments(dynamic value, {String? fallbackName}) {
    if (value == null) return [];
    if (value is! List) return [];

    try {
      return value.map((item) {
        if (item is String) {
          return Attachment(
            id: item,
            name: fallbackName ?? 'Attachment',
            url: item,
          );
        }

        if (item is Map<String, dynamic>) {
          return Attachment.fromJson(item);
        }

        return Attachment(
          id: item.toString(),
          name: fallbackName ?? 'Attachment',
          url: item.toString(),
        );
      }).toList();
    } catch (e) {
      print('⚠️ Error parsing attachments: $e');
      return [];
    }
  }

  // ============================================================================
  // TO JSON
  // ============================================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_by_role': createdByRole,
      'target_audience': targetAudience,
      'target_classes': targetClasses,
      'target_students': targetStudents,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'is_active': isActive,
      'is_pinned': isPinned,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'metadata': metadata,
      'read_count': readCount,
      'read_by': readBy,
    };
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? priority,
    String? createdBy,
    String? createdByName,
    String? createdByRole,
    List<String>? targetAudience,
    List<String>? targetClasses,
    List<String>? targetStudents,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiryDate,
    bool? isActive,
    bool? isPinned,
    String? attachmentUrl,
    String? attachmentName,
    List<Attachment>? attachments,
    Map<String, dynamic>? metadata,
    int? readCount,
    List<String>? readBy,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdByRole: createdByRole ?? this.createdByRole,
      targetAudience: targetAudience ?? this.targetAudience,
      targetClasses: targetClasses ?? this.targetClasses,
      targetStudents: targetStudents ?? this.targetStudents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      isPinned: isPinned ?? this.isPinned,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      readCount: readCount ?? this.readCount,
      readBy: readBy ?? this.readBy,
    );
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }

  String get priorityColor {
    switch (priority) {
      case 'high':
        return '#F44336';
      case 'medium':
        return '#FF9800';
      case 'low':
        return '#4CAF50';
      default:
        return '#2196F3';
    }
  }

  String get typeIcon {
    switch (type) {
      case 'academic':
        return '📚';
      case 'urgent':
        return '🚨';
      case 'event':
        return '📅';
      case 'holiday':
        return '🏖️';
      default:
        return '📢';
    }
  }
}

// ============================================================================
// ATTACHMENT MODEL
// ============================================================================

class Attachment {
  final String id;
  final String name;
  final String url;
  final int? size;
  final String? type;

  Attachment({
    required this.id,
    required this.name,
    required this.url,
    this.size,
    this.type,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      url: json['url'] ?? '',
      size: json['size'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'size': size,
      'type': type,
    };
  }
}