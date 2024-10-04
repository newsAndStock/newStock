import 'package:flutter/material.dart';
import 'package:frontend/api/news_api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/news/news_all.dart';
import 'package:frontend/screens/news/news_detail.dart';
import 'package:frontend/screens/news/news_my_scrap.dart';
import 'package:frontend/screens/notification_screen.dart';
import 'package:frontend/widgets/news/news_category.dart';
import 'package:frontend/widgets/news/news_card.dart';
import 'package:frontend/models/news/news_model.dart';
import 'package:frontend/widgets/news/news_searchbar.dart';

class NewsMainScreen extends StatefulWidget {
  const NewsMainScreen({super.key});

  @override
  _NewsMainScreenState createState() => _NewsMainScreenState();
}

class _NewsMainScreenState extends State<NewsMainScreen> {
  final storage = FlutterSecureStorage();
  String selectedCategory = '금융'; // 기본 선택된 카테고리
  List<News> filteredNewsList = []; // 카테고리별 필터링된 뉴스 리스트
  List<News> recentNewsList = []; // 최근 뉴스 리스트

  @override
  void initState() {
    super.initState();
    _loadInitialNews();
    _loadRecentNews();
  }

  // 초기 데이터 로드 (전체 뉴스)
  Future<void> _loadInitialNews() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please log in.');
      }

      final allNews = await NewsService()
          .fetchNewsByCategory(accessToken, selectedCategory);
      setState(() {
        // 기본 카테고리 뉴스 필터링
        filteredNewsList = allNews.take(5).toList(); // 기본 카테고리 뉴스에서 상위 5개만 가져옴
      });
    } catch (e) {
      print('Failed to load initial news: $e');
    }
  }

  // 최근 뉴스 데이터 로드
  Future<void> _loadRecentNews() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please log in.');
      }

      final recentNews = await NewsService().fetchRecentNews(accessToken);
      setState(() {
        recentNewsList = recentNews.toList();
      });
    } catch (e) {
      print('Failed to load recent news: $e');
    }
  }

  // 선택된 카테고리로 뉴스 필터링
  Future<void> _filterNewsByCategory(String category) async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please log in.');
      }

      final allNews =
          await NewsService().fetchNewsByCategory(accessToken, category);
      setState(() {
        selectedCategory = category;
        filteredNewsList = allNews.toList();
      });
    } catch (e) {
      print('Failed to filter news by category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(), // 검색 페이지로 이동
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 20, // 로고 사이즈 조정
                    child: Image.asset(
                      'assets/images/NEWstock.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NotificationScreen(), // 알림 페이지로 이동
                      ),
                    );
                  },
                  child: const SizedBox(
                    height: 30,
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색 창
            GestureDetector(
              onTap: () => {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.95,
                    child: GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const NewsSearchScreen()),
                        // );
                      },
                      child: const AbsorbPointer(
                        child: NewsSearchbar(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 최근 뉴스와 전체보기 버튼을 한 줄에 배치
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '최근 뉴스',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 전체보기 클릭 시 페이지 이동 처리
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewsAllScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '전체보기 >',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 최근 뉴스 섹션
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recentNewsList.length,
                itemBuilder: (context, index) {
                  final news = recentNewsList[index];
                  return Row(
                    children: [
                      NewsCard(
                        imageUrl: news.imageUrl,
                        title: news.title,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailScreen(
                                newsId: news.newsId, // 뉴스 ID를 전달
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewsMyScrapScreen(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '스크랩 기사 바로가기',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 카테고리 섹션
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    NewsCategory(
                      categories: const [
                        '금융',
                        '증권',
                        '산업/재계',
                        '부동산',
                        '글로벌경제',
                        '경제일반'
                      ],
                      selectedCategory: selectedCategory,
                      onCategorySelected: (category) {
                        _filterNewsByCategory(category); // 카테고리 변경 시 필터링
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 카테고리별 뉴스 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredNewsList.length,
                      itemBuilder: (context, index) {
                        final news = filteredNewsList[index];
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewsDetailScreen(
                                        newsId: news.newsId, // 뉴스 ID를 전달
                                      ),
                                    ),
                                  );
                                },
                                child: buildNewsListTile(news, index),
                              ),
                            ),
                            if (index != filteredNewsList.length - 1)
                              Divider(
                                color: Colors.grey.shade300,
                                thickness: 0.5,
                                indent: 20,
                                endIndent: 20,
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildNewsListTile(News news, int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 왼쪽: 제목과 작성일자
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    news.createDate,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    news.press,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // 오른쪽: 썸네일
            Container(
              width: 120,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: news.imageUrl.isNotEmpty
                      ? NetworkImage(news.imageUrl)
                      : AssetImage('assets/images/default-image.png')
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
