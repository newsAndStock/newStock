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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
  final double? height;
  const NewsPageComponent({Key? key, this.height}) : super(key: key);

  @override
  _NewsPageComponentState createState() => _NewsPageComponentState();
}

class _NewsPageComponentState extends State<NewsPageComponent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['삼성전자', 'SK하이닉스', '유한양행', '한미약품', 'LG에너지솔'];
  String selectedCategory = '삼성전자';

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
      NewsItem(
        title: '일론머스크, 화성 진짜 갈까? 다시 한 번 X 업로드',
        source: '가짜뉴스',
        timeAgo: '2시간 전',
        imageUrl: 'https://via.placeholder.com/60',
      ),
      // 더 많은 테스트 아이템 추가...
    ];
  }

  Widget _buildCategoryItem(String category) {
    bool isSelected = category == selectedCategory;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3A2E6A) : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF3A2E6A) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: _categories.map((category) {
                  final index = _categories.indexOf(category);
                  return Row(
                    children: [
                      _buildCategoryItem(category),
                      if (index < _categories.length - 1)
                        const SizedBox(width: 10),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: _getNewsForCategory(selectedCategory).length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) => NewsComponent(
                  newsItem: _getNewsForCategory(selectedCategory)[index],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
