import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class QuizApiService {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  // 퀴즈 데이터를 불러오는 함수
  Future<Map<String, dynamic>> getQuizData(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$apiServerUrl/questions'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        var data = jsonDecode(decodedBody);

        if (data is Map<String, dynamic>) {
          return data; // 단일 객체를 그대로 반환
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
      } else {
        throw Exception(
            'Failed to load quiz data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load quiz data: $e');
    }
  }

  // 퀴즈 정답 제출 함수
  Future<bool> submitQuizAnswer(
      String accessToken, int quizId, String answer) async {
    try {
      final response = await http.post(
        Uri.parse('$apiServerUrl/questions?quizId=$quizId&answer=$answer'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) == true;
      } else {
        throw Exception(
            'Failed to submit quiz answer: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to submit quiz answer: $e');
    }
  }

  // 퀴즈 건너뛰기 함수
  Future<void> skipQuiz(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('$apiServerUrl/questions/skip'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to skip quiz: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to skip quiz: $e');
    }
  }
}
