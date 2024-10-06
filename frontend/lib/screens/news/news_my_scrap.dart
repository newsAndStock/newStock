import 'package:flutter/material.dart';
import 'package:frontend/api/news_api_service.dart'; // NewsService를 가져와서 API 호출 사용
import 'package:frontend/models/news_model.dart'; // 뉴스 모델
import 'package:frontend/screens/main_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screens/news/news_main.dart';
import 'package:frontend/screens/news/news_scrap_detail.dart';

class NewsMyScrapScreen extends StatefulWidget {
  const NewsMyScrapScreen({Key? key}) : super(key: key);

  @override
  _NewsMyScrapScreenState createState() => _NewsMyScrapScreenState();
}

class _NewsMyScrapScreenState extends State<NewsMyScrapScreen> {
  final storage = FlutterSecureStorage();
  late Future<List<News>> scrapedNewsFuture;
  String sortType = 'latest'; // 기본 정렬 방식 설정

  @override
  void initState() {
    super.initState();
    scrapedNewsFuture = _loadScrapedNews(); // 스크랩된 뉴스 로드
  }

  Future<List<News>> _loadScrapedNews() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please log in.');
      }
      return await NewsService().fetchScrapList(accessToken, sort: sortType);
    } catch (e) {
      print('Failed to load scraped news: $e');
      throw e;
    }
  }

  void _setSortType(String type) {
    setState(() {
      sortType = type; // 정렬 타입 설정
      scrapedNewsFuture = _loadScrapedNews(); // 새로고침
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '스크랩한 기사',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<News>>(
            future: scrapedNewsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Failed to load scraped news: ${snapshot.error}'),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final scrapedNews = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10.0), // 버튼 위치를 고려하여 리스트 위쪽 패딩 추가
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 사용자 이름 텍스트
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 10),
                        child: const Text(
                          '띵슈롱님이 스크랩한 기사예요',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      // 정렬 버튼
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                _setSortType('latest'); // 최신순 정렬
                              },
                              child: Text(
                                '최신순',
                                style: TextStyle(
                                  color: sortType == 'latest'
                                      ? Colors.black
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _setSortType('oldest'); // 오래된순 정렬
                              },
                              child: Text(
                                '오래된순',
                                style: TextStyle(
                                  color: sortType == 'oldest'
                                      ? Colors.black
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 스크랩된 뉴스 리스트
                      Expanded(
                        child: ListView.builder(
                          itemCount: scrapedNews.length,
                          itemBuilder: (context, index) {
                            final news = scrapedNews[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 10.0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // 뉴스 스크랩 디테일 페이지로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NewsScrapDetailScreen(
                                        scrapId: news.scrapId
                                            .toString(), // 스크랩 ID 전달
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.white, // 카드 배경색을 하얀색으로 설정
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Row(
                                    children: [
                                      // 뉴스 썸네일 (왼쪽 40%)
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(40),
                                            bottomLeft: Radius.circular(40),
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(news.imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      // 뉴스 정보 (오른쪽 60%)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                news.title,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text('스크랩한 뉴스가 없습니다.'),
                );
              }
            },
          ),
          // 하단에 고정된 '뉴스 홈으로' 버튼
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 뉴스 홈으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NewsMainScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A2E6A), // 보라색 배경
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  '뉴스 홈으로',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
