import 'package:flutter/material.dart';
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
import 'package:frontend/screens/notification_screen.dart';

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
            MarketIndex(currentIndex: _currentIndex),
            const SizedBox(height: 25),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.9,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              StockDetailPage(stockName: '삼성전자')),
                    );
                  },
                  child: SizedBox(
                    height: 150,
                    child: FavoriteStocks(),
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
