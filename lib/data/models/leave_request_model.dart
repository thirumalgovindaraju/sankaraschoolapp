
// lib/data/models/leave_request_model.dart

class LeaveRequestModel {
  final String id;
  final String studentId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status; // pending, approved, rejected
  final String? approvedBy;
  final DateTime? approvedDate;
  final String? rejectionReason;

  LeaveRequestModel({
    required this.id,
    required this.studentId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.approvedBy,
    this.approvedDate,
    this.rejectionReason,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      approvedBy: json['approved_by'],
      approvedDate: json['approved_date'] != null
          ? DateTime.parse(json['approved_date'])
          : null,
      rejectionReason: json['rejection_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'reason': reason,
      'status': status,
      'approved_by': approvedBy,
      'approved_date': approvedDate?.toIso8601String(),
      'rejection_reason': rejectionReason,
    };
  }
}