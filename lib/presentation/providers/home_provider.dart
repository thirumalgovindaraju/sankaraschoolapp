// lib/presentation/providers/home_provider.dart

import 'package:flutter/foundation.dart';
import '../../data/models/news_model.dart';

class HomeProvider with ChangeNotifier {
  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error state
  String? _error;
  String? get error => _error;

  // News/Announcements list
  List<NewsModel> _newsList = [];
  List<NewsModel> get newsList => _newsList;

  // Constructor - Load initial data
  HomeProvider() {
    loadHomeData();
  }

  // Load all home screen data
  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Load dummy news data (replace with actual API call later)
      _newsList = _getDummyNews();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadHomeData();
  }

  // Get dummy news (temporary - replace with API)
  List<NewsModel> _getDummyNews() {
    return [
      NewsModel(
        id: '1',
        title: 'Admissions Open 2025-2026',
        description: 'Admissions are now open for the academic year 2025-2026. Apply now!',
        date: DateTime.now(),
        imageUrl: 'https://www.srisankaraglobal.com/images/admission-banner.jpg',
        category: 'Admission',
      ),
      NewsModel(
        id: '2',
        title: 'Annual Day Celebration',
        description: 'Join us for our Annual Day celebration on December 15, 2024.',
        date: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl: 'https://www.srisankaraglobal.com/images/annual-day.jpg',
        category: 'Event',
      ),
      NewsModel(
        id: '3',
        title: 'Sports Day Winners',
        description: 'Congratulations to all our sports day winners! Excellent performance by all students.',
        date: DateTime.now().subtract(const Duration(days: 5)),
        imageUrl: 'https://www.srisankaraglobal.com/images/sports-day.jpg',
        category: 'Achievement',
      ),
      NewsModel(
        id: '4',
        title: 'Parent-Teacher Meeting',
        description: 'Next parent-teacher meeting scheduled for December 22, 2024.',
        date: DateTime.now().subtract(const Duration(days: 7)),
        category: 'Meeting',
      ),
    ];
  }

  // Add new news item
  void addNews(NewsModel news) {
    _newsList.insert(0, news);
    notifyListeners();
  }

  // Get latest news (top 3)
  List<NewsModel> getLatestNews({int limit = 3}) {
    if (_newsList.length <= limit) {
      return _newsList;
    }
    return _newsList.sublist(0, limit);
  }

  // Get news by category
  List<NewsModel> getNewsByCategory(String category) {
    return _newsList.where((news) => news.category == category).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}