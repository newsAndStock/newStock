import 'package:flutter/material.dart';
import 'package:frontend/screens/news/news_detail.dart';
import 'package:frontend/widgets/news/news_category.dart';
import 'package:frontend/models/news_model.dart';
import 'package:frontend/api/news_api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NewsAllScreen extends StatefulWidget {
  const NewsAllScreen({Key? key}) : super(key: key);

  @override
  _NewsAllScreenState createState() => _NewsAllScreenState();
}

class _NewsAllScreenState extends State<NewsAllScreen> {
  final storage = FlutterSecureStorage();
  String selectedCategory = '금융'; // 기본 선택된 카테고리
  late Future<List<News>> futureNewsList; // Future 타입으로 뉴스 리스트 설정

  @override
  void initState() {
    super.initState();
    _loadNewsByCategory(); // 카테고리에 맞는 뉴스 데이터 로드
  }

  // 카테고리별 뉴스를 가져오는 메서드
  void _loadNewsByCategory() {
    setState(() {
      futureNewsList = _fetchAllNewsByCategory(selectedCategory);
    });
  }

  // NewsService를 사용하여 카테고리별 뉴스 데이터를 가져오는 함수
  Future<List<News>> _fetchAllNewsByCategory(String category) async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please log in.');
      }
      return await NewsService().fetchAllNewsByCategory(accessToken, category);
    } catch (e) {
      print('Failed to load news by category: $e');
      return [];
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
          '최근 뉴스',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // 카테고리 선택 탭
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  NewsCategory(
                    categories: ['금융', '증권', '산업/재계', '부동산', '글로벌경제', '경제일반'],
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        selectedCategory = category;
                        _loadNewsByCategory(); // 카테고리 변경 시 뉴스 데이터 로드
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // 뉴스 리스트
          Expanded(
            child: FutureBuilder<List<News>>(
              future: futureNewsList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('뉴스가 없습니다.'));
                } else {
                  List<News> displayedNews = snapshot.data!;

                  return ListView.builder(
                    itemCount: displayedNews.length,
                    itemBuilder: (context, index) {
                      final news = displayedNews[index];
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 5),
                            child: GestureDetector(
                              onTap: () {
                                // 뉴스 상세 페이지로 이동
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewsDetailScreen(
                                      newsId: news.newsId,
                                    ),
                                  ),
                                );
                              },
                              child: buildNewsListTile(news),
                            ),
                          ),
                          if (index != displayedNews.length - 1)
                            Divider(
                              color: Colors.grey.shade300,
                              thickness: 0.5,
                              indent: 20, // 좌우 패딩만큼 간격 맞추기
                              endIndent: 20,
                            ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNewsListTile(News news) {
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
            Container(
              width: 120,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: news.imageUrl.isNotEmpty
                      ? NetworkImage(news.imageUrl)
                      : const AssetImage('assets/images/default-image.png')
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
