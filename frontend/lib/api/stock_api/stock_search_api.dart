import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StockSearchgApi {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  // Get top volume stocks
  static Future<List<Map<String, dynamic>>> getTopVolumeStocks(
      String token) async {
    final url = Uri.parse('$apiServerUrl/stock-ranking?category=topvolume');

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
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load top volume stocks');
      }
    } catch (e) {
      throw Exception('Failed to load top volume stocks: ${e.toString()}');
    }
  }

  static Future<List<Map<String, dynamic>>> searchStocks(
      String token, String keyword) async {
    final url = Uri.parse('$apiServerUrl/stock-search?keyword=$keyword');

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
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to search stocks');
      }
    } catch (e) {
      throw Exception('Failed to search stocks: ${e.toString()}');
    }
  }

  static Future<void> saveRecentKeyword(
      String token, int memberId, String keyword) async {
    final url = Uri.parse('$apiServerUrl/recent-stock-keyword');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"memberId": memberId, "keyword": keyword}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save recent keyword');
      }
    } catch (e) {
      throw Exception('Failed to save recent keyword: ${e.toString()}');
    }
  }
}
