import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MemberApiService {
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
}
