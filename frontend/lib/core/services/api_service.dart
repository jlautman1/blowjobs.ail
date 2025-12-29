import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/environment_provider.dart';

class ApiService {
  final Dio _dio;
  String? _authToken;
  final Ref _ref;

  ApiService(this._ref) : _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Update base URL from environment provider
        final apiUrl = _ref.read(apiUrlProvider);
        options.baseUrl = apiUrl;
        
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle errors globally
        return handler.next(error);
      },
    ));
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server. Is the backend running?');
      }
      throw Exception('Login failed. Please try again.');
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String firstName,
    String userType,
  ) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'first_name': firstName,
      'user_type': userType,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dio.get('/me');
    return response.data;
  }

  Future<Map<String, dynamic>> getUserStats() async {
    final response = await _dio.get('/me/stats');
    return response.data;
  }

  // Profile endpoints
  Future<Map<String, dynamic>> getJobSeekerProfile() async {
    final response = await _dio.get('/profiles/job-seeker');
    return response.data;
  }

  Future<void> updateJobSeekerProfile(Map<String, dynamic> profile) async {
    await _dio.put('/profiles/job-seeker', data: profile);
  }

  Future<Map<String, dynamic>> getRecruiterProfile() async {
    final response = await _dio.get('/profiles/recruiter');
    return response.data;
  }

  Future<void> updateRecruiterProfile(Map<String, dynamic> profile) async {
    await _dio.put('/profiles/recruiter', data: profile);
  }

  // Job endpoints
  Future<List<dynamic>> getJobFeed({int limit = 10}) async {
    final response = await _dio.get('/jobs/feed', queryParameters: {'limit': limit});
    return response.data;
  }

  Future<List<dynamic>> getCandidateFeed({int limit = 10}) async {
    final response = await _dio.get('/candidates/feed', queryParameters: {'limit': limit});
    return response.data;
  }

  Future<Map<String, dynamic>> createJob(Map<String, dynamic> job) async {
    final response = await _dio.post('/jobs', data: job);
    return response.data;
  }

  Future<List<dynamic>> getMyJobs() async {
    final response = await _dio.get('/jobs/my-jobs');
    return response.data;
  }

  // Swipe endpoints
  Future<Map<String, dynamic>> recordSwipe(String targetId, String direction) async {
    final response = await _dio.post('/swipes', data: {
      'target_id': targetId,
      'direction': direction,
    });
    return response.data;
  }

  Future<List<dynamic>> getSwipeHistory() async {
    final response = await _dio.get('/swipes/history');
    return response.data;
  }

  Future<void> resetSwipes() async {
    try {
      await _dio.delete('/swipes/reset');
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Reset swipes is only available in development mode');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Reset endpoint not found. Make sure you are in development mode.');
      }
      throw Exception('Failed to reset swipes: ${e.message}');
    }
  }

  // Match endpoints
  Future<List<dynamic>> getMatches() async {
    final response = await _dio.get('/matches');
    return response.data;
  }

  Future<Map<String, dynamic>> getMatch(String matchId) async {
    final response = await _dio.get('/matches/$matchId');
    return response.data;
  }

  // Chat endpoints
  Future<List<dynamic>> getConversations() async {
    final response = await _dio.get('/chat/conversations');
    return response.data;
  }

  Future<List<dynamic>> getMessages(String matchId, {int limit = 50, int offset = 0}) async {
    final response = await _dio.get('/chat/$matchId/messages', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> sendMessage(String matchId, String content) async {
    final response = await _dio.post('/chat/$matchId/messages', data: {
      'content': content,
    });
    return response.data;
  }

  Future<void> markMessagesRead(String matchId) async {
    await _dio.put('/chat/$matchId/read');
  }

  // Interview endpoints
  Future<List<dynamic>> getInterviews() async {
    final response = await _dio.get('/interviews');
    return response.data;
  }

  Future<Map<String, dynamic>> scheduleInterview(Map<String, dynamic> interview) async {
    final response = await _dio.post('/interviews', data: interview);
    return response.data;
  }

  // Gamification endpoints
  Future<Map<String, dynamic>> getGamificationStats() async {
    final response = await _dio.get('/gamification/stats');
    return response.data;
  }

  Future<List<dynamic>> getBadges() async {
    final response = await _dio.get('/gamification/badges');
    return response.data;
  }

  Future<Map<String, dynamic>> claimDailyReward() async {
    final response = await _dio.post('/gamification/daily-reward');
    return response.data;
  }

  // CV Upload endpoint
  Future<Map<String, dynamic>> uploadCV(Uint8List fileBytes, String fileName) async {
    final formData = FormData.fromMap({
      'cv': MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
      ),
    });
    
    // Don't set Content-Type header - Dio will set it automatically with boundary
    final response = await _dio.post(
      '/profiles/job-seeker/cv',
      data: formData,
    );
    return response.data;
  }
}

