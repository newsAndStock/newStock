import 'package:flutter/material.dart';

class NewsItem {
  final String title;
  final String source;
  final String timeAgo;
  final String imageUrl;

  NewsItem({
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.imageUrl,
  });
}

class NewsComponent extends StatelessWidget {
  final NewsItem newsItem;

  const NewsComponent({Key? key, required this.newsItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  newsItem.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(newsItem.source,
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 8),
                    Text(newsItem.timeAgo,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              newsItem.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class NewsPageComponent extends StatefulWidget {
  final double? height; // 높이를 옵션으로 받음
  const NewsPageComponent({Key? key, this.height}) : super(key: key);

  @override
  _NewsPageComponentState createState() => _NewsPageComponentState();
}

class _NewsPageComponentState extends State<NewsPageComponent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['최신뉴스', '정치', '경제', '사회', '문화', '스포츠'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NewsItem> _getNewsForCategory(String category) {
    // 테스트 데이터
    return [
      NewsItem(
        title: 'LG엔솔, 40만 원선 돌파... 2차 전지株 일제히 강세',
        source: '서울경제',
        timeAgo: '4시간 전',
        imageUrl: 'https://via.placeholder.com/60',
      ),
      NewsItem(
        title: '삼성전자, 신제품 출시 예정... 스마트폰 시장 주도권 노려',
        source: '한국경제',
        timeAgo: '2시간 전',
        imageUrl: 'https://via.placeholder.com/60',
      ),
      // 더 많은 테스트 아이템 추가...
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height, // 높이를 설정할 수 있도록 함
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: _categories.map((category) => Tab(text: category)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final news = _getNewsForCategory(category);
                return ListView.separated(
                  itemCount: news.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) =>
                      NewsComponent(newsItem: news[index]),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
