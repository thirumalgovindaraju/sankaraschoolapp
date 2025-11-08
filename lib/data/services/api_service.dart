import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_config.dart';
import 'package:flutter/foundation.dart';
class ApiService {
  // -------- Singleton --------
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  // ADD THIS STATIC GETTER:
  static String get baseUrl => ApiConfig.baseUrl;

  // -------- Auth token cache --------
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Future<String?> getToken() async {
    try {
      if (_authToken != null) return _authToken;
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
      return _authToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting token: $e');
      }
      return null;
    }
  }

  Future<bool> saveToken(String token) async {
    try {
      _authToken = token;
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString('auth_token', token);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving token: $e');
      }
      return false;
    }
  }

  Future<bool> removeToken() async {
    try {
      _authToken = null;
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('auth_token');
    } catch (e) {
      if (kDebugMode) {
        print('Error removing token: $e');
      }
      return false;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // -------- Headers --------
  Future<Map<String, String>> _jsonHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _authOnlyHeaders() async {
    final token = await getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // -------- URL helpers --------
  Uri _buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    // If path is a full URL (starts with http), use directly
    final isAbsolute = path.startsWith('http');
    final base = isAbsolute ? path : '${ApiConfig.baseUrl}$path';
    final uri = Uri.parse(base);

    if (queryParameters == null || queryParameters.isEmpty) return uri;

    return uri.replace(
      queryParameters: queryParameters.map(
            (k, v) => MapEntry(k, v.toString()),
      ),
    );
  }

  // -------- Raw HTTP methods --------
  Future<http.Response> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) async {
    final url = _buildUri(endpoint, queryParameters: queryParameters);
    final headers = await _authOnlyHeaders();
    return http.get(url, headers: headers);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = _buildUri(endpoint);
    final headers = await _jsonHeaders();
    return http.post(url, headers: headers, body: json.encode(body));
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = _buildUri(endpoint);
    final headers = await _jsonHeaders();
    return http.put(url, headers: headers, body: json.encode(body));
  }

  Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final url = _buildUri(endpoint);
    final headers = await _jsonHeaders();
    return http.patch(url, headers: headers, body: json.encode(body));
  }

  Future<http.Response> delete(String endpoint) async {
    final url = _buildUri(endpoint);
    final headers = await _authOnlyHeaders();
    return http.delete(url, headers: headers);
  }

  // -------- JSON helpers --------
  Future<Map<String, dynamic>> getJson(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      if (ApiConfig.useMockData) {
        // Provide your mock data reads here if needed.
        return {'success': true, 'data': []};
      }

      final response = await get(endpoint, queryParameters: queryParameters);
      final status = response.statusCode;

      if (status >= 200 && status < 300) {
        return json.decode(response.body);
      }
      return {
        'success': false,
        'message': 'Request failed with status: $status',
        'status': status,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> postJson(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    try {
      if (ApiConfig.useMockData) {
        // Provide your mock data logic here
        return {'success': true, 'data': {}};
      }

      final response = await post(endpoint, body);
      final status = response.statusCode;

      if (status >= 200 && status < 300) {
        return json.decode(response.body);
      }
      return {
        'success': false,
        'message': 'Request failed with status: $status',
        'status': status,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ========== HIGH-LEVEL / CONVENIENCE METHODS ==========

  /// Login – returns decoded JSON and saves token if present as `token` or `access_token`
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await postJson(ApiConfig.login, {
      'email': email,
      'password': password,
    });

    // Try to capture and persist token automatically
    final token = res['token'] ?? res['access_token'];
    if (token is String && token.isNotEmpty) {
      await saveToken(token);
    }
    return res;
  }

  Future<void> logout() async {
    try {
      await postJson(ApiConfig.logout, {});
    } catch (_) {}
    await removeToken();
  }

  Future<http.Response> getAnnouncementsRaw() {
    return http.get(Uri.parse(ApiConfig.announcements));
  }

  Future<http.Response> getAnnouncements() {
    return get(ApiConfig.announcements);
  }

  Future<List<dynamic>> getEvents() async {
    try {
      final response = await get(ApiConfig.events);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['data'] ?? decoded as List<dynamic>? ?? [];
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching events: $e');
      }
      return [];
    }
  }

  Future<void> submitAdmission(Map<String, dynamic> data) async {
    try {
      await post(ApiConfig.admissions, data);
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting admission: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() {
    return getJson(ApiConfig.userProfile);
  }
}
