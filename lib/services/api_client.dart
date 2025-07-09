import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';

class ApiClient {
  static String? _token;
  
  static void setToken(String token) {
    _token = token;
  }
  
  static void clearToken() {
    _token = null;
  }
  
  static String? get token => _token;
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };
  
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/health'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  static Map<String, dynamic> handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        data['error'] ?? 'Unknown error',
        response.statusCode,
        data['details'],
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? details;
  
  ApiException(this.message, this.statusCode, [this.details]);
  
  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)${details != null ? ' - $details' : ''}';
  }
}
