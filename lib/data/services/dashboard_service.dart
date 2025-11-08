// lib/data/services/dashboard_service.dart
import 'dart:convert';
import 'dart:math';
import '../models/dashboard_stats_model.dart';
import 'test_data_service.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService;
  final bool useTestMode;

  DashboardService(this._apiService, {this.useTestMode = true});

  /// Fetch dashboard statistics

  /// Fetch dashboard statistics
  Future<DashboardStats> fetchDashboardStats() async {
    if (useTestMode) {
      return _getTestDashboardStats();
    }

    try {
      // Get the HTTP response
      final response = await _apiService.get('/admin/dashboard/stats');

      // Check if request was successful
      if (response.statusCode == 200) {
        // Parse the JSON response body
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return DashboardStats.fromJson(jsonData);
      } else {
        print('Error: API returned status code ${response.statusCode}');
        return _getTestDashboardStats();
      }
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return _getTestDashboardStats();
    }
  }
  /// Fetch recent activities
  Future<List<RecentActivity>> fetchRecentActivities({int limit = 10}) async {
    if (useTestMode) {
      return _getTestRecentActivities().take(limit).toList();
    }

    try {
      final response = await _apiService.get('/admin/dashboard/activities?limit=$limit');
      return (response as List).map((e) => RecentActivity.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching recent activities: $e');
      return _getTestRecentActivities().take(limit).toList();
    }
  }

  /// Get test dashboard statistics
  DashboardStats _getTestDashboardStats() {
    final testData = TestDataService.instance;
    final students = testData.getStudents();
    final teachers = testData.getTeachers();

    // Calculate real counts
    final totalStudents = students.length;
    final totalTeachers = teachers.length;

    // Calculate gender distribution
    int maleCount = 0;
    int femaleCount = 0;
    int otherCount = 0;

    for (var student in students) {
      // You can add gender field to student data, for now using random distribution
      final random = Random(student['student_id'].hashCode);
      if (random.nextDouble() < 0.52) {
        maleCount++;
      } else if (random.nextDouble() < 0.48) {
        femaleCount++;
      } else {
        otherCount++;
      }
    }

    // Generate class-wise strength
    final classStrengths = _generateClassWiseStrength(students);

    // Generate weekly attendance
    final weeklyAttendance = _generateWeeklyAttendance(totalStudents);

    // Generate fee collection trends
    final feeCollection = _generateFeeCollectionTrends();

    // Calculate today's attendance (mock data)
    final todayPresent = (totalStudents * 0.94).round();
    final todayAbsent = totalStudents - todayPresent;

    return DashboardStats(
      totalStudents: totalStudents,
      totalTeachers: totalTeachers,
      totalParents: totalStudents, // Assuming 1 parent per student
      totalClasses: classStrengths.length,
      averageAttendance: 93.5,
      todayAttendance: 94.2,
      presentToday: todayPresent,
      absentToday: todayAbsent,
      feeCollectionRate: 87.5,
      totalFeesCollected: 2450000,
      totalFeesPending: 350000,
      upcomingEvents: 5,
      pendingAdmissions: 12,
      genderDistribution: StudentGenderDistribution(
        male: maleCount,
        female: femaleCount,
        other: otherCount,
      ),
      classWiseStrength: classStrengths,
      weeklyAttendance: weeklyAttendance,
      monthlyFeeCollection: feeCollection,
    );
  }

  /// Generate class-wise strength from student data
  List<ClassStrength> _generateClassWiseStrength(List<Map<String, dynamic>> students) {
    final Map<String, List<Map<String, dynamic>>> classGroups = {};

    for (var student in students) {
      final className = student['class'] ?? 'Unknown';
      if (!classGroups.containsKey(className)) {
        classGroups[className] = [];
      }
      classGroups[className]!.add(student);
    }

    return classGroups.entries.map((entry) {
      final className = entry.key;
      final classStudents = entry.value;

      int male = 0;
      int female = 0;

      for (var student in classStudents) {
        final random = Random(student['student_id'].hashCode);
        if (random.nextDouble() < 0.52) {
          male++;
        } else {
          female++;
        }
      }

      return ClassStrength(
        className: className,
        totalStudents: classStudents.length,
        maleStudents: male,
        femaleStudents: female,
      );
    }).toList()
      ..sort((a, b) => a.className.compareTo(b.className));
  }

  /// Generate weekly attendance trends
  List<AttendanceTrend> _generateWeeklyAttendance(int totalStudents) {
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final attendanceData = <AttendanceTrend>[];

    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: 4 - i));
      final random = Random(date.day);
      final percentage = 90.0 + random.nextDouble() * 8.0; // 90-98%
      final present = (totalStudents * percentage / 100).round();
      final absent = totalStudents - present;

      attendanceData.add(AttendanceTrend(
        day: weekDays[i],
        date: date,
        percentage: percentage,
        present: present,
        absent: absent,
      ));
    }

    return attendanceData;
  }

  /// Generate monthly fee collection trends
  List<FeeCollectionTrend> _generateFeeCollectionTrends() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final feeData = <FeeCollectionTrend>[];

    for (int i = 0; i < 6; i++) {
      final total = 500000.0;
      final random = Random(i);
      final collectionRate = 0.75 + random.nextDouble() * 0.2; // 75-95%
      final collected = total * collectionRate;
      final pending = total - collected;

      feeData.add(FeeCollectionTrend(
        month: months[i],
        collected: collected,
        pending: pending,
        total: total,
      ));
    }

    return feeData;
  }

  /// Get test recent activities
  List<RecentActivity> _getTestRecentActivities() {
    final now = DateTime.now();

    return [
      RecentActivity(
        id: 'ACT001',
        title: 'New Student Admission',
        description: 'Rajesh Kumar enrolled in Grade 10-A',
        type: 'student',
        timestamp: now.subtract(const Duration(hours: 2)),
        userName: 'Rajesh Kumar',
      ),
      RecentActivity(
        id: 'ACT002',
        title: 'Teacher Assignment Updated',
        description: 'Math teacher assigned to Grade 9-B',
        type: 'teacher',
        timestamp: now.subtract(const Duration(hours: 4)),
        userName: 'Admin',
      ),
      RecentActivity(
        id: 'ACT003',
        title: 'Announcement Posted',
        description: 'School holiday notice for Diwali',
        type: 'announcement',
        timestamp: now.subtract(const Duration(hours: 5)),
        userName: 'Admin',
      ),
      RecentActivity(
        id: 'ACT004',
        title: 'Attendance Marked',
        description: 'Grade 10-A attendance marked - 42/45 present',
        type: 'attendance',
        timestamp: now.subtract(const Duration(hours: 6)),
        userName: 'Teacher',
      ),
      RecentActivity(
        id: 'ACT005',
        title: 'Fee Payment Received',
        description: 'Monthly fee paid by Priya Sharma (10-B)',
        type: 'fee',
        timestamp: now.subtract(const Duration(hours: 8)),
        userName: 'Priya Sharma',
      ),
      RecentActivity(
        id: 'ACT006',
        title: 'Event Created',
        description: 'Annual Sports Day scheduled for Dec 15',
        type: 'event',
        timestamp: now.subtract(const Duration(days: 1)),
        userName: 'Admin',
      ),
      RecentActivity(
        id: 'ACT007',
        title: 'Exam Schedule Published',
        description: 'Half-yearly exam timetable released',
        type: 'exam',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        userName: 'Admin',
      ),
      RecentActivity(
        id: 'ACT008',
        title: 'Library Book Issued',
        description: 'Mathematics textbook issued to Amit Singh',
        type: 'library',
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        userName: 'Amit Singh',
      ),
      RecentActivity(
        id: 'ACT009',
        title: 'Parent Meeting Scheduled',
        description: 'PTM scheduled for Grade 10 parents on Nov 20',
        type: 'meeting',
        timestamp: now.subtract(const Duration(days: 2)),
        userName: 'Admin',
      ),
      RecentActivity(
        id: 'ACT010',
        title: 'New Teacher Joined',
        description: 'Mrs. Sharma joined as English teacher',
        type: 'teacher',
        timestamp: now.subtract(const Duration(days: 2, hours: 4)),
        userName: 'Mrs. Sharma',
      ),
    ];
  }

  /// Calculate percentage change
  String calculateChange(double current, double previous) {
    if (previous == 0) return '+0%';
    final change = ((current - previous) / previous) * 100;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}%';
  }

  /// Get activity icon
  String getActivityIcon(String type) {
    switch (type) {
      case 'student':
        return 'person_add';
      case 'teacher':
        return 'school';
      case 'announcement':
        return 'announcement';
      case 'attendance':
        return 'check_circle';
      case 'fee':
        return 'payment';
      case 'event':
        return 'event';
      case 'exam':
        return 'quiz';
      case 'library':
        return 'book';
      case 'meeting':
        return 'people';
      default:
        return 'info';
    }
  }

  /// Get activity color
  String getActivityColor(String type) {
    switch (type) {
      case 'student':
        return 'blue';
      case 'teacher':
        return 'green';
      case 'announcement':
        return 'orange';
      case 'attendance':
        return 'purple';
      case 'fee':
        return 'teal';
      case 'event':
        return 'pink';
      case 'exam':
        return 'red';
      case 'library':
        return 'brown';
      case 'meeting':
        return 'indigo';
      default:
        return 'grey';
    }
  }
}