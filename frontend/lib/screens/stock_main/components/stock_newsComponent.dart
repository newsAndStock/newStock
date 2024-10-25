import 'package:flutter/material.dart';
import 'package:frontend/api/stock_api/favorite_stock_api.dart';
import 'package:frontend/api/stock_api/stock_detail_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screens/news/news_detail.dart';

class NewsItem {
  final String title;
  final String source;
  final String timeAgo;
  final String imageUrl;
  final String newsId;

  NewsItem({
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.imageUrl,
    required this.newsId,
  });
}

class Category {
  final String title;
  final String stockCode;

  Category({required this.title, required this.stockCode});
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
  final VoidCallback onRefresh;
  final Function(bool) onHasFavoriteStocksChanged;

  const NewsPageComponent({
    Key? key,
    this.height,
    required this.onRefresh,
    required this.onHasFavoriteStocksChanged,
  }) : super(key: key);

  @override
  NewsPageComponentState createState() => NewsPageComponentState();
}

class NewsPageComponentState extends State<NewsPageComponent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Category> _categories = [];
  Category? selectedCategory;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  bool _isLoading = true;
  List<NewsItem> _newsItems = [];

  @override
  void initState() {
    super.initState();
    _fetchFavoriteStocks();
  }

  Future<void> refresh() async {
    await _fetchFavoriteStocks();
    widget.onRefresh(); // 부모 위젯의 onRefresh 콜백 호출
  }

  Future<void> _fetchFavoriteStocks() async {
    try {
      String? token = await storage.read(key: 'accessToken');
      if (token == null) throw Exception('No access token found');

      final favoriteStocks = await FavoriteStockApi.getFavoriteStocks(token);

      if (favoriteStocks['stocks'] == null ||
          !(favoriteStocks['stocks'] is List)) {
        throw Exception('Invalid favorite stocks data format');
      }

      setState(() {
        _categories = (favoriteStocks['stocks'] as List)
            .map((stock) => Category(
                title: stock['name'] as String? ?? 'Unknown Stock',
                stockCode: stock['stockCode'] as String? ?? ''))
            .toList();

        if (_categories.isNotEmpty) {
          selectedCategory = _categories[0];
          _tabController =
              TabController(length: _categories.length, vsync: this);
          _fetchNewsForStock(_categories[0]);
        } else {
          print('No favorite stocks found');
        }
        _isLoading = false;
        // 여기서 관심종목 상태 변경을 부모 위젯에 알립니다.
        widget.onHasFavoriteStocksChanged(_categories.isNotEmpty);
      });
    } catch (e) {
      print('Error fetching favorite stocks: $e');
      setState(() {
        _isLoading = false;
        // 에러 발생 시에도 관심종목 상태를 업데이트합니다.
        widget.onHasFavoriteStocksChanged(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('관심종목을 불러오는데 실패했습니다: $e')),
        );
      });
    }
  }

  Future<void> _fetchNewsForStock(Category category) async {
    try {
      String? token = await storage.read(key: 'accessToken');
      if (token == null) throw Exception('No access token found');

      final news = await StockDetailApi().getStockNews(
        category.stockCode,
        page: 1,
        pageSize: 6,
      );

      setState(() {
        _newsItems = news
            .map((item) => NewsItem(
                  title: item['title'] ?? 'No Title',
                  source: item['press'] ?? 'Unknown',
                  timeAgo: item['date'] ?? 'No Date',
                  imageUrl:
                      item['imageUrl'] ?? 'https://via.placeholder.com/60',
                  newsId: item['newsId'] ?? 'No NewsId',
                ))
            .toList();
      });
    } catch (e) {
      print('Error fetching news: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('뉴스를 불러오는데 실패했습니다: $e')),
      );
    }
  }

  Widget _buildCategoryItem(Category category) {
    bool isSelected = category == selectedCategory;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
          _fetchNewsForStock(category);
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
          category.title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    double componentHeight = _categories.isEmpty ? 150 : (widget.height ?? 400);

    return SizedBox(
      height: componentHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_categories.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: _categories.map((category) {
                    return Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: _buildCategoryItem(category),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: _categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('관심종목이 없습니다.'),
                            ElevatedButton(
                              child: Text('새로고침'),
                              onPressed: _fetchFavoriteStocks,
                            ),
                          ],
                        ),
                      )
                    : (_newsItems.isEmpty
                        ? Center(child: Text('뉴스가 없습니다.'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16.0),
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: _newsItems.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewsDetailScreen(
                                      newsId: _newsItems[index].newsId,
                                    ),
                                  ),
                                );
                              },
                              child: NewsComponent(
                                newsItem: _newsItems[index],
                              ),
                            ),
                          )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
