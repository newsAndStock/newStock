import 'package:flutter/material.dart';
import 'package:frontend/api/stock_api/favorite_stock_api.dart';
import 'package:frontend/api/stock_api/market_index_api.dart';
import 'package:frontend/screens/main_screen.dart';
import 'dart:async';
import 'components/search_bar.dart';
import 'components/account_summary.dart';
import 'components/market_index.dart';
import 'components/favorite_stocks.dart';
import 'components/stock_newsComponent.dart';
import 'components/stock_ranking.dart';
import 'stock_search_page.dart';
import 'my_page.dart';
import 'stock_detail_page.dart';
import 'market_index_page.dart';
import 'package:frontend/screens/notification_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StockMainPage extends StatefulWidget {
  const StockMainPage({Key? key}) : super(key: key);

  @override
  _StockMainPageState createState() => _StockMainPageState();
}

class _StockMainPageState extends State<StockMainPage> {
  late Timer _timer;
  int _currentIndex = 0;
  Map<String, dynamic>? _favoriteStockData;
  bool _isLoadingFavStock = true;
  List<Map<String, dynamic>> _marketIndices = [];
  bool _isLoadingMarketIndex = true;
  final FlutterSecureStorage storage =
      FlutterSecureStorage(); // Secure storage instance

  @override
  void initState() {
    super.initState();
    _fetchFavoriteStocks();
    _fetchMarketIndices();
    // 5초마다 MarketIndex 위젯의 애니메이션을 트리거
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % 4; // 4개의 지수가 있다고 가정
      });
    });
  }

  Future<void> _fetchMarketIndices() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }
      final data = await MarketIndexApi.marketIndex(accessToken);
      setState(() {
        _marketIndices = data;
        _isLoadingMarketIndex = false;
      });
    } catch (e) {
      print('Error fetching market indices: $e');
      setState(() {
        _isLoadingMarketIndex = false;
      });
    }
  }

  Future<void> _fetchFavoriteStocks() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }
      final data = await FavoriteStockApi.getFavoriteStocks(accessToken);
      setState(() {
        _favoriteStockData = data;
        _isLoadingFavStock = false;
      });
    } catch (e) {
      print('Error fetching favorite stocks: $e');
      setState(() {
        _isLoadingFavStock = false;
      });
    }
  }

  void _navigateToStockDetail(String stockName, String stockCode) {
    // 빌드 프로세스 이후에 실행되도록 WidgetsBinding.instance.addPostFrameCallback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StockDetailPage(
            stockName: stockName,
            stockCode: stockCode,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
                        builder: (context) => MainScreen(), // 검색 페이지로 이동
                      ),
                    );
                  },
                  child: Container(
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
                            NotificationScreen(), // 알림 페이지로 이동
                      ),
                    );
                  },
                  child: Container(
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
            SizedBox(height: 20),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.9,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                  child: AbsorbPointer(
                    child: SearchBarStock(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.9,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyPage()),
                    );
                  },
                  child: AccountSummary(),
                ),
              ),
            ),
            const SizedBox(height: 25),
            _isLoadingMarketIndex
                ? Center(child: CircularProgressIndicator())
                : _marketIndices.isEmpty
                    ? Center(child: Text('No market data available'))
                    : MarketIndex(
                        indexData: _marketIndices[_currentIndex],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MarketIndexPage(indices: _marketIndices),
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 25),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.9,
                child: SizedBox(
                  height: 150,
                  child: _isLoadingFavStock
                      ? Center(child: CircularProgressIndicator())
                      : FavoriteStocks(
                          stocksData: _favoriteStockData,
                          onStockTap: _navigateToStockDetail,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 33),
              child: Text('관련 뉴스',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.9,
                child: SizedBox(
                  height: 400, // 원하는 높이로 조정
                  child: NewsPageComponent(),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 33),
              child: Text('국내 실시간 랭킹',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.9,
                child: SizedBox(
                  height: 400, // 원하는 높이로 조정
                  child: StockPageComponent(),
                ),
              ),
            ),

            // RecommendedNews(),
            // DomesticStocks(),
          ],
        ),
      ),
    );
  }
}
