// lib/presentation/providers/dashboard_provider.dart (FINAL VERSION)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/dashboard_stats.dart';
import '../../domain/models/activity.dart';

class DashboardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DashboardStats? _stats;
  List<Activity> _recentActivities = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  DashboardStats? get stats => _stats;
  List<Activity> get recentActivities => _recentActivities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Real-time listeners
  StreamSubscription<QuerySnapshot>? _studentsSubscription;
  StreamSubscription<QuerySnapshot>? _activitiesSubscription;

  // Initialize real-time updates
  void initializeRealTimeUpdates() {
    print('🔄 Initializing real-time Firestore updates...');

    try {
      // Listen to students collection
      _studentsSubscription = _firestore
          .collection('students')
          .snapshots()
          .listen(
            (snapshot) {
          print('📊 Students updated: ${snapshot.docs.length} documents');
          // Schedule refresh on platform thread to avoid threading errors
          _safeRefreshDashboard();
        },
        onError: (error) {
          print('❌ Error listening to students: $error');
        },
      );

      // Listen to activities collection
      _activitiesSubscription = _firestore
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots()
          .listen(
            (snapshot) {
          print('📊 Activities updated: ${snapshot.docs.length} documents');
          // Schedule loading on platform thread to avoid threading errors
          _safeLoadActivitiesFromSnapshot(snapshot);
        },
        onError: (error) {
          print('❌ Error listening to activities: $error');
        },
      );

      // Initial load
      refreshDashboard();
      loadRecentActivities();
    } catch (e) {
      print('❌ Error initializing real-time updates: $e');
    }
  }

  // Thread-safe refresh that ensures execution on platform thread
  void _safeRefreshDashboard() {
    // Use addPostFrameCallback to ensure we're on the platform thread
    SchedulerBinding.instance.addPostFrameCallback((_) {
      refreshDashboard();
    });
  }

  // Thread-safe activity loading
  void _safeLoadActivitiesFromSnapshot(QuerySnapshot snapshot) {
    // Use addPostFrameCallback to ensure we're on the platform thread
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadActivitiesFromSnapshot(snapshot);
    });
  }

  // Load activities from snapshot
  void _loadActivitiesFromSnapshot(QuerySnapshot snapshot) {
    try {
      _recentActivities = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Activity(
          id: doc.id,
          type: data['type'] ?? 'info',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          metadata: data['metadata'] as Map<String, dynamic>? ?? {},
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print('❌ Error loading activities: $e');
    }
  }

  // Refresh dashboard stats
  Future<void> refreshDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get students count
      final studentsSnapshot = await _firestore.collection('students').get();
      final totalStudents = studentsSnapshot.docs.length;

      // Get teachers count
      final teachersSnapshot = await _firestore.collection('teachers').get();
      final totalTeachers = teachersSnapshot.docs.length;

      // Calculate class count
      final studentsByClass = <String>{};
      for (var doc in studentsSnapshot.docs) {
        final data = doc.data();
        final className = data['class'] ?? '';
        if (className.isNotEmpty) {
          studentsByClass.add(className);
        }
      }

      // Create stats with required parameters only
      _stats = DashboardStats(
        totalStudents: totalStudents,
        totalTeachers: totalTeachers,
        totalClasses: studentsByClass.length,
        averageAttendance: 92.5, // Mock data
        totalFeesCollected: 450000.0, // Mock data
        totalFeesPending: 50000.0, // Mock data
        feeCollectionRate: 90.0, // Mock data
        weeklyAttendance: [], // Empty for now
      );

      _isLoading = false;
      print('✅ Dashboard refreshed: $totalStudents students, $totalTeachers teachers');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh dashboard: $e';
      _isLoading = false;
      print('❌ Error refreshing dashboard: $e');
      notifyListeners();
    }
  }

  // Load recent activities
  Future<void> loadRecentActivities() async {
    try {
      final snapshot = await _firestore
          .collection('activities')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      _loadActivitiesFromSnapshot(snapshot);
    } catch (e) {
      print('❌ Error loading activities: $e');
    }
  }

  // Helper methods for trends
  String getStudentGrowthTrend() {
    return '+5%';
  }

  String getTeacherGrowthTrend() {
    return '+2%';
  }

  String getAttendanceTrend() {
    return '+1.5%';
  }

  String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  @override
  void dispose() {
    _studentsSubscription?.cancel();
    _activitiesSubscription?.cancel();
    super.dispose();
  }
}