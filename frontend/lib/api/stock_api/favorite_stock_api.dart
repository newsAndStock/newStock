import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FavoriteStockApi {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  // 관심종목 조회 api
  static Future<Map<String, dynamic>> getFavoriteStocks(String token) async {
    final url = Uri.parse('$apiServerUrl/favorite-stock');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('Failed to load favorite stocks');
      }
    } catch (e) {
      throw Exception('Failed to load favorite stocks: ${e.toString()}');
    }
  }

  // 관심종목 추가 api
  static Future<void> addFavoriteStock(String token, String stockCode) async {
    final url = Uri.parse('$apiServerUrl/favorite-stock?stockCode=$stockCode');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to add favorite stock: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to add favorite stock: ${e.toString()}');
    }
  }

  // 관심종목 삭제 api
  static Future<void> removeFavoriteStock(
      String token, String stockCode) async {
    final url = Uri.parse('$apiServerUrl/favorite-stock?stockCode=$stockCode');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to remove favorite stock: ${errorData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to remove favorite stock: ${e.toString()}');
    }
  }
}
