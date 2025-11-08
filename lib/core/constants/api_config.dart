class ApiConfig {
  /// Production API URL (Laravel / Node / Django etc.)
  static const String baseUrl = 'https://sankaraschoolapp.com/api';

  /// Set `false` when backend is ready
  static const bool useMockData = false;

  /// API endpoints
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String userProfile = '$baseUrl/user/profile';
  static const String announcements = '$baseUrl/announcements';
  static const String attendance = '$baseUrl/attendance';
  static const String notifications = '$baseUrl/notifications';

  // ADD THESE MISSING ENDPOINTS:
  static const String events = '$baseUrl/events';
  static const String admissions = '$baseUrl/admissions';
}