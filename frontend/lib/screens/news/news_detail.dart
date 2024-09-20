import 'package:flutter/material.dart';
import 'package:frontend/screens/news/news_scrap.dart';

class NewsDetailScreen extends StatelessWidget {
  final String title; // 뉴스 제목
  final String dateTime; // 뉴스 작성일시
  final String content; // 뉴스 내용
  final String imageUrl; // 이미지 URL

  const NewsDetailScreen({
    Key? key,
    required this.title,
    required this.dateTime,
    required this.content,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 상단 이미지
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.network(
              imageUrl,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          // 뒤로가기 버튼
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // DraggableScrollableSheet로 제목, 작성일시, 내용 표시
          DraggableScrollableSheet(
            initialChildSize: 0.75, // 초기 크기
            minChildSize: 0.75, // 최소 크기
            maxChildSize: 0.95, // 최대 크기
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30, // 기존보다 넉넉한 패딩 추가
                    vertical: 10, // 상하 패딩도 넉넉하게 추가
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 드래그 힌트
                      Center(
                        child: Container(
                          width: 120,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '이데일리 최정훈 기자',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        dateTime,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 구분선 추가
                      const Divider(
                        thickness: 1, // 두께 설정
                        color: Color.fromARGB(255, 201, 201, 201), // 구분선 색상
                      ),
                      const SizedBox(height: 20),
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // 하단에 고정된 스크랩하기 버튼
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewsScrapScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A2E6A), // 버튼 색상
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '스크랩하기',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
