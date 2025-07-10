import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';
import 'api_client.dart';

class AuthService {
  static bool _isLoggedIn = false;
  static Map<String, dynamic>? _currentUser;
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  
  static bool get isLoggedIn => _isLoggedIn;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static String? get currentUsername => _currentUser?['username'];
  
  // Initialize auth state on app start
  static Future<void> initialize() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final userJson = await _storage.read(key: _userKey);
      
      if (token != null && userJson != null) {
        ApiClient.setToken(token);
        _currentUser = jsonDecode(userJson);
        _isLoggedIn = true;
      }
    } catch (e) {
      // If there's an error reading stored data, clear it
      await logout();
    }
  }
  
  static Future<Map<String, dynamic>> signup(String email, String password, String username) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/auth/signup'),
        headers: ApiClient.headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );
      
      final data = ApiClient.handleResponse(response);
      
      // After successful signup, automatically log in
      await login(email, password);
      
      return data;
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/auth/login'),
        headers: ApiClient.headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = ApiClient.handleResponse(response);
      
      // Store token and user data
      final token = data['session']['access_token'];
      final user = data['user'];
      
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _userKey, value: jsonEncode(user));
      
      ApiClient.setToken(token);
      _currentUser = user;
      _isLoggedIn = true;
      
      return data;
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<void> logout() async {
    try {
      // Call logout endpoint if we have a token
      if (_isLoggedIn && ApiClient.token != null) {
        await http.post(
          Uri.parse('${Config.apiBaseUrl}/auth/logout'),
          headers: ApiClient.headers,
        );
      }
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      // Clear local data
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      
      ApiClient.clearToken();
      _currentUser = null;
      _isLoggedIn = false;
    }
  }

  // Handle authentication callback from Supabase
  static Future<void> handleAuthCallback(String accessToken, String refreshToken) async {
    try {
      // Store the tokens
      await _storage.write(key: _tokenKey, value: accessToken);
      ApiClient.setToken(accessToken);
      
      // You might need to fetch user data from your backend using the token
      // For now, we'll set basic auth state
      _isLoggedIn = true;
      
      // TODO: Fetch user data from backend using the token
      // This is a placeholder - you'll need to implement this based on your backend
      _currentUser = {
        'id': 'temp_id',
        'username': 'temp_username',
        'email': 'temp_email',
      };
      
      await _storage.write(key: _userKey, value: jsonEncode(_currentUser));
    } catch (e) {
      rethrow;
    }
  }
}
