import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InTradingApi {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");
  final FlutterSecureStorage storage = FlutterSecureStorage();

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

  Future<Map<String, int>> getDeposit() async {
    final url = Uri.parse('$apiServerUrl/deposit');

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
        Map<String, dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes));
        Map<String, int> data = Map<String, int>.from(jsonResponse);
        return data;
      } else {
        throw Exception('Failed to load buying stocks');
      }
    } catch (e) {
      throw Exception('Failed to load buying stocks: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getHoldings(String stockCode) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    final url = Uri.parse('$apiServerUrl/stocks/$stockCode/holdings');

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
        throw Exception('Failed to load selling stocks');
      }
    } catch (e) {
      throw Exception('Failed to load selling stocks: ${e.toString()}');
    }
  }

  Future<Map<String, int>> getAveragePrice(String stockCode) async {
    final url =
        Uri.parse('$apiServerUrl/member/averagePrice?stockCode=${stockCode}');

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
        Map<String, dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes));
        return Map<String, int>.from(jsonResponse);
      } else {
        throw Exception(
            'Failed to load average prices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load average prices: ${e.toString()}');
    }
  }
}
