// lib/data/repositories/dashboard_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_stats_model.dart';
import '../services/dashboard_service.dart';
import '../services/activity_service.dart';

class DashboardRepository {
  final DashboardService _dashboardService;
  final ActivityService _activityService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DashboardRepository({
    DashboardService? dashboardService,
    ActivityService? activityService,
  })  : _dashboardService = dashboardService ?? DashboardService(null as dynamic),
        _activityService = activityService ?? ActivityService();

  /// Fetch dashboard statistics
  Future<DashboardStats> fetchDashboardStats() async {
    try {
      // Try to fetch real-time data from Firestore
      final stats = await _fetchRealTimeStats();
      if (stats != null) return stats;

      // Fallback to service if Firestore fails
      return await _dashboardService.fetchDashboardStats();
    } catch (e) {
      print('❌ Repository Error: $e');
      return await _dashboardService.fetchDashboardStats();
    }
  }

  /// Fetch real-time statistics from Firestore
  Future<DashboardStats?> _fetchRealTimeStats() async {
    try {
      // Fetch counts from different collections
      final studentsCount = await _firestore.collection('students').count().get();
      final teachersCount = await _firestore.collection('teachers').count().get();
      final parentsCount = await _firestore.collection('parents').count().get();

      // Get today's attendance
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final attendanceSnapshot = await _firestore
          .collection('attendance')
          .where('date', isEqualTo: todayStr)
          .get();

      int presentToday = 0;
      int absentToday = 0;

      for (var doc in attendanceSnapshot.docs) {
        final status = doc.data()['status'];
        if (status == 'present') {
          presentToday++;
        } else if (status == 'absent') {
          absentToday++;
        }
      }

      final totalStudents = studentsCount.count ?? 0;
      final todayAttendance = totalStudents > 0
          ? (presentToday / totalStudents * 100)
          : 0.0;

      // Calculate fee collection (you can customize this based on your fee structure)
      final feeSnapshot = await _firestore
          .collection('fees')
          .where('status', isEqualTo: 'paid')
          .get();

      double totalFeesCollected = 0;
      for (var doc in feeSnapshot.docs) {
        totalFeesCollected += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
      }

      final pendingFeeSnapshot = await _firestore
          .collection('fees')
          .where('status', isEqualTo: 'pending')
          .get();

      double totalFeesPending = 0;
      for (var doc in pendingFeeSnapshot.docs) {
        totalFeesPending += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
      }

      final totalFees = totalFeesCollected + totalFeesPending;
      final feeCollectionRate = totalFees > 0
          ? (totalFeesCollected / totalFees * 100)
          : 0.0;

      // Get class-wise strength
      final classStrengths = await _fetchClassWiseStrength();

      // Get weekly attendance
      final weeklyAttendance = await _fetchWeeklyAttendance();

      return DashboardStats(
        totalStudents: totalStudents,
        totalTeachers: teachersCount.count ?? 0,
        totalParents: parentsCount.count ?? 0,
        totalClasses: classStrengths.length,
        averageAttendance: todayAttendance,
        todayAttendance: todayAttendance,
        presentToday: presentToday,
        absentToday: absentToday,
        feeCollectionRate: feeCollectionRate,
        totalFeesCollected: totalFeesCollected,
        totalFeesPending: totalFeesPending,
        upcomingEvents: 5, // You can fetch from events collection
        pendingAdmissions: 0, // You can fetch from admissions collection
        genderDistribution: await _fetchGenderDistribution(),
        classWiseStrength: classStrengths,
        weeklyAttendance: weeklyAttendance,
        monthlyFeeCollection: [], // Optional: implement if needed
      );
    } catch (e) {
      print('❌ Error fetching real-time stats: $e');
      return null;
    }
  }

  /// Fetch class-wise student strength
  Future<List<ClassStrength>> _fetchClassWiseStrength() async {
    try {
      final snapshot = await _firestore.collection('students').get();
      final Map<String, Map<String, int>> classData = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final className = data['class'] ?? 'Unknown';
        final gender = data['gender'] ?? 'Other';

        if (!classData.containsKey(className)) {
          classData[className] = {'male': 0, 'female': 0, 'total': 0};
        }

        classData[className]!['total'] = (classData[className]!['total'] ?? 0) + 1;

        if (gender.toLowerCase() == 'male') {
          classData[className]!['male'] = (classData[className]!['male'] ?? 0) + 1;
        } else if (gender.toLowerCase() == 'female') {
          classData[className]!['female'] = (classData[className]!['female'] ?? 0) + 1;
        }
      }

      return classData.entries.map((entry) {
        return ClassStrength(
          className: entry.key,
          totalStudents: entry.value['total'] ?? 0,
          maleStudents: entry.value['male'] ?? 0,
          femaleStudents: entry.value['female'] ?? 0,
        );
      }).toList()
        ..sort((a, b) => a.className.compareTo(b.className));
    } catch (e) {
      print('❌ Error fetching class-wise strength: $e');
      return [];
    }
  }

  /// Fetch weekly attendance trends
  Future<List<AttendanceTrend>> _fetchWeeklyAttendance() async {
    try {
      final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
      final attendanceData = <AttendanceTrend>[];
      final now = DateTime.now();

      for (int i = 0; i < 5; i++) {
        final date = now.subtract(Duration(days: 4 - i));
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        final snapshot = await _firestore
            .collection('attendance')
            .where('date', isEqualTo: dateStr)
            .get();

        int present = 0;
        int absent = 0;

        for (var doc in snapshot.docs) {
          final status = doc.data()['status'];
          if (status == 'present') {
            present++;
          } else if (status == 'absent') {
            absent++;
          }
        }

        final total = present + absent;
        final percentage = total > 0 ? (present / total * 100) : 0.0;

        attendanceData.add(AttendanceTrend(
          day: weekDays[i],
          date: date,
          percentage: percentage,
          present: present,
          absent: absent,
        ));
      }

      return attendanceData;
    } catch (e) {
      print('❌ Error fetching weekly attendance: $e');
      return [];
    }
  }

  /// Fetch gender distribution
  Future<StudentGenderDistribution> _fetchGenderDistribution() async {
    try {
      final snapshot = await _firestore.collection('students').get();
      int male = 0;
      int female = 0;
      int other = 0;

      for (var doc in snapshot.docs) {
        final gender = (doc.data()['gender'] ?? '').toLowerCase();
        if (gender == 'male') {
          male++;
        } else if (gender == 'female') {
          female++;
        } else {
          other++;
        }
      }

      return StudentGenderDistribution(
        male: male,
        female: female,
        other: other,
      );
    } catch (e) {
      print('❌ Error fetching gender distribution: $e');
      return StudentGenderDistribution(male: 0, female: 0, other: 0);
    }
  }

  /// Fetch recent activities
  Future<List<RecentActivity>> fetchRecentActivities({int limit = 10}) async {
    try {
      return await _activityService.getRecentActivities(limit: limit);
    } catch (e) {
      print('❌ Repository Error: $e');
      return [];
    }
  }

  /// Get activities stream for real-time updates
  Stream<List<RecentActivity>> getActivitiesStream({int limit = 10}) {
    return _activityService.getActivitiesStream(limit: limit);
  }

  /// Refresh all dashboard data
  Future<Map<String, dynamic>> refreshAllData() async {
    try {
      final stats = await fetchDashboardStats();
      final activities = await fetchRecentActivities(limit: 10);

      return {
        'success': true,
        'stats': stats,
        'activities': activities,
      };
    } catch (e) {
      print('❌ Error refreshing dashboard: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
