import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'api_client.dart';

class UserService {
  static Future<Map<String, dynamic>> getProfile(String username) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/user/$username'),
        headers: ApiClient.headers,
      );
      
      return ApiClient.handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> getUserQuestions(String username) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/user/$username/questions'),
        headers: ApiClient.headers,
      );
      
      return ApiClient.handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> getMyQuestions() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/user/me/questions'),
        headers: ApiClient.headers,
      );
      
      return ApiClient.handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
