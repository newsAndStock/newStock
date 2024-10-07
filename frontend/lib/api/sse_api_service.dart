import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SseApiService {
  final storage = const FlutterSecureStorage();
  static String apiServerUrl = dotenv.get("API_SERVER_URL");
  Stream<String> subscribe() async* {
    final url = Uri.parse('$apiServerUrl/subscribe');
    final request = http.Request('GET', url);
    final client = http.Client();
    final response = await client.send(request);

    // SSE 스트림을 UTF-8로 디코딩하여 줄 단위로 처리
    final stream =
        response.stream.transform(utf8.decoder).transform(const LineSplitter());

    // 수신한 데이터를 스트림으로 반환
    await for (var data in stream) {
      yield data;
    }
  }
}
