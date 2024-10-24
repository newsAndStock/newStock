import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/data/news/mock_news_data.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/news_model.dart';

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
  Future<List<News>> fetchAllNewsByCategory(
      String accessToken, String category) async {
    try {
      print(
          "Requesting news with Access Token: $accessToken and Category: $category");
      print("API URL: $apiServerUrl/news/list?category=$category");

      final response = await http.get(
        Uri.parse('$apiServerUrl/news/list?category=$category'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // 응답 데이터를 UTF-8로 디코딩하여 처리
        String decodedBody = utf8.decode(response.bodyBytes);
        var data = jsonDecode(decodedBody);

        if (data is List) {
          return data.map((e) => News.fromJson(e)).toList();
        } else if (data is Map<String, dynamic> &&
            data.containsKey('content')) {
          // 만약 'content' 키가 있는 맵 형식으로 응답이 온다면
          return (data['content'] as List)
              .map((e) => News.fromJson(e))
              .toList();
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
    final response = await http.get(
      Uri.parse('$apiServerUrl/scrap/$scrapId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return News.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch scrap: ${response.statusCode}');
    }
  }

  // 스크랩 업데이트 메서드 추가
  Future<void> updateScrap(
      String accessToken, String scrapId, String contentJson) async {
    try {
      final response = await http.put(
        Uri.parse('$apiServerUrl/scrap'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'scrapId': scrapId,
          'content': contentJson, // Delta JSON으로 변환된 데이터를 전송
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update scrap: ${response.statusCode}');
      }
    } catch (e) {
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

  // 스크랩 삭제 함수 추가
  Future<void> deleteScrap(String accessToken, int scrapId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiServerUrl/scrap/$scrapId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // 상태 코드가 200 또는 204인 경우 삭제 성공으로 처리합니다.
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Failed to delete scrap: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to delete scrap: $e');
    }
  }

  Future<List<String>> fetchTrendingKeywords(
      String date, String accessToken) async {
    final url = Uri.parse('$apiServerUrl/popular-word?date=$date');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // UTF-8로 응답을 디코딩하여 한글 깨짐 방지
        String decodedResponse = utf8.decode(response.bodyBytes);
        List<dynamic> data = jsonDecode(decodedResponse);
        return List<String>.from(data);
      } else {
        throw Exception('Failed to load trending keywords');
      }
    } catch (e) {
      throw Exception('Failed to load trending keywords: $e');
    }
  }

  // 최근 검색어 API 함수 수정
  Future<List<Map<String, dynamic>>> fetchRecentKeywords(
      String accessToken) async {
    final url = Uri.parse('$apiServerUrl/news/recent-word');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        String decodedResponse = utf8.decode(response.bodyBytes);
        List<dynamic> data = jsonDecode(decodedResponse);

        // Map 형태로 반환 (id와 word를 포함)
        return data
            .map((item) => {'id': item['id'], 'word': item['word']})
            .toList();
      } else {
        throw Exception('Failed to load recent keywords');
      }
    } catch (e) {
      throw Exception('Failed to load recent keywords: $e');
    }
  }

  Future<List<News>> searchNews(String keyword, String accessToken) async {
    print('Searching for keyword: $keyword'); // 검색어 로그 출력

    final response = await http.get(
      Uri.parse('$apiServerUrl/news-search?keyword=$keyword'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // UTF-8로 응답을 디코딩하여 한글 깨짐 방지
      String decodedResponse = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedResponse);
      return data.map((json) => News.fromJson(json)).toList();
    } else {
      throw Exception('뉴스 검색에 실패했습니다.');
    }
  }

  // 최근검색어 삭제 메서드
  Future<void> deleteRecentKeyword(String accessToken, int id) async {
    final url = Uri.parse('$apiServerUrl/news/recent-word?id=$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 204) {
        throw Exception(
            'Failed to delete recent keyword: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Failed to delete recent keyword: $e');
      throw Exception('Failed to delete recent keyword: $e');
    }
  }
}
