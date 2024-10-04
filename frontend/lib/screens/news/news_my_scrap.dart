import 'package:flutter/material.dart';
import 'package:frontend/api/news_api_service.dart'; // NewsService를 가져와서 API 호출 사용
import 'package:frontend/models/news/news_model.dart'; // 뉴스 모델
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/news/news_detail.dart'; // 뉴스 상세 페이지로 이동하기 위한 스크린
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NewsMyScrapScreen extends StatefulWidget {
  const NewsMyScrapScreen({Key? key}) : super(key: key);

  @override
  _NewsMyScrapScreenState createState() => _NewsMyScrapScreenState();
}

class _NewsMyScrapScreenState extends State<NewsMyScrapScreen> {
  final storage = FlutterSecureStorage();
  late Future<List<News>> scrapedNewsFuture;

  @override
  void initState() {
    super.initState();
    scrapedNewsFuture = _loadScrapedNews(); // 스크랩된 뉴스 로드
  }

  Future<List<News>> _loadScrapedNews() async {
    try {
      // 액세스 토큰 가져오기
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please log in.');
      }

      // 스크랩 리스트를 가져오기
      return await NewsService().fetchScrapList(accessToken, sort: 'latest');
    } catch (e) {
      print('Failed to load scraped news: $e');
      throw e; // 오류 발생 시 다시 던져서 FutureBuilder가 처리하게 함
    }
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
      body: FutureBuilder<List<News>>(
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
            return Column(
              children: [
                // 상단 스크랩한 기사 소개
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Row(
                    children: const [
                      Text(
                        '띵슈롱',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('님이 스크랩한 기사예요'),
                    ],
                  ),
                ),
                // 정렬 방식 (최신순, 오래된순)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            scrapedNewsFuture = _loadScrapedNews();
                          });
                        },
                        child: const Text(
                          '최신순',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // 오래된순 정렬 (여기선 실제 구현을 위해 매개변수를 변경할 수 있습니다.)
                        },
                        child: const Text(
                          '오래된순',
                          style: TextStyle(color: Colors.grey),
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
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10.0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                // 뉴스 상세 페이지로 이동
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => NewsDetailScreen(),
                                //   ),
                                // );
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 뉴스 썸네일
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(news.imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // 뉴스 제목 및 날짜
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          news.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        // Text(
                                        //   news.dateTime,
                                        //   style: const TextStyle(
                                        //     fontSize: 12,
                                        //     color: Colors.grey,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (index != scrapedNews.length - 1)
                            const Divider(
                              thickness: 0.5,
                              indent: 20,
                              endIndent: 20,
                              color: Colors.grey,
                            ),
                        ],
                      );
                    },
                  ),
                ),
                // 하단 버튼
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 뉴스 홈으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A), // 보라색 배경
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        '뉴스 홈으로',
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text('스크랩한 뉴스가 없습니다.'),
            );
          }
        },
      ),
    );
  }
}
