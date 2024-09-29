import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StockDetailApi {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

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
}
