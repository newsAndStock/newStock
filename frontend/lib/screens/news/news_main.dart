import 'package:flutter/material.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/news/news_all.dart';
import 'package:frontend/screens/news/news_detail.dart';
import 'package:frontend/screens/news/news_my_scrap.dart';
import 'package:frontend/screens/news/news_search.dart';
import 'package:frontend/screens/notification_screen.dart';
import 'package:frontend/api/news_api_service.dart';
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
  String selectedCategory = '금융'; // 기본 선택된 카테고리
  late Future<List<News>> futureNewsList; // 뉴스 리스트 저장
  List<News> filteredNewsList = []; // 카테고리별 필터링된 뉴스 리스트
  List<News> recentNewsList = []; // 최근 뉴스 리스트

  @override
  void initState() {
    super.initState();
    futureNewsList = NewsService().fetchNews(); // 뉴스 데이터 로드
    _loadInitialNews(); // 뉴스 데이터를 초기화
  }

  // 초기 데이터 로드
  void _loadInitialNews() async {
    final allNews = await NewsService().fetchNews();
    setState(() {
      // 최근 뉴스는 최신 뉴스에서 상위 4개만 가져옴
      recentNewsList = allNews.take(4).toList();
      // 기본 카테고리 뉴스 필터링
      filteredNewsList =
          allNews.where((news) => news.category == selectedCategory).toList();
    });
  }

  // 선택된 카테고리로 뉴스 필터링
  void _filterNewsByCategory(String category) async {
    final allNews = await NewsService().fetchNews();
    setState(() {
      filteredNewsList =
          allNews.where((news) => news.category == category).toList();
    });
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
                    height: 20, // Adjust this size for the logo
                    child: Image.asset(
                      'assets/images/NEWstock.png', // Ensure this is the correct path to your image
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
                    height: 30, // Adjust the size for the notification icon
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 30, // You can adjust the size of the icon
                      color: Colors.black, // Change color if necessary
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
            GestureDetector(
              onTap: () => {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.95,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NewsSearchScreen()),
                        );
                      },
                      child: const AbsorbPointer(
                        child: NewsSearchbar(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
            FutureBuilder<List<News>>(
              future: futureNewsList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator()); // 데이터 로딩 중
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}')); // 에러 발생 시
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('뉴스가 없습니다.'));
                } else {
                  return Column(
                    children: [
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
                                          title: news.title,
                                          dateTime: news.date,
                                          content: news.content,
                                          imageUrl: news.imageUrl,
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () {
                            // 스크랩 기사 클릭 시 스크랩 화면으로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NewsMyScrapScreen(), // 스크랩 화면으로 이동
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
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
                      const SizedBox(height: 20),
                      // Categories section 가로 스크롤
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
                                  '글로벌 경제',
                                  '경제 일반'
                                ],
                                selectedCategory: selectedCategory,
                                onCategorySelected: (category) {
                                  setState(() {
                                    selectedCategory = category;
                                    _filterNewsByCategory(
                                        category); // 카테고리 변경 시 필터링
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 뉴스 리스트를 감싸는 박스 (그림자 포함)
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
                                                builder: (context) =>
                                                    NewsDetailScreen(
                                                  title: news.title,
                                                  dateTime: news.date,
                                                  content: news.content,
                                                  imageUrl: news.imageUrl,
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
                  );
                }
              },
            ),
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
                    news.date,
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
                  image: NetworkImage(news.imageUrl),
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
