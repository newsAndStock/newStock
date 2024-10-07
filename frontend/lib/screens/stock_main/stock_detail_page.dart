import 'dart:math';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/api/stock_api/chart_api.dart';
import 'package:frontend/api/stock_api/stock_detail_api.dart';
import 'package:frontend/screens/stock_main/interactive_chart/interactive_chart.dart';
import 'package:frontend/api/stock_api/favorite_stock_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'stock_trading_page.dart';
import 'interactive_chart/mock_data.dart';
import 'interactive_chart/src/candle_data.dart';

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
  List<Map<String, dynamic>>? _stockData;
  List<Map<String, dynamic>>? _daystockData;
  List<Map<String, dynamic>>? _weekstockData;
  List<Map<String, dynamic>>? _monthstockData;

  bool _isFavorite = false;
  bool _isLoading = false;
  bool _isLoadingday = false;
  bool _isLoadingweek = false;
  bool _isLoadingmonth = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  late Map<dynamic, dynamic> details;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _showLineChart = true;
    _checkFavoriteStatus();
    _fetchStockData();
    _fetchThreeMonthsStockData();
    _fetchYearStockData();
    _fetchFiveYearsStockData();
    details = {};
    _fetchStockDetail();
  }

  Future<void> _fetchStockDetail() async {
    setState(() => _isLoading = true);
    try {
      String? token = await _storage.read(key: 'accessToken');
      if (token == null) throw Exception('No access token found');

      final data = await StockDetailApi().getStockDetail(widget.stockCode);
      setState(() {
        details = data;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stock data: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStockData() async {
    setState(() => _isLoading = true);
    try {
      String? token = await _storage.read(key: 'accessToken');
      if (token == null) throw Exception('No access token found');

      final data = await ChartApi.fetchStockData(token, widget.stockCode);
      setState(() {
        _stockData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stock data: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchThreeMonthsStockData() async {
    setState(() => _isLoadingday = true);
    try {
      String? token = await _storage.read(key: 'accessToken');
      if (token == null) throw Exception('No access token found');

      final data =
          await ChartApi.fetchThreeMonthsStockData(token, widget.stockCode);
      setState(() {
        _daystockData = data;
        _isLoadingday = false;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stock data: ${e.toString()}')),
      );
      setState(() => _isLoadingday = false);
    }
  }

  Future<void> _fetchYearStockData() async {
    setState(() => _isLoadingweek = true);
    try {
      String? token = await _storage.read(key: 'accessToken');
      if (token == null) throw Exception('No access token found');

      final data = await ChartApi.fetchYearStockData(token, widget.stockCode);
      setState(() {
        _weekstockData = data;
        _isLoadingweek = false;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stock data: ${e.toString()}')),
      );
      setState(() => _isLoadingweek = false);
    }
  }

  Future<void> _fetchFiveYearsStockData() async {
    setState(() => _isLoadingmonth = true);
    try {
      String? token = await _storage.read(key: 'accessToken');
      if (token == null) throw Exception('No access token found');

      final data =
          await ChartApi.fetchFiveYearsStockData(token, widget.stockCode);
      setState(() {
        _monthstockData = data;
        _isLoadingmonth = false;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stock data: ${e.toString()}')),
      );
      setState(() => _isLoadingmonth = false);
    }
  }

  List<CandleData> _convertToCandleData(List<Map<String, dynamic>> data) {
    var result = data.map((item) {
      final dateTime = DateTime.parse(item['date'] as String);
      return CandleData(
        dateTime: dateTime,
        open: _parseDouble(item['openingPrice']),
        high: _parseDouble(item['highestPrice']),
        low: _parseDouble(item['lowestPrice']),
        close: _parseDouble(item['closingPrice']),
        volume: _parseDouble(item['volume']),
      );
    }).toList();
    print('Converted CandleData length: ${result.length}');
    return result;
  }

  double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.parse(value);
    }
    throw FormatException('Cannot parse $value to double');
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

  TouchedSpot? touchedSpot;

  Widget _buildLineChart() {
    final selectedData = _getSelectedData();
    if (selectedData == null || selectedData.isEmpty) {
      return Center(child: Text('데이터를 불러오는 데 실패했습니다. 다시 시도해 주세요.'));
    }

    final List<FlSpot> spots = selectedData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(),
          double.parse(entry.value['closingPrice'].toString()));
    }).toList();

    double maxPrice = spots.map((spot) => spot.y).reduce(max);
    double minPrice = spots.map((spot) => spot.y).reduce(min);
    int maxIndex = spots.indexWhere((spot) => spot.y == maxPrice);
    int minIndex = spots.indexWhere((spot) => spot.y == minPrice);

    return Stack(
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
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final flSpot = barSpot;
                    final date =
                        DateTime.parse(selectedData[flSpot.x.toInt()]['date']);
                    return LineTooltipItem(
                      '${date.day}/${date.month}\n${flSpot.y.toStringAsFixed(2)}',
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
                      color: Colors.orange,
                      strokeWidth: 2,
                      dashArray: [5, 5],
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
            minX: 0,
            maxX: spots.length.toDouble() - 1,
            minY: minPrice * 0.95,
            maxY: maxPrice * 1.05,
          ),
        ),
        // CustomPaint(
        //   size: Size.infinite,
        //   painter: PointPainter(
        //     maxIndex: maxIndex,
        //     minIndex: minIndex,
        //     maxPrice: maxPrice,
        //     minPrice: minPrice,
        //     spots: spots,
        //     minX: 0,
        //     maxX: spots.length.toDouble() - 1,
        //     minY: minPrice * 0.95,
        //     maxY: maxPrice * 1.05,
        //   ),
        // ),
      ],
    );
  }

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
          child: _isLoading ||
                  _isLoadingday ||
                  _isLoadingweek ||
                  _isLoadingmonth
              ? Center(child: CircularProgressIndicator())
              : _showLineChart
                  ? _buildLineChart()
                  : _getSelectedData() != null &&
                          _getSelectedData()!.length >= 3
                      ? InteractiveChart(
                          candles: _convertToCandleData(_getSelectedData()!))
                      : Center(child: Text('데이터를 불러오는 데 실패했습니다. 다시 시도해 주세요.')),
        ),
        _buildPeriodSelector(),
      ],
    );
  }

  List<Map<String, dynamic>>? _getSelectedData() {
    List<Map<String, dynamic>>? result;
    switch (_selectedPeriod) {
      case '1일':
        result = _stockData;
        // 데이터가 3개 미만일 경우 더미 데이터 추가
        while (result != null && result.length < 3) {
          result.add(Map<String, dynamic>.from(result.last));
        }
        break;
      case '3달':
        result = _daystockData;
        break;
      case '1년':
        result = _weekstockData;
        break;
      case '5년':
        result = _monthstockData;
        break;
      default:
        result = _stockData;
    }
    print('Selected data length: ${result?.length}');
    return result;
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
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    String safeToString(dynamic value) {
      if (value == null) return '정보 없음';
      return value.toString();
    }

    String getFinancialData(String key) {
      var value = details[key];
      if (value == null) {
        print('$key is null in details map'); // 디버깅을 위한 로그
        return '정보 없음yoyo';
      }
      return safeToString(value);
    }

    return ListView(
      children: [
        ListTile(
            title: Text('${widget.stockCode}'),
            trailing: Text(safeToString(details['marketIdCode']))),
        ListTile(
            title: Text('시장 구분'),
            trailing: Text(safeToString(details['marketIdCode']))),
        ListTile(
            title: Text('업종'),
            trailing: Text(safeToString(details['industryCodeName']))),
        ListTile(
            title: Text('상장일'),
            trailing: Text(safeToString(details['listingDate']))),
        ListTile(
            title: Text('결산월'),
            trailing: Text(safeToString(details['settlementMonth']))),
        ListTile(
            title: Text('자본금'),
            trailing: Text(safeToString(details['capital']))),
        ListTile(
            title: Text('상장주식수'),
            trailing: Text(safeToString(details['listedStockCount']))),
        ListTile(
            title: Text('매출액'),
            trailing: Text(safeToString(details['salesRevenue']))),
        ListTile(
            title: Text('당기순이익'),
            trailing: Text(safeToString(details['netIncome']))),
        ListTile(
            title: Text('시가총액'),
            trailing: Text(safeToString(details['marketCap']))),
        ListTile(
            title: Text('전일종가'),
            trailing: Text(safeToString(details['previousClosePrice']))),
        ListTile(
            title: Text('250일 고가'),
            trailing: Text(safeToString(details['high250Price']))),
        ListTile(
            title: Text('250일 저가'),
            trailing: Text(safeToString(details['low250Price']))),
        ListTile(
            title: Text('연중 고가'),
            trailing: Text(safeToString(details['yearlyHighPrice']))),
        ListTile(
            title: Text('연중 저가'),
            trailing: Text(safeToString(details['yearlyLowPrice']))),
        ListTile(
            title: Text('배당금'),
            trailing: Text(safeToString(details['dividendAmount']))),
        ListTile(
            title: Text('배당수익률'),
            trailing: Text(safeToString(details['dividendYield']))),
        ListTile(title: Text('PER'), trailing: Text(getFinancialData('per'))),
        ListTile(title: Text('EPS'), trailing: Text(getFinancialData('eps'))),
        ListTile(title: Text('PBR'), trailing: Text(getFinancialData('pbr'))),
        ListTile(title: Text('BPS'), trailing: Text(getFinancialData('bps'))),
        ListTile(title: Text('ROE'), trailing: Text(getFinancialData('roe'))),
        ListTile(title: Text('ROA'), trailing: Text(getFinancialData('roa'))),
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
