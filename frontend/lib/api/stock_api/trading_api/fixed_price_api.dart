import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FixedPriceApi {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  //지정가 매도
  static Future<Map<String, dynamic>> sellMarket({
    required String token,
    required String stockCode,
    required double bid,
    required int quantity,
    required String orderTime,
  }) async {
    final url = Uri.parse('$apiServerUrl/sell-limit');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'stockCode': stockCode,
          'bid': bid,
          'quantity': quantity,
          'orderTime': orderTime,
        }),
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('Failed to sell stock');
      }
    } catch (e) {
      throw Exception('Failed to sell stock: ${e.toString()}');
    }
  }

  // 지정가 매수
  static Future<Map<String, dynamic>> buyMarket({
    required String token,
    required String stockCode,
    required double bid,
    required int quantity,
    required String orderTime,
  }) async {
    final url = Uri.parse('$apiServerUrl/buy-market');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'stockCode': stockCode,
          'bid': bid,
          'quantity': quantity,
          'orderTime': orderTime,
        }),
      );
      if (response.statusCode == 201) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('Failed to buy stock');
      }
    } catch (e) {
      throw Exception('Failed to buy stock: ${e.toString()}');
    }
  }
}
