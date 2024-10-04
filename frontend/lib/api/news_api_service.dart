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

  // 최근 뉴스를 불러오는 메서드
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

  // 카테고리별 뉴스를 불러오는 메서드
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

  // 뉴스 상세 정보를 가져오는 메서드
  Future<News> fetchNewsDetail(String accessToken, String newsId) async {
    try {
      // 디버깅용으로 요청 URL과 상태를 확인합니다.
      print(
          "Requesting news detail for newsId: $newsId with Access Token: $accessToken");
      print("API URL: $apiServerUrl/news/detail?newsId=$newsId");

      final response = await http.get(
        Uri.parse('$apiServerUrl/news/detail?newsId=$newsId'),
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

        // JSON 데이터를 모델로 변환
        return News.fromJson(data);
      } else {
        throw Exception(
            'Failed to load news detail: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load news detail: $e');
    }
  }

// 모든 뉴스를 가져오는 메서드 (NewsAllScreen에서 사용)
  Future<List<News>> fetchAllNews(String accessToken) async {
    try {
      print("Requesting all news with Access Token: $accessToken");
      print("API URL: $apiServerUrl/news/list");

      final response = await http.get(
        Uri.parse('$apiServerUrl/news/list'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

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
            'Failed to load news list: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load news list: $e');
    }
  }

  Future<String> saveScrap(String accessToken, String newsId) async {
    try {
      // 디버깅용으로 요청 정보 출력
      print("Saving scrap with Access Token: $accessToken for newsId: $newsId");
      print("API URL: $apiServerUrl/scrap?newsId=$newsId");

      final response = await http.post(
        Uri.parse('$apiServerUrl/scrap?newsId=$newsId'),
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

        // JSON 응답에서 'scrapId'를 추출하여 반환
        if (data != null && data['scrapId'] != null) {
          return data['scrapId'].toString();
        } else {
          throw Exception('Invalid response: Missing scrapId');
        }
      } else {
        throw Exception(
            'Failed to save scrap: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Failed to save scrap: $e');
      throw Exception('Failed to save scrap: $e');
    }
  }

  // 스크랩된 뉴스 불러오기 (GET 요청)
  Future<News> fetchScrap(String accessToken, String scrapId) async {
    try {
      // 디버깅용으로 요청 정보 출력
      print(
          "Fetching scrap with Access Token: $accessToken for scrapId: $scrapId");
      print("API URL: $apiServerUrl/scrap/$scrapId");

      final response = await http.get(
        Uri.parse('$apiServerUrl/scrap/$scrapId'),
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

        // JSON 데이터를 모델로 변환
        return News.fromJson(data);
      } else {
        throw Exception(
            'Failed to fetch scrap: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to fetch scrap: $e');
    }
  }

  // 스크랩 업데이트 메서드 추가
  Future<void> updateScrap(
      String accessToken, String scrapId, String content) async {
    try {
      // 디버깅용으로 요청 정보 출력
      print(
          "Updating scrap with Access Token: $accessToken for scrapId: $scrapId");
      print("API URL: $apiServerUrl/scrap");

      final response = await http.put(
        Uri.parse('$apiServerUrl/scrap'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'scrapId': scrapId,
          'content': content,
        }),
      );

      // 응답 상태 코드와 내용을 출력하여 디버깅을 돕습니다.
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update scrap: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Failed to update scrap: $e');
      throw Exception('Failed to update scrap: $e');
    }
  }

  // 스크랩된 뉴스 리스트를 불러오는 메서드
  Future<List<News>> fetchScrapList(String accessToken,
      {String sort = 'latest'}) async {
    try {
      final response = await http.get(
        Uri.parse('$apiServerUrl/scrap-list?sort=$sort'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      // 디버깅을 돕기 위해 상태 코드와 응답 내용을 출력
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        var data = jsonDecode(decodedBody);

        if (data is List) {
          // API 응답이 배열 형태라면 이를 `List<News>`로 변환하여 반환합니다.
          return data.map((item) => News.fromJson(item)).toList();
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
      } else {
        throw Exception(
            'Failed to load scrap list: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to load scrap list: $e');
    }
  }
}
