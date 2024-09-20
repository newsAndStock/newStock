import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MemberApiService {
  static String apiServerUrl = dotenv.get("API_SEREVER_URL");

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
}
