import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/api/news_api_service.dart';
import 'package:frontend/models/news_model.dart';
import 'package:frontend/screens/news/news_my_scrap.dart';
import 'package:frontend/screens/news/news_scrap.dart';

class NewsScrapDetailScreen extends StatefulWidget {
  final String scrapId; // 스크랩 ID

  const NewsScrapDetailScreen({Key? key, required this.scrapId})
      : super(key: key);

  @override
  _NewsScrapDetailScreenState createState() => _NewsScrapDetailScreenState();
}

class _NewsScrapDetailScreenState extends State<NewsScrapDetailScreen> {
  final storage = FlutterSecureStorage();
  late Future<News> newsDetailFuture;

  @override
  void initState() {
    super.initState();
    newsDetailFuture = _loadScrapDetail(); // 스크랩 상세 정보 로드
  }

  Future<News> _loadScrapDetail() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please log in.');
      }

      // 스크랩 상세 정보 가져오기
      return await NewsService().fetchScrap(accessToken, widget.scrapId);
    } catch (e) {
      print('Failed to load scrap detail: $e');
      throw e; // 에러 발생 시 다시 던져서 FutureBuilder가 처리하게 함
    }
  }

  Future<void> _deleteScrap() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please log in.');
      }

      int scrapId = int.parse(widget.scrapId);

      // 디버깅을 위해 로그 추가
      print("Attempting to delete scrap with ID: $scrapId");
      print("Access Token: $accessToken");

      await NewsService().deleteScrap(accessToken, scrapId);

      // 삭제 후 피드백을 주고 이전 화면으로 돌아감
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제되었습니다.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsMyScrapScreen(),
        ),
      );
    } catch (e) {
      print('Failed to delete scrap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('스크랩 삭제에 실패했습니다. 다시 시도해주세요.')),
      );
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load scrap detail: ${snapshot.error}'),
            );
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9), // 배경색에 투명도 추가
                      shape: BoxShape.circle, // 원형 설정
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.2), // 그림자 색상 및 투명도 설정
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2), // 그림자 위치
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
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
                          horizontal: 30,
                          vertical: 10,
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
                            // 구분선 추가
                            const Divider(
                              thickness: 1,
                              color: Color.fromARGB(255, 201, 201, 201),
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
                // 하단에 고정된 수정 및 삭제 버튼
                Positioned(
                  bottom: 30,
                  left: 30,
                  right: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 수정 버튼
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsScrapScreen(
                                      scrapId: widget.scrapId), // scrapId 전달
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                  255, 218, 218, 218), // 회색 배경
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              '편집',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                      ),

                      // 삭제 버튼
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _deleteScrap();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF3A2E6A), // 보라색 배경
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              '삭제',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('스크랩 데이터를 불러올 수 없습니다.'));
          }
        },
      ),
    );
  }
}
