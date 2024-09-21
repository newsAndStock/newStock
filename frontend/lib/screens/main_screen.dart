import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screens/news/news_main.dart';
import 'package:frontend/screens/signin_screen.dart';
import 'package:frontend/screens/stock_main/stock_main.dart';
import 'package:frontend/widgets/common/card_button.dart';
import 'package:frontend/widgets/common/image_button.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const secureStorage = FlutterSecureStorage();

    return Scaffold(
      backgroundColor: const Color(0xFF3A2E6A), // 배경색
      body: Stack(
        children: [
          // 상단 - 날짜, 자산 정보, 수익률
          const Positioned(
            top: 80,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2024년 9월 13일 금요일',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 30),

                // 자산 정보
                Text(
                  '띵슈롱님의 자산',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  '12,360,000원',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '수익률 0%\n랭킹 500위',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 200, // 캐릭터 이미지의 상단 위치 조정
            right: -30, // 캐릭터 이미지를 화면 오른쪽에 배치
            child: Image.asset(
              'assets/images/default.png',
              height: 400,
            ),
          ),

          // 출석 챌린지 및 퀴즈 챌린지 버튼
          Positioned(
            bottom: 120, // 버튼 위치 조정
            left: 20,
            right: 20,
            child: Column(
              children: [
                // 출석 챌린지 버튼
                ImageButton(
                  title: '출석 챌린지',
                  subscription: '룰렛 돌리고 랜덤포인트 받자!',
                  imagePath: 'assets/images/checkin.png',
                  onPressed: () {},
                ),
                const SizedBox(height: 20),

                // 퀴즈 챌린지 버튼
                ImageButton(
                  title: '퀴즈 챌린지',
                  subscription: '퀴즈 풀고 포인트 받자!',
                  imagePath: 'assets/images/quiz.png',
                  onPressed: () {},
                ),
              ],
            ),
          ),

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
                      // 드래그 힌트
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

                      // 출석 챌린지 카드
                      ImageButton(
                        title: '출석 챌린지',
                        subscription: '룰렛 돌리고 랜덤포인트 받자!',
                        imagePath: 'assets/images/checkin.png',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 20),

                      // 퀴즈 챌린지 카드
                      ImageButton(
                        title: '퀴즈 챌린지',
                        subscription: '퀴즈 풀고 포인트 받자!',
                        imagePath: 'assets/images/quiz.png',
                        onPressed: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              // await
                              await secureStorage.delete(key: "accessToken");
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
