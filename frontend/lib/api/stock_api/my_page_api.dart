import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure storage import

class MyPageApi {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> getMyDetail() async {
    final url = Uri.parse('$apiServerUrl/member-summary');
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken == null) {
      throw Exception('No access token found');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('Failed to load stock price');
      }
    } catch (e) {
      throw Exception('Failed to load stock price: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getMyStocks() async {
    final url = Uri.parse('$apiServerUrl/stocks-held');
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken == null) {
      throw Exception('No access token found');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load top volume stocks');
      }
    } catch (e) {
      throw Exception('Failed to load top volume stocks: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getRanking() async {
    final url = Uri.parse('$apiServerUrl/rank');
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken == null) {
      throw Exception('No access token found');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data; // 여기서 바로 Map을 반환합니다.
      } else {
        throw Exception('Failed to load ranking data');
      }
    } catch (e) {
      throw Exception('Failed to load ranking data: ${e.toString()}');
    }
  }
}
