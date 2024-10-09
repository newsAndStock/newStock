import 'package:flutter/material.dart';
import 'package:frontend/api/news_api_service.dart'; // NewsService를 가져와서 API 호출 사용
import 'package:frontend/models/news_model.dart'; // 뉴스 모델
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screens/news/news_main.dart';
import 'package:frontend/screens/news/news_scrap_detail.dart';
import 'package:frontend/api/member_api_service.dart'; // MemberApiService import

class NewsMyScrapScreen extends StatefulWidget {
  const NewsMyScrapScreen({Key? key}) : super(key: key);

  @override
  _NewsMyScrapScreenState createState() => _NewsMyScrapScreenState();
}

class _NewsMyScrapScreenState extends State<NewsMyScrapScreen> {
  final storage = FlutterSecureStorage();
  late Future<List<News>> scrapedNewsFuture;
  late Future<String> nicknameFuture; // 닉네임 Future 추가
  String sortType = 'latest'; // 기본 정렬 방식 설정

  @override
  void initState() {
    super.initState();
    scrapedNewsFuture = _loadScrapedNews(); // 스크랩된 뉴스 로드
    nicknameFuture = _loadNickname(); // 닉네임 로드
  }

  // 닉네임 불러오기
  Future<String> _loadNickname() async {
    try {
      return await MemberApiService().fetchNickname(); // MemberApiService 사용
    } catch (e) {
      print('Failed to load nickname: $e');
      return '유저'; // 닉네임을 불러오지 못했을 경우 기본 닉네임 설정
    }
  }

  // 스크랩된 뉴스 불러오기
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
          FutureBuilder<String>(
            future: nicknameFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('Failed to load nickname'),
                );
              } else {
                final nickname = snapshot.data ?? '유저'; // 기본 닉네임을 '유저'로 설정
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$nickname', // 닉네임 부분
                              style: const TextStyle(
                                fontSize: 20, // 닉네임 부분 크기
                                fontWeight: FontWeight.bold, // 닉네임 부분 볼드체
                              ),
                            ),
                            TextSpan(
                              text: '님이 스크랩한 기사예요', // 나머지 텍스트
                              style: const TextStyle(
                                fontSize: 15, // 나머지 텍스트 크기
                                fontWeight: FontWeight.normal, // 나머지 텍스트는 일반체
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

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
                    Container(
                      height: 400, // 원하는 높이로 설정
                      child: FutureBuilder<List<News>>(
                        future: scrapedNewsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('뉴스를 불러오는 중 오류가 발생했습니다.'),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        // 다시 시도 (뉴스 다시 로드)
                                        scrapedNewsFuture = _loadScrapedNews();
                                      });
                                    },
                                    child: const Text('다시 시도'),
                                  ),
                                ],
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.isNotEmpty) {
                            final scrapedNews = snapshot.data!;
                            return ListView.builder(
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            height: 130,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(40),
                                                bottomLeft: Radius.circular(40),
                                              ),
                                              image: DecorationImage(
                                                image:
                                                    NetworkImage(news.imageUrl),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          // 뉴스 정보 (오른쪽 60%)
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    news.title,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                            );
                          } else {
                            return const Center(
                              child: Text('스크랩한 뉴스가 없습니다.'),
                            );
                          }
                        },
                      ),
                    ),
                  ],
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
