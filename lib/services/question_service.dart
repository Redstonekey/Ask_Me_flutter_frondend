import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';
import 'api_client.dart';

class QuestionService {
  static Future<Map<String, dynamic>> submitQuestion(String receiver, String question) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/questions'),
        headers: ApiClient.headers,
        body: jsonEncode({
          'receiver': receiver,
          'question': question,
        }),
      );
      
      return ApiClient.handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> answerQuestion(int questionId, String answer) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/questions/$questionId/answer'),
        headers: ApiClient.headers,
        body: jsonEncode({
          'answer': answer,
        }),
      );
      
      return ApiClient.handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> deleteQuestion(int questionId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Config.apiBaseUrl}/questions/$questionId'),
        headers: ApiClient.headers,
      );
      
      return ApiClient.handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
