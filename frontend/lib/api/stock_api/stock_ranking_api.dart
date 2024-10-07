import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StockRankingApi {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  Future<List<Map<String, dynamic>>> getStockRanking(String category) async {
    final url = Uri.parse('$apiServerUrl/stock-ranking?category=$category');
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
        List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonData
            .map((item) => {
                  'stockName': item['stockName'] as String,
                  'stockCode': item['stockCode'] as String,
                  'currentPrice': item['currentPrice'] as String,
                  'priceChangeRate': item['priceChangeRate'] as String,
                  'priceChangeAmount': item['priceChangeAmount'] as String,
                  'priceChangeSign': item['priceChangeSign'] as String,
                })
            .toList();
      } else {
        throw Exception('Failed to load stock ranking data');
      }
    } catch (e) {
      throw Exception('Failed to load stock ranking data: ${e.toString()}');
    }
  }
}
