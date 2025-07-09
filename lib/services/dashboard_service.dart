import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'api_client.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/dashboard'),
        headers: ApiClient.headers,
      );
      
      return ApiClient.handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
