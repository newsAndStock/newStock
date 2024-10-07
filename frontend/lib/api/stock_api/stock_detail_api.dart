import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StockDetailApi {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> getStockPrice(
      String token, String stockCode) async {
    final url = Uri.parse('$apiServerUrl/stocks/daily?stockCode=$stockCode');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        // 임의의 응답 구조 가정
        return {
          'price': data['price'] ?? '0',
          'change': data['change'] ?? '0%',
        };
      } else {
        throw Exception('Failed to load stock price');
      }
    } catch (e) {
      throw Exception('Failed to load stock price: ${e.toString()}');
    }
  }

  Future<Map<dynamic, dynamic>> getStockDetail(String stockCode) async {
    final url = Uri.parse('$apiServerUrl/stocks/$stockCode');

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
        Map<dynamic, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        // 임의의 응답 구조 가정
        return data;
      } else {
        throw Exception('Failed to load stock price');
      }
    } catch (e) {
      throw Exception('Failed to load stock price: ${e.toString()}');
    }
  }
}
