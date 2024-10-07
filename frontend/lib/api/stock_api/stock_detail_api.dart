import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StockDetailApi {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");
  final FlutterSecureStorage storage = FlutterSecureStorage();

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

  Future<Map<dynamic, dynamic>> getStockDetail(String stockCode) async {
    final url = Uri.parse('$apiServerUrl/stocks/$stockCode');

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
        Map<dynamic, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        // 임의의 응답 구조 가정
        return data;
      } else {
        throw Exception('Failed to load stock price');
      }
    } catch (e) {
      throw Exception('Failed to load stock price: ${e.toString()}');
    }
  }

  //주식 현재정보 api
  Future<CurrentStockPriceResponse> getCurrentStockPrice(
      String stockCode) async {
    final url = Uri.parse('$apiServerUrl/stocks/$stockCode/current');

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
        Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        return CurrentStockPriceResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to load current stock price');
      }
    } catch (e) {
      throw Exception('Failed to load current stock price: ${e.toString()}');
    }
  }

  // 뉴스가져오기(STOCKCODE로)
  Future<List<Map<String, dynamic>>> getStockNews(String stockCode,
      {int page = 1, int pageSize = 10}) async {
    final url = Uri.parse(
        '$apiServerUrl/stock-news-search?stockCode=$stockCode&page=$page&pageSize=$pageSize');

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
        List<dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));

        List<Map<String, dynamic>> newsList = responseData.map((news) {
          return {
            'newsId': news['newsId'],
            'category': news['category'],
            'title': news['title'],
            'date': news['date'],
            'content': news['content'],
            'press': news['press'],
            'imageUrl': news['imageUrl'],
            'keywords': List<String>.from(news['keywords'] ?? []),
          };
        }).toList();

        return newsList;
      } else {
        throw Exception('Failed to load stock news');
      }
    } catch (e) {
      throw Exception('Failed to load stock news: ${e.toString()}');
    }
  }
}

class CurrentStockPriceResponse {
  final String stckPrpr; // 주식 현재가
  final String prdyVrss; // 전일 대비
  final String prdyCtrt; // 전일 대비율
  final Map<String, String> askpMap; // 매도 호가, 잔량
  final Map<String, String> bidpMap; // 매수 호가, 잔량

  CurrentStockPriceResponse({
    required this.stckPrpr,
    required this.prdyVrss,
    required this.prdyCtrt,
    required this.askpMap,
    required this.bidpMap,
  });

  factory CurrentStockPriceResponse.fromJson(Map<String, dynamic> json) {
    return CurrentStockPriceResponse(
      stckPrpr: json['stckPrpr'],
      prdyVrss: json['prdyVrss'],
      prdyCtrt: json['prdyCtrt'],
      askpMap: Map<String, String>.from(json['askpMap']),
      bidpMap: Map<String, String>.from(json['bidpMap']),
    );
  }
}
