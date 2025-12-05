// lib/data/models/user_model.dart
// ✅ UPDATED: Added approval status fields

enum UserRole {
  parent,
  student,
  teacher,
  admin,
}

// ✅ NEW: Approval status enum
enum ApprovalStatus {
  pending,
  approved,
  rejected,
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? profileImage;
  final UserRole role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final Map<String, dynamic>? metadata;

  // ✅ NEW: Approval fields (Lines 28-30)
  final ApprovalStatus approvalStatus;
  final DateTime? approvalDate;
  final String? approvedBy;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.profileImage,
    required this.role,
    this.isActive = true,
    this.createdAt,
    this.lastLogin,
    this.metadata,
    // ✅ NEW: Default to pending for new registrations (Lines 45-47)
    this.approvalStatus = ApprovalStatus.pending,
    this.approvalDate,
    this.approvedBy,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      profileImage: json['profile_image'],
      role: _parseRole(json['role']),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      metadata: json['metadata'],
      // ✅ NEW: Parse approval fields (Lines 69-75)
      approvalStatus: _parseApprovalStatus(json['approval_status']),
      approvalDate: json['approval_date'] != null
          ? DateTime.parse(json['approval_date'])
          : null,
      approvedBy: json['approved_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'profile_image': profileImage,
      'role': role.name,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'metadata': metadata,
      // ✅ NEW: Include approval fields in JSON (Lines 94-96)
      'approval_status': approvalStatus.name,
      'approval_date': approvalDate?.toIso8601String(),
      'approved_by': approvedBy,
    };
  }

  static UserRole _parseRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'parent':
        return UserRole.parent;
      case 'student':
        return UserRole.student;
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.parent;
    }
  }

  // ✅ NEW: Parse approval status (Lines 115-124)
  static ApprovalStatus _parseApprovalStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      case 'pending':
      default:
        return ApprovalStatus.pending;
    }
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? profileImage,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
    Map<String, dynamic>? metadata,
    // ✅ NEW: Add approval fields to copyWith (Lines 141-143)
    ApprovalStatus? approvalStatus,
    DateTime? approvalDate,
    String? approvedBy,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      metadata: metadata ?? this.metadata,
      // ✅ NEW: Include in copyWith return (Lines 158-160)
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvalDate: approvalDate ?? this.approvalDate,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }

  // ✅ NEW: Helper methods (Lines 165-174)
  bool get isPending => approvalStatus == ApprovalStatus.pending;
  bool get isApproved => approvalStatus == ApprovalStatus.approved;
  bool get isRejected => approvalStatus == ApprovalStatus.rejected;

  bool get canLogin => isApproved && isActive;

  String get approvalStatusText {
    return approvalStatus.name.substring(0, 1).toUpperCase() +
        approvalStatus.name.substring(1);
  }
}