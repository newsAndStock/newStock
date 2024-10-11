import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChartApi {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  // daily
  static Future<List<Map<String, dynamic>>> fetchStockData(
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
        List<dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      throw Exception('Failed to load stock data: ${e.toString()}');
    }
  }

//3month
  static Future<List<Map<String, dynamic>>> fetchThreeMonthsStockData(
      String token, String stockCode) async {
    final url =
        Uri.parse('$apiServerUrl/stocks?stockCode=$stockCode&period=day');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      throw Exception('Failed to load stock data: ${e.toString()}');
    }
  }

// year
  static Future<List<Map<String, dynamic>>> fetchYearStockData(
      String token, String stockCode) async {
    final url =
        Uri.parse('$apiServerUrl/stocks?stockCode=$stockCode&period=week');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      throw Exception('Failed to load stock data: ${e.toString()}');
    }
  }

// 5 years
  static Future<List<Map<String, dynamic>>> fetchFiveYearsStockData(
      String token, String stockCode) async {
    final url =
        Uri.parse('$apiServerUrl/stocks?stockCode=$stockCode&period=month');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse =
            jsonDecode(utf8.decode(response.bodyBytes));
        return jsonResponse.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      throw Exception('Failed to load stock data: ${e.toString()}');
    }
  }
}
