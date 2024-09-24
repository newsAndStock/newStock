import 'dart:math';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/screens/stock_main/interactive_chart/interactive_chart.dart';
import 'stock_trading_page.dart';
import 'interactive_chart/mock_data.dart';

class StockDetailPage extends StatefulWidget {
  final String stockName;

  const StockDetailPage({Key? key, required this.stockName}) : super(key: key);

  @override
  _StockDetailPageState createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCandlesticks = true;
  String _selectedPeriod = '1일';
  final List<CandleData> _data = MockDataTesla.candles;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.stockName),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              // 즐겨찾기 기능 구현
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(children: [
            SizedBox(
              width: 50,
            ),
            _buildStockInfo(),
          ]),
          // _buildChartSection(),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10), // 라벨 좌우 여백 추가
                  child: Text(
                    '차트',
                    style: TextStyle(fontSize: 16), // 글씨 크기 증가
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10), // 라벨 좌우 여백 추가
                  child: Text(
                    '종목 정보',
                    style: TextStyle(fontSize: 16), // 글씨 크기 증가
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10), // 라벨 좌우 여백 추가
                  child: Text(
                    '관련 뉴스',
                    style: TextStyle(fontSize: 16), // 글씨 크기 증가
                  ),
                ),
              ),
              // Tab(text: '차트'),
              // Tab(text: '종목 정보'),
              // Tab(text: '관련 뉴스'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChartTab(),
                _buildStockInfoTab(),
                _buildNewsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildStockInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '74,500원',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '+300원 (0.4%)',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 300,
      child: Stack(
        children: [
          _showCandlesticks ? _buildCandlestickChart() : _buildLineChart(),
          Positioned(
            right: 16,
            bottom: 16,
            child: IconButton(
              icon: Icon(_showCandlesticks
                  ? Icons.show_chart
                  : Icons.candlestick_chart),
              onPressed: () {
                setState(() {
                  _showCandlesticks = !_showCandlesticks;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCandlestickChart() {
  //   final List<Candle> candles = List.generate(
  //     30,
  //     (index) => Candle(
  //       date: DateTime.now().subtract(Duration(days: 30 - index)),
  //       high: 75000 + (index * 100),
  //       low: 73000 + (index * 100),
  //       open: 74000 + (index * 100),
  //       close: 74500 + (index * 100),
  //       volume: 1000000 + (index * 10000),
  //     ),
  //   );

  //   return Candlesticks(
  //     candles: candles,
  //   );
  // }

  Widget _buildCandlestickChart() {
    final random = Random();
    int candleCount;
    switch (_selectedPeriod) {
      case '1일':
        candleCount = 24; // 1시간 간격으로 24개
        break;
      case '3달':
        candleCount = 90; // 1일 간격으로 90개
        break;
      case '1년':
        candleCount = 52; // 1주 간격으로 52개
        break;
      case '5년':
        candleCount = 60; // 1달 간격으로 60개
        break;
      default:
        candleCount = 30;
    }

    final List<Candle> candles = List.generate(
      candleCount,
      (index) {
        final basePrice = 70000 + random.nextInt(10000);
        final highLowDiff = random.nextInt(2000);
        final openCloseDiff = random.nextInt(1000);

        final high = basePrice + highLowDiff;
        final low = basePrice - highLowDiff;
        final open = basePrice +
            (random.nextBool() ? 1 : -1) * random.nextInt(openCloseDiff);
        final close = basePrice +
            (random.nextBool() ? 1 : -1) * random.nextInt(openCloseDiff);

        return Candle(
          date: _getDateForIndex(index),
          high: high.toDouble(),
          low: low.toDouble(),
          open: open.toDouble(),
          close: close.toDouble(),
          volume: (1000000 + random.nextInt(1000000)).toDouble(),
        );
      },
    );

    return Candlesticks(
      candles: candles,
    );
  }

  DateTime _getDateForIndex(int index) {
    switch (_selectedPeriod) {
      case '1일':
        return DateTime.now().subtract(Duration(hours: 24 - index));
      case '3달':
        return DateTime.now().subtract(Duration(days: 90 - index));
      case '1년':
        return DateTime.now().subtract(Duration(days: (52 - index) * 7));
      case '5년':
        return DateTime.now().subtract(Duration(days: (60 - index) * 30));
      default:
        return DateTime.now().subtract(Duration(days: 30 - index));
    }
  }

  Widget _buildLineChart() {
    final List<FlSpot> spots = List.generate(
      30,
      (index) => FlSpot(index.toDouble(), 74000 + (index * 100)),
    );

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
      ),
    );
  }

  Widget _buildChartTab() {
    return Column(
      children: [
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Text(
        //     '주가 추이',
        //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        //   ),
        // ),
        Expanded(
          // child: _buildChartSection(),
          child: InteractiveChart(candles: _data),
        ),
        // _buildPeriodSelector(),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 40,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['1일', '3달', '1년', '5년'].map((period) {
          bool isSelected = _selectedPeriod == period;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPeriod = period;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[50] : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                period,
                style: TextStyle(
                  color: isSelected ? Colors.blue[700] : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStockInfoTab() {
    return ListView(
      children: [
        ListTile(title: Text('시가총액'), trailing: Text('229.7900억 원')),
        ListTile(title: Text('PER'), trailing: Text('37.36')),
        ListTile(title: Text('EPS'), trailing: Text('1,993원')),
        ListTile(title: Text('52주 최고'), trailing: Text('75,800원')),
        ListTile(title: Text('52주 최저'), trailing: Text('51,300원')),
        ListTile(title: Text('거래량'), trailing: Text('9,123,456주')),
      ],
    );
  }

  Widget _buildNewsTab() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${widget.stockName} 관련 뉴스 ${index + 1}'),
          subtitle: Text(
              '뉴스 출처 | ${DateTime.now().subtract(Duration(hours: index)).toString().substring(0, 16)}'),
          leading: Icon(Icons.article),
          onTap: () {
            // 뉴스 상세 페이지로 이동
          },
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        child: Text(
          '거래하기',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockTradingPage(
                stockName: widget.stockName,
                currentPrice: 74500, // Replace with actual current price
                priceChange: 300, // Replace with actual price change
                priceChangePercentage: 0.4, // Replace with actual percentage
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3A2E6A),
          minimumSize: Size(double.infinity, 50),
        ),
      ),
    );
  }
}
