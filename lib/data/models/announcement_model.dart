// lib/data/models/announcement_model.dart

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'academic', 'general', 'urgent', 'event', 'holiday'
  final String priority; // 'high', 'medium', 'low'
  final String createdBy; // User ID who created
  final String createdByName; // Name of creator
  final String createdByRole; // 'admin', 'teacher'
  final List<String> targetAudience; // ['student', 'parent', 'teacher', 'all']
  final List<String> targetClasses; // Specific classes if applicable
  final List<String>? targetStudents; // Specific students if applicable
  final DateTime createdAt;
  final DateTime? updatedAt; // Added for update tracking
  final DateTime? expiryDate;
  final bool isActive;
  final bool isPinned; // Added for pinned announcements
  final String? attachmentUrl;
  final String? attachmentName;
  final List<Attachment> attachments; // Changed to List<Attachment> for better structure
  final Map<String, dynamic>? metadata; // Additional data
  final int readCount;
  final List<String> readBy; // User IDs who have read

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

  // Getters for backward compatibility with AnnouncementDetailScreen
  String get content => message; // Maps message to content
  String get category => type; // Maps type to category
  String get createdById => createdBy; // createdBy is already the user ID

  // From JSON
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      priority: json['priority'] ?? 'medium',
      createdBy: json['created_by'] ?? '',
      createdByName: json['created_by_name'] ?? '',
      createdByRole: json['created_by_role'] ?? '',
      targetAudience: List<String>.from(json['target_audience'] ?? ['all']),
      targetClasses: json['target_classes'] != null
          ? List<String>.from(json['target_classes'])
          : [],
      targetStudents: json['target_students'] != null
          ? List<String>.from(json['target_students'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      isActive: json['is_active'] ?? true,
      isPinned: json['is_pinned'] ?? false,
      attachmentUrl: json['attachment_url'],
      attachmentName: json['attachment_name'],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
          .map((a) => a is String
          ? Attachment(
        id: a,
        name: json['attachment_name'] ?? 'Attachment',
        url: a,
      )
          : Attachment.fromJson(a))
          .toList()
          : [],
      metadata: json['metadata'],
      readCount: json['read_count'] ?? 0,
      readBy: List<String>.from(json['read_by'] ?? []),
    );
  }

  // To JSON
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

  // Copy with
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

  // Check if announcement is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  // Check if user has read the announcement
  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }

  // Get priority color
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

  // Get type icon
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

// Attachment model
class Attachment {
  final String id;
  final String name;
  final String url;
  final int? size; // in bytes
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