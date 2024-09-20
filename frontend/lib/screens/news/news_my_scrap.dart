import 'package:flutter/material.dart';
import 'package:frontend/models/news/news_model.dart'; // 뉴스 모델
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/news/news_detail.dart'; // 뉴스 홈으로 이동하기 위한 스크린

class NewsMyScrapScreen extends StatelessWidget {
  const NewsMyScrapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 예시 데이터: 실제로는 스크랩된 데이터를 가져와야 함
    List<News> scrapedNews = [
      News(
        title: '연말 기준금리 하향 가능성...',
        date: '2024.09.20. 오후 1:48',
        content: '기사 내용...',
        press: '서울경제',
        imageUrl:
            'https://imgnews.pstatic.net/image/003/2024/09/20/NISI20240920_0020527489_web_20240920155829_20240920162217146.jpg?type=w647',
        category: '금융',
      ),
      News(
        title: 'PF 사업 약화 지속 가능성...',
        date: '2024.09.20. 오후 1:46',
        content: '기사 내용...',
        press: '서울경제',
        imageUrl:
            'https://imgnews.pstatic.net/image/003/2024/09/20/NISI20240920_0020527489_web_20240920155829_20240920162217146.jpg?type=w647',
        category: '금융',
      ),
    ];

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
      body: Column(
        children: [
          // 상단 스크랩한 기사 소개
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
                    // 최신순 클릭 시
                  },
                  child: const Text(
                    '최신순',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // 오래된순 클릭 시
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Text(
                                    news.date,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
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
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A), // 보라색 배경
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('뉴스 홈으로'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
