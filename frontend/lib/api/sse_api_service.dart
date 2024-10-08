import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/widgets/notification/notification_service.dart';
import 'package:http/http.dart' as http;

class SseApiService {
  final NotificationService _notificationService;

  final storage = const FlutterSecureStorage();
  static String apiServerUrl = dotenv.get("API_SERVER_URL");
  final DateTime _lastDataReceivedTime = DateTime.now();
  Timer? _connectionCheckTimer;

  SseApiService(this._notificationService) {
    _startConnectionCheckTimer();
  }

  void _startConnectionCheckTimer() {
    // 30초마다 연결 상태를 체크하는 타이머를 설정
    _connectionCheckTimer =
        Timer.periodic(const Duration(seconds: 30), (timer) {
      final currentTime = DateTime.now();
      final durationSinceLastData =
          currentTime.difference(_lastDataReceivedTime).inSeconds;

      if (durationSinceLastData > 30) {
        // 30초 동안 데이터가 없으면 재연결
        print("연결이 끊긴 것으로 감지됨. 재연결 시도 중...");
        startListening();
      }
    });
  }

  Stream<String> subscribe() async* {
    while (true) {
      try {
        String? accessToken = await storage.read(key: 'accessToken');
        final url = Uri.parse('$apiServerUrl/subscribe');
        final request = http.Request('GET', url);
        request.headers['Authorization'] = 'Bearer $accessToken';
        final client = http.Client();
        final response = await client.send(request);

        if (response.statusCode == 200) {
          final stream = response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter());

          await for (var data in stream) {
            print("데이터 수신: $data");
            yield data; // 데이터가 수신될 때마다 스트림에 전달
          }
        } else {
          print("연결 실패 - 상태 코드: ${response.statusCode}");
          await Future.delayed(const Duration(seconds: 5)); // 실패 시 재연결 대기
        }
      } catch (e) {
        print("Error occurred: $e. 재연결 대기 중...");
        await Future.delayed(const Duration(seconds: 5)); // 재연결 대기 시간
      }
    }
  }

  void startListening() {
    bool isFirstMessage = true;
    subscribe().listen((data) {
      if (isFirstMessage) {
        print("첫 번째 메시지: $data");
        isFirstMessage = false;
      } else if (data.startsWith('{') && data.endsWith('}')) {
        try {
          final parsedData = jsonDecode(data);
          final id = parsedData['id']?.toString() ?? '0';
          final stockName = parsedData['stockName'];
          final orderType = parsedData['orderType'];
          final price = parsedData['price'];

          String title = "주식 거래 알림";
          String body =
              "$stockName 주식이 ${orderType == 'BUY' ? '구매' : '판매'}되었습니다. 가격: $price 원";

          print("알림 생성 - 제목: $title, 내용: $body");
          _notificationService.showNotification(id, title, body);
        } catch (e) {
          print("JSON 파싱 오류: $e - 원본 데이터: $data");
        }
      }
    }, onError: (error) {
      print("SSE 에러 발생: $error. 재연결을 시도합니다.");
      startListening();
    }, onDone: () {
      print("SSE 연결이 종료되었습니다. 재연결을 시도합니다.");
      startListening();
    });
  }

  void dispose() {
    _connectionCheckTimer?.cancel();
  }
}
