import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InTradingApi {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  // 매수대기 거래목록 보기
  static Future<List<dynamic>> getInBuyingStocks(String token) async {
    final url = Uri.parse('$apiServerUrl/buy-tradings');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('Failed to load buying stocks');
      }
    } catch (e) {
      throw Exception('Failed to load buying stocks: ${e.toString()}');
    }
  }

  // 매도대기 거래목록 보기
  static Future<List<dynamic>> getInSellingStocks(String token) async {
    final url = Uri.parse('$apiServerUrl/sell-tradings');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('Failed to load selling stocks');
      }
    } catch (e) {
      throw Exception('Failed to load selling stocks: ${e.toString()}');
    }
  }

  // 거래목록 삭제
  static Future<void> cancelTrading(String token, int tradingId) async {
    final url = Uri.parse('$apiServerUrl/trading');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"tradingId": tradingId}),
      );

      if (response.statusCode == 204) {
        // 204 No Content는 성공적으로 삭제되었음을 의미합니다.
        return;
      } else {
        throw Exception('Failed to cancel trading');
      }
    } catch (e) {
      throw Exception('Failed to cancel trading: ${e.toString()}');
    }
  }
}
