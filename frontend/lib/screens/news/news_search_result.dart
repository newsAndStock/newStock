import 'package:flutter/material.dart';
import 'package:frontend/models/news_model.dart';
import 'package:frontend/api/news_api_service.dart';

class NewsSearchResultScreen extends StatefulWidget {
  final String searchTerm;

  const NewsSearchResultScreen({Key? key, required this.searchTerm})
      : super(key: key);

  @override
  _NewsSearchResultScreenState createState() => _NewsSearchResultScreenState();
}

class _NewsSearchResultScreenState extends State<NewsSearchResultScreen> {
  late Future<List<News>> futureNewsList;

  @override
  void initState() {
    super.initState();
    futureNewsList = NewsService().fetchNews(); // 뉴스 데이터 로드
  }

  // 검색어에 따라 뉴스 리스트를 필터링하는 함수
  List<News> _filterNewsBySearchTerm(List<News> allNews) {
    return allNews
        .where((news) =>
            news.title.contains(widget.searchTerm) ||
            news.content.contains(widget.searchTerm))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('뉴스 검색'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<News>>(
        future: futureNewsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 중
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // 에러 발생 시
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('검색 결과가 없습니다.'));
          } else {
            // 검색어로 필터링된 뉴스 리스트
            List<News> filteredNews = _filterNewsBySearchTerm(snapshot.data!);
            if (filteredNews.isEmpty) {
              return const Center(child: Text('검색 결과가 없습니다.'));
            }

            return ListView.builder(
              itemCount: filteredNews.length,
              itemBuilder: (context, index) {
                final news = filteredNews[index];
                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => NewsDetailScreen(
                    //                             ),
                    //   ),
                    // );
                  },
                  child: buildNewsListTile(news),
                );
              },
            );
          }
        },
      ),
    );
  }

  // 뉴스 타일 위젯
  Widget buildNewsListTile(News news) {
    // 이미지 URL 로그 출력
    print('Image URL: ${news.imageUrl}'); // 이미지 URL 확인을 위한 로그

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            // 뉴스 제목 및 정보
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
                    news.press,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: news.imageUrl.isNotEmpty
                      ? NetworkImage(news.imageUrl)
                      : const AssetImage('assets/placeholder.png')
                          as ImageProvider, // 기본 이미지
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
