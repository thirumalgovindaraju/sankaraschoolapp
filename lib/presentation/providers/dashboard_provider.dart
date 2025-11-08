// lib/presentation/providers/dashboard_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../data/services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService;

  DashboardProvider(this._dashboardService);

  // State
  DashboardStats? _stats;
  List<RecentActivity> _recentActivities = [];
  bool _isLoading = false;
  bool _isActivitiesLoading = false;
  String? _error;

  // Getters
  DashboardStats? get stats => _stats;
  List<RecentActivity> get recentActivities => _recentActivities;
  bool get isLoading => _isLoading;
  bool get isActivitiesLoading => _isActivitiesLoading;
  String? get error => _error;
  bool get hasData => _stats != null;

  /// Fetch dashboard statistics
  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await _dashboardService.fetchDashboardStats();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error in fetchDashboardStats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch recent activities
  Future<void> fetchRecentActivities() async {
    _isActivitiesLoading = true;
    notifyListeners();

    try {
      _recentActivities = await _dashboardService.fetchRecentActivities(limit: 10);
    } catch (e) {
      print('Error in fetchRecentActivities: $e');
    } finally {
      _isActivitiesLoading = false;
      notifyListeners();
    }
  }

  /// Refresh all dashboard data
  Future<void> refreshDashboard() async {
    await Future.wait([
      fetchDashboardStats(),
      fetchRecentActivities(),
    ]);
  }

  /// Get student growth trend
  String getStudentGrowthTrend() {
    if (_stats == null) return '+0%';
    // Mock calculation - in real app, compare with previous month
    return '+5.2%';
  }

  /// Get teacher growth trend
  String getTeacherGrowthTrend() {
    if (_stats == null) return '+0%';
    return '+2.1%';
  }

  /// Get attendance trend
  String getAttendanceTrend() {
    if (_stats == null) return '+0%';
    return '+1.5%';
  }

  /// Get fee collection trend
  String getFeeCollectionTrend() {
    if (_stats == null) return '+0%';
    return '+3.2%';
  }

  /// Format currency
  String formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(2)} K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  /// Format number with suffix
  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Get time ago string
  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Clear data
  void clearData() {
    _stats = null;
    _recentActivities = [];
    _error = null;
    notifyListeners();
  }
}