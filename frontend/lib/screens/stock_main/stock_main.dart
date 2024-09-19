import 'package:flutter/material.dart';
import 'dart:async';
import 'components/search_bar.dart';
import 'components/account_summary.dart';
import 'components/market_index.dart';
import 'components/favorite_stocks.dart';
import 'components/stock_news.dart';
import 'components/domestic_stocks.dart';
import 'stock_search_page.dart';
import 'my_page.dart';
import 'stock_detail_page.dart';

class StockMainPage extends StatefulWidget {
  const StockMainPage({Key? key}) : super(key: key);

  @override
  _StockMainPageState createState() => _StockMainPageState();
}

class _StockMainPageState extends State<StockMainPage> {
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 5초마다 MarketIndex 위젯의 애니메이션을 트리거
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % 4; // 4개의 지수가 있다고 가정
      });
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
      appBar: AppBar(title: Text('Stock Main Page')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
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
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPage()),
                );
              },
              child: AccountSummary(),
            ),
            const SizedBox(height: 12),
            MarketIndex(currentIndex: _currentIndex),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StockDetailPage(stockName: '삼성전자')),
                );
              },
              child: SizedBox(
                height: 150,
                child: FavoriteStocks(),
              ),
            ),
            const SizedBox(height: 12),
            // SizedBox(height: 300, child: RecommendedNews())

            // RecommendedNews(),
            // DomesticStocks(),
          ],
        ),
      ),
    );
  }
}
