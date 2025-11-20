// lib/domain/models/dashboard_stats.dart

class DashboardStats {
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final double averageAttendance;
  final double totalFeesCollected;
  final double totalFeesPending;
  final double feeCollectionRate;
  final List<AttendanceData> weeklyAttendance;

  DashboardStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
    required this.averageAttendance,
    required this.totalFeesCollected,
    required this.totalFeesPending,
    required this.feeCollectionRate,
    required this.weeklyAttendance,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalStudents: json['totalStudents'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      averageAttendance: (json['averageAttendance'] ?? 0.0).toDouble(),
      totalFeesCollected: (json['totalFeesCollected'] ?? 0.0).toDouble(),
      totalFeesPending: (json['totalFeesPending'] ?? 0.0).toDouble(),
      feeCollectionRate: (json['feeCollectionRate'] ?? 0.0).toDouble(),
      weeklyAttendance: (json['weeklyAttendance'] as List<dynamic>?)
          ?.map((e) => AttendanceData.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'totalClasses': totalClasses,
      'averageAttendance': averageAttendance,
      'totalFeesCollected': totalFeesCollected,
      'totalFeesPending': totalFeesPending,
      'feeCollectionRate': feeCollectionRate,
      'weeklyAttendance': weeklyAttendance.map((e) => e.toJson()).toList(),
    };
  }
}

class AttendanceData {
  final String day;
  final double percentage;

  AttendanceData({
    required this.day,
    required this.percentage,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      day: json['day'] ?? '',
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'percentage': percentage,
    };
  }
}