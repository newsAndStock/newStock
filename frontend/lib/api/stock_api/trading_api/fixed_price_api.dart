import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FixedPriceApi {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  //지정가 매도
  static Future<void> sellMarket({
    required String token,
    required String stockCode,
    required int bid,
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
          'bid': bid, // double을 int로 변환
          'quantity': quantity,
          'orderTime': orderTime,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('지정가 매도 신청에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in sellMarket: $e');
      rethrow;
    }
  }

  // 지정가 매수
  static Future<void> buyMarket({
    required String token,
    required String stockCode,
    required double bid,
    required int quantity,
    required String orderTime,
  }) async {
    final url = Uri.parse('$apiServerUrl/buy-limit');

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
      if (response.statusCode != 201) {
        throw Exception('지정가 매수 신청에 실패했습니다.');
      }
    } catch (e) {
      throw Exception('지정가 매수 신청 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
