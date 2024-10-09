import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/api/member_api_service.dart';
import 'package:frontend/models/member_model.dart';
import 'package:frontend/screens/attendance/attendance_screen.dart';
import 'package:frontend/screens/news/news_main.dart';
import 'package:frontend/screens/quiz/quiz_screen.dart';
import 'package:frontend/screens/signin_screen.dart';
import 'package:frontend/screens/stock_main/my_page.dart';
import 'package:frontend/screens/stock_main/stock_main.dart';
import 'package:frontend/widgets/common/card_button.dart';
import 'package:frontend/widgets/common/image_button.dart';
import 'package:frontend/widgets/notification/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final storage = const FlutterSecureStorage();
  late Future<Member> memberInfoFuture;
  static String apiServerUrl = dotenv.get("API_SERVER_URL");
  final NotificationService _notificationService = NotificationService();
  String sseData = "데이터가 없습니다";

  @override
  void initState() {
    super.initState();
    memberInfoFuture = _loadMemberInfo();
    requestNotificationPermission();
    startSseConnection();
    _notificationService.initialize();
  }

  void startSseConnection() async {
    String? accessToken = await storage.read(key: 'accessToken');
    final url = Uri.parse('$apiServerUrl/subscribe');

    SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: '$apiServerUrl/subscribe',
      header: {
        "Cookie": 'jwt=$accessToken',
        "Accept": "text/event-stream",
        "Cache-Control": "no-cache",
        "Authorization": "Bearer $accessToken",
      },
    ).listen((event) {
      setState(() {
        sseData = event.data ?? "수신된 데이터가 없습니다";
      });

      try {
        if (_isJson(event.data)) {
          final parsedData = jsonDecode(event.data ?? '{}');
          final stockName = parsedData['stockName'];
          final orderType = parsedData['orderType'];
          final price = parsedData['price'];
          String message =
              "$stockName 주식이 ${orderType == 'BUY' ? '구매' : '판매'}되었습니다. 가격: $price 원";
          _notificationService.showNotification('0', '주식 알림', message);
        }
      } catch (e) {
        print("JSON 파싱 오류: $e");
      }
    }, onDone: () {
      print("SSE 연결이 종료되었습니다.");
    }, onError: (error) {
      print("SSE 오류 발생: $error");
    });
  }

  bool _isJson(String? data) {
    if (data == null) return false;
    try {
      jsonDecode(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    SSEClient.unsubscribeFromSSE();
    super.dispose();
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<Member> _loadMemberInfo() async {
    try {
      final response = await MemberApiService().memberInfo();
      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        return Member.fromJson(jsonDecode(decodedResponse));
      } else {
        throw Exception('Failed to load member info');
      }
    } catch (e) {
      throw Exception('Failed to load member info: $e');
    }
  }

  // 날짜 포맷 메서드
  String _getFormattedDate() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('y년 M월 d일 EEEE', 'ko');
    return formatter.format(now);
  }

  // 금액 포맷 메서드
  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'ko');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A2E6A),
      body: Stack(
        children: [
          FutureBuilder<Member>(
            future: memberInfoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Positioned(
                  top: 80,
                  left: 30,
                  child: Text(
                    'Failed to load member info',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              } else if (snapshot.hasData) {
                final member = snapshot.data!;
                // 이미지 결정 로직
                String assetImage;
                double roiValue =
                    double.tryParse(member.roi) ?? 0; // 문자열을 숫자로 변환, 실패 시 0

                if (roiValue > 0) {
                  assetImage = 'assets/images/up.png';
                } else if (roiValue < 0) {
                  assetImage = 'assets/images/down.png';
                } else {
                  assetImage = 'assets/images/default.png';
                }

                return Stack(
                  children: [
                    Positioned(
                      top: 80,
                      left: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getFormattedDate(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 30),
                          GestureDetector(
                            onTap: () {
                              // 페이지 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyPage(),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${member.nickname}님의 자산',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_formatCurrency(member.totalPrice)}원',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '수익률 ${member.roi}%\n랭킹 ${member.rank}위',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 이미지 표시
                    Positioned(
                      top: 200,
                      right: -30,
                      child: Image.asset(
                        assetImage,
                        height: 400,
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox();
              }
            },
          ),

          // 출석 챌린지 및 퀴즈 챌린지 버튼 (메인 화면)
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Column(
              children: [
                ImageButton(
                  title: '출석 챌린지',
                  subscription: '룰렛 돌리고 랜덤포인트 받자!',
                  imagePath: 'assets/images/checkin.png',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ImageButton(
                  title: '퀴즈 챌린지',
                  subscription: '퀴즈 풀고 포인트 받자!',
                  imagePath: 'assets/images/quiz.png',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.08,
            minChildSize: 0.08,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Stack(
                children: [
                  // 스크롤 가능한 컨텐츠
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(40)),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 50), // 힌트와 로고 아래 공간 확보
                            // 주식 모의투자 카드
                            CardButton(
                              description: '뉴스톡에서 쉽고 안전하게',
                              title: '주식 모의투자',
                              imagePath: 'assets/images/stock.png',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StockMainPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            // 경제신문 읽기 카드
                            CardButton(
                              description: '뉴스톡과 함께하는',
                              title: '경제신문 읽기',
                              imagePath: 'assets/images/news.png',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NewsMainScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            ImageButton(
                              title: '출석 챌린지',
                              subscription: '룰렛 돌리고 랜덤포인트 받자!',
                              imagePath: 'assets/images/checkin.png',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AttendanceScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            // 퀴즈 챌린지 카드 (드래그 가능 영역 내)
                            ImageButton(
                              title: '퀴즈 챌린지',
                              subscription: '퀴즈 풀고 포인트 받자!',
                              imagePath: 'assets/images/quiz.png',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const QuizScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            // 로그아웃 버튼
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await storage.delete(key: "accessToken");
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SigninScreen()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    backgroundColor: const Color(0xFF3A2E6A),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                  ),
                                  child: const Text("로그아웃",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 드래그 힌트 (회색 바)와 뉴스톡 로고는 상단에 고정
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 120,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Image.asset(
                              'assets/images/NEWstock.png',
                              height: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
