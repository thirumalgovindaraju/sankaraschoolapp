class ApiConfig {
  /// Use Firebase instead of REST API
  static const bool useFirebase = true;

  /// Mock data flag (for testing without backend)
  static const bool useMockData = false;

  /// For future REST API fallback
  static const String baseUrl = 'https://sankaraschoolapp.com/api';

  /// REST API Endpoints (for fallback when not using Firebase)
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String announcements = '/announcements';
  static const String events = '/events';
  static const String admissions = '/admissions';
  static const String userProfile = '/user/profile';

  /// Firebase Collection Names
  static const String usersCollection = 'users';
  static const String studentsCollection = 'students';
  static const String teachersCollection = 'teachers';
  static const String attendanceCollection = 'attendance';
  static const String announcementsCollection = 'announcements';
  static const String eventsCollection = 'events';
  static const String notificationsCollection = 'notifications';
  static const String admissionsCollection = 'admissions';
  static const String gradesCollection = 'grades';
  static const String feesCollection = 'fees';
  static const String leavesCollection = 'leaves';
  static const String timetableCollection = 'timetable';

  /// Firebase Storage Paths
  static const String studentPhotosPath = 'students/photos';
  static const String teacherPhotosPath = 'teachers/photos';
  static const String documentsPath = 'documents';
  static const String announcementImagesPath = 'announcements/images';

  /// User Roles
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';
  static const String roleParent = 'parent';
}