import 'package:flutter/material.dart';
import 'package:frontend/screens/news/news_detail.dart';
import 'package:frontend/widgets/common/news_category.dart';
import 'package:frontend/models/news/news_model.dart';
import 'package:frontend/services/news/news_service.dart';

class NewsAllScreen extends StatefulWidget {
  const NewsAllScreen({Key? key}) : super(key: key);

  @override
  _NewsAllScreenState createState() => _NewsAllScreenState();
}

class _NewsAllScreenState extends State<NewsAllScreen> {
  String selectedCategory = '금융'; // 기본 선택된 카테고리
  late Future<List<News>> futureNewsList; // Future 타입으로 뉴스 리스트 설정
  List<News> filteredNewsList = []; // 필터링된 뉴스 리스트

  @override
  void initState() {
    super.initState();
    futureNewsList = NewsService().fetchNews(); // 뉴스 데이터 로드
    _filterNewsByCategory(selectedCategory); // 기본 카테고리로 필터링
  }

  // 선택된 카테고리로 뉴스 필터링
  void _filterNewsByCategory(String category) async {
    final allNews = await NewsService().fetchNews();
    setState(() {
      filteredNewsList = allNews
          .where((news) => news.category == category)
          .toList(); // 카테고리별 필터링
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
                    categories: ['금융', '증권', '산업/재계', '부동산', '글로벌 경제', '경제 일반'],
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        selectedCategory = category;
                        _filterNewsByCategory(category); // 카테고리 변경 시 필터링
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
                  return ListView.builder(
                    itemCount: filteredNewsList.length,
                    itemBuilder: (context, index) {
                      final news = filteredNewsList[index];
                      return Column(
                        children: [
                          // 뉴스 항목에만 패딩 적용
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
                                      title: news.title,
                                      dateTime: news.date,
                                      content: news.content,
                                      imageUrl: news.imageUrl,
                                    ),
                                  ),
                                );
                              },
                              child: buildNewsListTile(news),
                            ),
                          ),
                          if (index != filteredNewsList.length - 1)
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.transparent, // 투명 보더
          width: 2, // 보더 두께 설정
        ),
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
                  maxLines: 2, // 제목이 두 줄을 넘지 않도록 설정
                  overflow: TextOverflow.ellipsis, // 내용이 길면 생략 표시
                ),
                const SizedBox(height: 5),
                Text(
                  news.date, // 뉴스 데이터에서 날짜 가져오기
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  news.press, // 뉴스 데이터에서 신문사 이름 가져오기
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // 오른쪽: 썸네일
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(news.imageUrl), // 뉴스 이미지 URL 사용
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
