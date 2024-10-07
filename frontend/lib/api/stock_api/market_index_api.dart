import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MarketIndexApi {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  static Future<List<Map<String, dynamic>>> marketIndex(String token) async {
    final url = Uri.parse('$apiServerUrl/market-data');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load market data');
      }
    } catch (e) {
      throw Exception('Failed to load market data: ${e.toString()}');
    }
  }
}
