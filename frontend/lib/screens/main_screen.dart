import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/api/member_api_service.dart';
import 'package:frontend/models/member_model.dart';
import 'package:frontend/screens/attendance/attendance_screen.dart';
import 'package:frontend/screens/news/news_main.dart';
import 'package:frontend/screens/quiz/quiz_screen.dart';
import 'package:frontend/screens/signin_screen.dart';
import 'package:frontend/screens/stock_main/stock_main.dart';
import 'package:frontend/widgets/common/card_button.dart';
import 'package:frontend/widgets/common/image_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final storage = const FlutterSecureStorage();
  late Future<Member> memberInfoFuture;

  @override
  void initState() {
    super.initState();
    memberInfoFuture = _loadMemberInfo();
  }

  Future<Member> _loadMemberInfo() async {
    try {
      final response = await MemberApiService().memberInfo();
      if (response.statusCode == 200) {
        // 응답 본문을 UTF-8로 강제 디코딩
        final decodedResponse = utf8.decode(response.bodyBytes);
        return Member.fromJson(jsonDecode(decodedResponse));
      } else {
        throw Exception('Failed to load member info');
      }
    } catch (e) {
      throw Exception('Failed to load member info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A2E6A), // 배경색
      body: Stack(
        children: [
          // 회원 정보 섹션 (FutureBuilder 사용)
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
                return Positioned(
                  top: 80,
                  left: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '2024년 9월 13일 금요일',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        '${member.nickname}님의 자산',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${member.totalPrice}원',
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
                );
              } else {
                return const SizedBox();
              }
            },
          ),

          // 캐릭터 이미지
          Positioned(
            top: 200,
            right: -30,
            child: Image.asset(
              'assets/images/default.png',
              height: 400,
            ),
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

          // 드래그 가능한 스크롤 시트
          DraggableScrollableSheet(
            initialChildSize: 0.08,
            minChildSize: 0.08,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/images/NEWstock.png',
                          height: 20,
                        ),
                      ),
                      const SizedBox(height: 20),

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
                              builder: (context) => const NewsMainScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // 출석 챌린지 카드 (드래그 가능 영역 내)
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
                      const SizedBox(height: 20),

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
                                    builder: (context) => const SigninScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: const Color(0xFF3A2E6A),
                              padding: const EdgeInsets.symmetric(vertical: 15),
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
              );
            },
          ),
        ],
      ),
    );
  }
}
