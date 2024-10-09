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
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchFavoriteStocks();
    _fetchMarketIndices();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _marketIndices.length;
      });
    });
  }

  void _refreshPage() {
    setState(() {
      _isLoadingFavStock = true;
      _isLoadingMarketIndex = true;
    });
    _fetchFavoriteStocks();
    _fetchMarketIndices();
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

  Future<void> _refreshData() async {
    setState(() {
      _isLoadingFavStock = true;
      _isLoadingMarketIndex = true;
    });
    await Future.wait([
      _fetchFavoriteStocks(),
      _fetchMarketIndices(),
    ]);
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
                      builder: (context) => MainScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 20,
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
                      builder: (context) => NotificationScreen(),
                    ),
                  );
                },
                child: Container(
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
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // SearchBarStock(),
                GestureDetector(
                  onTap: () => {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SearchPage()),
                          );
                        },
                        child: const AbsorbPointer(
                          child: SearchBarStock(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                AccountSummary(),
                const SizedBox(height: 25),
                _isLoadingMarketIndex
                    ? Center(child: CircularProgressIndicator())
                    : _marketIndices.isEmpty
                        ? Center(child: Text('No market data available'))
                        : FractionallySizedBox(
                            widthFactor: 1.14, //여기 하드코딩
                            child: MarketIndex(
                              indexData: _marketIndices[_currentIndex],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MarketIndexPage(
                                        indices: _marketIndices),
                                  ),
                                );
                              },
                            ),
                          ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 150,
                  child: _isLoadingFavStock
                      ? Center(child: CircularProgressIndicator())
                      : FavoriteStocks(
                          stocksData: _favoriteStockData,
                          onStockTap: _navigateToStockDetail,
                        ),
                ),
                const SizedBox(height: 12),
                Text('관련 뉴스',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 400,
                  child: NewsPageComponent(),
                ),
                const SizedBox(height: 12),
                Text('국내 실시간 랭킹',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 470,
                  child: StockPageComponent(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
