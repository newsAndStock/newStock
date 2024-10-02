import 'dart:math';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/screens/stock_main/interactive_chart/interactive_chart.dart';
import 'package:frontend/api/stock_api/favorite_stock_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'stock_trading_page.dart';
import 'interactive_chart/mock_data.dart';

class StockData {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  StockData(this.date, this.open, this.high, this.low, this.close, this.volume);
}

class StockDetailPage extends StatefulWidget {
  final String stockName;
  final String stockCode;

  const StockDetailPage(
      {Key? key, required this.stockName, required this.stockCode})
      : super(key: key);

  @override
  _StockDetailPageState createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCandlesticks = true;
  bool _showLineChart = true;
  String _selectedPeriod = '1일';
  final List<CandleData> _data = MockDataTesla.candles;

  bool _isFavorite = false;
  bool _isLoading = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _showLineChart = true;
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    setState(() => _isLoading = true);
    try {
      String? token = await _storage.read(key: 'accessToken');
      if (token == null) throw Exception('No access token found');

      final favoriteStocks = await FavoriteStockApi.getFavoriteStocks(token);
      setState(() => _isFavorite = favoriteStocks['stocks']
          .any((stock) => stock['stockCode'] == widget.stockCode));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load favorite status: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isLoading = true);
    try {
      String? token = await _storage.read(key: 'accessToken');
      if (token == null) throw Exception('No access token found');

      if (_isFavorite) {
        await FavoriteStockApi.removeFavoriteStock(token, widget.stockCode);
      } else {
        await FavoriteStockApi.addFavoriteStock(token, widget.stockCode);
      }
      setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update favorite status: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
            icon: _isLoading
                ? CircularProgressIndicator()
                : Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _isLoading ? null : _toggleFavorite,
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

  List<StockData> generateMockStockData() {
    final random = Random();
    final List<StockData> stockData = [];
    DateTime currentDate = DateTime.now().subtract(Duration(days: 30));
    double lastClose = 100.0;

    for (int i = 0; i < 30; i++) {
      final change = (random.nextDouble() - 0.5) * 5;
      final open = lastClose;
      final close = (open + change).clamp(80.0, 120.0);
      final high = max(open, close) + random.nextDouble() * 2;
      final low = min(open, close) - random.nextDouble() * 2;
      final volume = random.nextInt(10000) + 5000;

      stockData.add(StockData(
        currentDate,
        open,
        high,
        low,
        close,
        volume,
      ));

      lastClose = close;
      currentDate = currentDate.add(Duration(days: 1));
    }

    return stockData;
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

  // Widget _buildLineChart() {
  //   final List<FlSpot> spots = List.generate(
  //     30,
  //     (index) => FlSpot(index.toDouble(), 74000 + (index * 100)),
  //   );

  //   return LineChart(
  //     LineChartData(
  //       lineBarsData: [
  //         LineChartBarData(
  //           spots: spots,
  //           isCurved: true,
  //           color: Colors.blue,
  //           barWidth: 2,
  //           dotData: FlDotData(show: false),
  //         ),
  //       ],
  //       titlesData: FlTitlesData(show: false),
  //       borderData: FlBorderData(show: false),
  //       gridData: FlGridData(show: false),
  //     ),
  //   );
  // }

  Widget _buildLineChart() {
    final List<StockData> stockData = generateMockStockData();

    final List<FlSpot> spots = stockData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.close);
    }).toList();

