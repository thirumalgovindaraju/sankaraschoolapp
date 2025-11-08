class DashboardStats {
  final int totalStudents;
  final int totalTeachers;
  final int totalParents;
  final int totalClasses;
  final double averageAttendance;
  final double todayAttendance;
  final int presentToday;
  final int absentToday;
  final double feeCollectionRate;
  final double totalFeesCollected;
  final double totalFeesPending;
  final int upcomingEvents;
  final int pendingAdmissions;
  final StudentGenderDistribution genderDistribution;
  final List<ClassStrength> classWiseStrength;
  final List<AttendanceTrend> weeklyAttendance;
  final List<FeeCollectionTrend> monthlyFeeCollection;

  DashboardStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalParents,
    required this.totalClasses,
    required this.averageAttendance,
    required this.todayAttendance,
    required this.presentToday,
    required this.absentToday,
    required this.feeCollectionRate,
    required this.totalFeesCollected,
    required this.totalFeesPending,
    required this.upcomingEvents,
    required this.pendingAdmissions,
    required this.genderDistribution,
    required this.classWiseStrength,
    required this.weeklyAttendance,
    required this.monthlyFeeCollection,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalStudents: json['totalStudents'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      totalParents: json['totalParents'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      averageAttendance: (json['averageAttendance'] ?? 0).toDouble(),
      todayAttendance: (json['todayAttendance'] ?? 0).toDouble(),
      presentToday: json['presentToday'] ?? 0,
      absentToday: json['absentToday'] ?? 0,
      feeCollectionRate: (json['feeCollectionRate'] ?? 0).toDouble(),
      totalFeesCollected: (json['totalFeesCollected'] ?? 0).toDouble(),
      totalFeesPending: (json['totalFeesPending'] ?? 0).toDouble(),
      upcomingEvents: json['upcomingEvents'] ?? 0,
      pendingAdmissions: json['pendingAdmissions'] ?? 0,
      genderDistribution: StudentGenderDistribution.fromJson(
        json['genderDistribution'] ?? {},
      ),
      classWiseStrength: (json['classWiseStrength'] as List<dynamic>?)
          ?.map((e) => ClassStrength.fromJson(e))
          .toList() ??
          [],
      weeklyAttendance: (json['weeklyAttendance'] as List<dynamic>?)
          ?.map((e) => AttendanceTrend.fromJson(e))
          .toList() ??
          [],
      monthlyFeeCollection: (json['monthlyFeeCollection'] as List<dynamic>?)
          ?.map((e) => FeeCollectionTrend.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'totalParents': totalParents,
      'totalClasses': totalClasses,
      'averageAttendance': averageAttendance,
      'todayAttendance': todayAttendance,
      'presentToday': presentToday,
      'absentToday': absentToday,
      'feeCollectionRate': feeCollectionRate,
      'totalFeesCollected': totalFeesCollected,
      'totalFeesPending': totalFeesPending,
      'upcomingEvents': upcomingEvents,
      'pendingAdmissions': pendingAdmissions,
      'genderDistribution': genderDistribution.toJson(),
      'classWiseStrength': classWiseStrength.map((e) => e.toJson()).toList(),
      'weeklyAttendance': weeklyAttendance.map((e) => e.toJson()).toList(),
      'monthlyFeeCollection': monthlyFeeCollection.map((e) => e.toJson()).toList(),
    };
  }
}

class StudentGenderDistribution {
  final int male;
  final int female;
  final int other;

  StudentGenderDistribution({
    required this.male,
    required this.female,
    required this.other,
  });

  int get total => male + female + other;

  factory StudentGenderDistribution.fromJson(Map<String, dynamic> json) {
    return StudentGenderDistribution(
      male: json['male'] ?? 0,
      female: json['female'] ?? 0,
      other: json['other'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'male': male,
      'female': female,
      'other': other,
    };
  }
}

class ClassStrength {
  final String className;
  final int totalStudents;
  final int maleStudents;
  final int femaleStudents;

  ClassStrength({
    required this.className,
    required this.totalStudents,
    required this.maleStudents,
    required this.femaleStudents,
  });

  factory ClassStrength.fromJson(Map<String, dynamic> json) {
    return ClassStrength(
      className: json['className'] ?? '',
      totalStudents: json['totalStudents'] ?? 0,
      maleStudents: json['maleStudents'] ?? 0,
      femaleStudents: json['femaleStudents'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'totalStudents': totalStudents,
      'maleStudents': maleStudents,
      'femaleStudents': femaleStudents,
    };
  }
}

class AttendanceTrend {
  final String day;
  final DateTime date;
  final double percentage;
  final int present;
  final int absent;

  AttendanceTrend({
    required this.day,
    required this.date,
    required this.percentage,
    required this.present,
    required this.absent,
  });

  factory AttendanceTrend.fromJson(Map<String, dynamic> json) {
    return AttendanceTrend(
      day: json['day'] ?? '',
      date: DateTime.parse(json['date']),
      percentage: (json['percentage'] ?? 0).toDouble(),
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date.toIso8601String(),
      'percentage': percentage,
      'present': present,
      'absent': absent,
    };
  }
}

class FeeCollectionTrend {
  final String month;
  final double collected;
  final double pending;
  final double total;

  FeeCollectionTrend({
    required this.month,
    required this.collected,
    required this.pending,
    required this.total,
  });

  double get collectionRate => total > 0 ? (collected / total) * 100 : 0;

  factory FeeCollectionTrend.fromJson(Map<String, dynamic> json) {
    return FeeCollectionTrend(
      month: json['month'] ?? '',
      collected: (json['collected'] ?? 0).toDouble(),
      pending: (json['pending'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'collected': collected,
      'pending': pending,
      'total': total,
    };
  }
}

class RecentActivity {
  final String id;
  final String title;
  final String description;
  final String type; // 'student', 'teacher', 'announcement', 'event', 'fee', etc.
  final DateTime timestamp;
  final String? userId;
  final String? userName;

  RecentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.userId,
    this.userName,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userName': userName,
    };
  }
}