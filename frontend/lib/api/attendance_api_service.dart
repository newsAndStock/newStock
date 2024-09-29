import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AttendanceApiService {
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  // 출석 체크된 날짜를 가져오는 함수
  Future<List<DateTime>> getCheckedDates(String token, int month) async {
    final url = Uri.parse('$apiServerUrl/attendance?month=$month');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<DateTime> checkedDates = data.map((date) {
          return DateTime.parse(date);
        }).toList();
        return checkedDates;
      } else {
        throw Exception('Failed to load attendance dates');
      }
    } catch (e) {
      throw Exception('Failed to load attendance dates');
    }
  }

  // 포인트 추가 API 요청 (쿼리 파라미터로 전송)
  Future<void> addPoints(String token, int points) async {
    final url = Uri.parse('$apiServerUrl/attendance?point=$points');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // 응답 상태 코드와 응답 본문 출력
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to add points: ${response.body}');
      }
    } catch (e) {
      print('Error adding points: $e');
      throw Exception('Failed to add points');
    }
  }
}
