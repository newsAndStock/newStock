import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/api/news_api_service.dart';
import 'package:frontend/models/news/news_model.dart';
import 'package:frontend/screens/news/news_scrap.dart';

class NewsDetailScreen extends StatefulWidget {
  final String newsId; // 뉴스 ID

  const NewsDetailScreen({Key? key, required this.newsId}) : super(key: key);

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final storage = FlutterSecureStorage();
  late Future<News> newsDetailFuture;

  @override
  void initState() {
    super.initState();
    newsDetailFuture = _loadNewsDetail(); // 뉴스 상세 정보 로드
  }

  Future<News> _loadNewsDetail() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please log in.');
      }

      // 뉴스 상세 정보 가져오기
      return await NewsService().fetchNewsDetail(accessToken, widget.newsId);
    } catch (e) {
      print('Failed to load news detail: $e');
      throw e; // 에러 발생 시 다시 던져서 FutureBuilder가 처리하게 함
    }
  }

  Future<String> _createScrap(String newsId) async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please log in.');
      }

      // 스크랩 생성 요청
      String scrapId = await NewsService().saveScrap(accessToken, newsId);
      return scrapId; // 스크랩 ID를 반환
    } catch (e) {
      print('Failed to create scrap: $e');
      throw e; // 에러 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<News>(
        future: newsDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 중일 때
          } else if (snapshot.hasError) {
            return Center(
                child:
                    Text('Failed to load news: ${snapshot.error}')); // 에러 발생 시
          } else if (snapshot.hasData) {
            final news = snapshot.data!;
            return Stack(
              children: [
                // 상단 이미지
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.network(
                    news.imageUrl,
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
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(40)),
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
                            // 뉴스 제목
                            Text(
                              news.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // 뉴스 출처 (press)
                            Text(
                              news.press,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            // 뉴스 작성일시 (createDate)
                            Text(
                              news.createDate,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // 구분선 추가
                            const Divider(
                              thickness: 1, // 두께 설정
                              color:
                                  Color.fromARGB(255, 201, 201, 201), // 구분선 색상
                            ),
                            const SizedBox(height: 20),
                            // 뉴스 내용
                            Text(
                              news.content,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 90),
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
                    onPressed: () async {
                      try {
                        // 스크랩 생성
                        String scrapId = await _createScrap(widget.newsId);
                        // 스크랩 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsScrapScreen(
                              scrapId: scrapId,
                            ),
                          ),
                        );
                      } catch (e) {
                        print('Failed to create scrap or navigate: $e');
                        // 오류 처리 (예: 에러 다이얼로그 표시)
                      }
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
            );
          } else {
            return const Center(child: Text('뉴스 데이터를 불러올 수 없습니다.'));
          }
        },
      ),
    );
  }
}