    // 최고가와 최저가 찾기
    double maxPrice = spots.map((spot) => spot.y).reduce(max);
    double minPrice = spots.map((spot) => spot.y).reduce(min);
    int maxIndex = spots.indexWhere((spot) => spot.y == maxPrice);
    int minIndex = spots.indexWhere((spot) => spot.y == minPrice);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '삼성전자',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: PointPainter(
                  maxIndex: maxIndex,
                  minIndex: minIndex,
                  maxPrice: maxPrice,
                  minPrice: minPrice,
                  spots: spots,
                  minX: 0,
                  maxX: spots.length.toDouble() - 1,
                  minY: minPrice * 0.95,
                  maxY: maxPrice * 1.05,
                ),
              ),
              LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      // tooltipBgColor: Colors.blueAccent,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          return LineTooltipItem(
                            '${stockData[flSpot.x.toInt()].date.day}/${stockData[flSpot.x.toInt()].date.month}\n${flSpot.y.toStringAsFixed(2)}',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                    getTouchedSpotIndicator:
                        (LineChartBarData barData, List<int> spotIndexes) {
                      return spotIndexes.map((spotIndex) {
                        return TouchedSpotIndicatorData(
                          FlLine(
                            color: Colors.orange, // 세로선 색상
                            strokeWidth: 2, // 세로선 두께
                            dashArray: [5, 5], // 점선 패턴 (5픽셀 선, 5픽셀 간격)
                          ),
                          FlDotData(
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 8,
                                color: Colors.deepOrange,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                        );
                      }).toList();
                    },
                  ),
                  extraLinesData: ExtraLinesData(
                    extraLinesOnTop: true,
                    horizontalLines: [],
                  ),
                  minX: 0,
                  maxX: spots.length.toDouble() - 1,
                  minY: minPrice * 0.95, // 그래프 하단에 여유 공간을 주기 위해
                  maxY: maxPrice * 1.05, // 그래프 상단에 여유 공간을 주기 위해
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildChartTab() {
  //   return Column(
  //     children: [
  //       // Padding(
  //       //   padding: const EdgeInsets.all(16.0),
  //       //   child: Text(
  //       //     '주가 추이',
  //       //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //       //   ),
  //       // ),
  //       Expanded(
  //         // child: _buildChartSection(),
  //         // child: InteractiveChart(candles: _data),
  //         child: _buildLineChart(),
  //       ),
  //       // _buildPeriodSelector(),
  //     ],
  //   );
  // }

  Widget _buildChartTab() {
    return Column(
      children: [
        Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: Text('라인 차트'),
                onPressed: () {
                  setState(() {
                    _showLineChart = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showLineChart ? Colors.blue : Colors.grey,
                ),
              ),
              ElevatedButton(
                child: Text('캔들스틱 차트'),
                onPressed: () {
                  setState(() {
                    _showLineChart = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_showLineChart ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _showLineChart
              ? _buildLineChart()
              : InteractiveChart(candles: _data),
        ),
        _buildPeriodSelector(),
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
                stockCode: widget.stockCode,
                currentPrice: 74500, // Replace with actual current price
                priceChange: 300, // Replace with actual price change
                priceChangePercentage: 0.4, // Replace with actual percentage
                totalHoldingQuantity: 30, //일단 임의의 숫자를 넣어놨음 api연결해서 수정해야함
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

class PointPainter extends CustomPainter {
  final int maxIndex;
  final int minIndex;
  final double maxPrice;
  final double minPrice;
  final List<FlSpot> spots;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  PointPainter({
    required this.maxIndex,
    required this.minIndex,
    required this.maxPrice,
    required this.minPrice,
    required this.spots,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    void drawPoint(int index, double price, String label) {
      final x = (index - minX) / (maxX - minX) * size.width;
      final y = size.height - ((price - minY) / (maxY - minY) * size.height);

      canvas.drawCircle(Offset(x, y), 4, paint);

      textPainter.text = TextSpan(
        text: '$label: ${price.toStringAsFixed(0)}',
        style: TextStyle(color: Colors.blue, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 20));
    }

    void drawPointBelow(int index, double price, String label) {
      final x = (index - minX) / (maxX - minX) * size.width;
      final y = size.height - ((price - minY) / (maxY - minY) * size.height);

      canvas.drawCircle(Offset(x, y), 4, paint);

      textPainter.text = TextSpan(
        text: '$label: ${price.toStringAsFixed(0)}',
        style: TextStyle(color: Colors.blue, fontSize: 10),
      );
      textPainter.layout();

      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y + 8));
    }

    drawPoint(maxIndex, maxPrice, '최고가');
    drawPointBelow(minIndex, minPrice, '최저가');
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
