import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/data/news/mock_news_data.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/news/news_model.dart';

class NewsService {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  // 임시 데이터를 불러오는 메서드
  Future<List<News>> fetchNews() async {
    // 실제 API가 아니라 로컬 데이터를 사용하는 부분
    return mockNewsData.map((data) => News.fromJson(data)).toList();
  }

  Future<List<News>> fetchRecentNews(String accessToken) async {
    try {
      // 디버깅용으로 토큰과 URL을 출력합니다.
      print("Requesting recent news with Access Token: $accessToken");
      print("API URL: $apiServerUrl/news/recent");

      final response = await http.get(
        Uri.parse('$apiServerUrl/news/recent'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      // 응답 상태 코드와 내용을 출력하여 디버깅을 돕습니다.
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        var data = jsonDecode(decodedBody);

        if (data is List) {
          return data.map((e) => News.fromJson(e)).toList();
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
      } else {
        throw Exception(
            'Failed to load recent news: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load recent news: $e');
    }
  }

  Future<List<News>> fetchNewsByCategory(
      String accessToken, String category) async {
    try {
      final response = await http.get(
        Uri.parse('$apiServerUrl/news?category=$category'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        var data = jsonDecode(decodedBody);

        if (data is List) {
          return data.map((e) => News.fromJson(e)).toList();
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
      } else {
        throw Exception(
            'Failed to load news by category: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load news by category: $e');
    }
  }
}
