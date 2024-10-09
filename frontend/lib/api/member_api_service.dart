import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MemberApiService {
  final storage = const FlutterSecureStorage();
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  // 로그인
  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$apiServerUrl/login');

    final body = jsonEncode({
      'email': email,
      'password': password,
    });
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
    return response;
  }

  // 회원가입 메서드 (이메일, 닉네임, 비밀번호 정보 전송)
  Future<http.Response> signUp(
      String email, String nickName, String password) async {
    final url = Uri.parse('$apiServerUrl/sign-up');

    final body = jsonEncode({
      'email': email,
      'password': password,
      'nickname': nickName,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
    return response;
  }

  // 이메일 중복 체크
  Future<http.Response> checkEmail(String email) async {
    final url = Uri.parse('$apiServerUrl/check-email?email=$email');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  // 닉네임 중복 체크
  Future<http.Response> checkNickname(String nickname) async {
    // 명시적으로 한글을 URL 인코딩하여 전송
    final encodedNickname = Uri.encodeQueryComponent(nickname);
    final url =
        Uri.parse('$apiServerUrl/check-nickname?nickname=$encodedNickname');
    print(url);
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print(response.body);
    return response;
  }

  //토큰 재발급
  Future<void> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$apiServerUrl/refresh?refreshToken=$refreshToken'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print(jsonDecode(utf8.decode(response.bodyBytes)));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String accessToken = data['accessToken']; // 새로운 액세스 토큰 갱신
      String refreshToken = data['refreshToken'];

      await storage.write(key: 'accessToken', value: accessToken);
      await storage.write(key: 'refreshToken', value: refreshToken);
    } else {
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
      print("토큰 재발급 실패");
    }
  }

  //회원 정보
  Future<http.Response> memberInfo() async {
    String? token = await storage.read(key: 'accessToken');
    final url = Uri.parse('$apiServerUrl/member-summary');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  // 닉네임을 가져오는 함수
  Future<String> fetchNickname() async {
    final response = await memberInfo();

    if (response.statusCode == 200) {
      // UTF-8로 강제로 디코딩
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['nickname'];
    } else {
      throw Exception('Failed to load nickname');
    }
  }

  //비밀번호 재발급
  Future<http.Response> resetPassword(String email) async {
    final url = Uri.parse('$apiServerUrl/send-email?email=$email');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  // 알림 리스트
  Future<http.Response> fetchNotification() async {
    String? token = await storage.read(key: 'accessToken');
    final url = Uri.parse('$apiServerUrl/notifications');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }
}
