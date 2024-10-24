import 'dart:math';
import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/api/stock_api/chart_api.dart';
import 'package:frontend/api/stock_api/stock_detail_api.dart';
import 'package:frontend/screens/news/news_detail.dart';
import 'package:frontend/screens/stock_main/interactive_chart/interactive_chart.dart';
import 'package:frontend/api/stock_api/favorite_stock_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'stock_trading_page.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:ui' as ui;

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
      {super.key, required this.stockName, required this.stockCode});

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
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late Map<dynamic, dynamic> details;

  List<Map<String, dynamic>> _newsData = [];
  bool _isLoadingNews = false;
  bool _hasMoreNews = true;
  int _currentPage = 1;
  static const int _pageSize = 10;

  CurrentStockPriceResponse? _currentStockPrice;
  late ValueNotifier<CurrentStockPriceResponse?> _currentStockPriceNotifier;
  Timer? _priceUpdateTimer;

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
    _fetchStockNews();
    _currentStockPriceNotifier = ValueNotifier(null);
    _fetchCurrentStockPrice();
    _startPriceUpdateTimer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _priceUpdateTimer?.cancel(); // 타이머 취소
    _currentStockPriceNotifier.dispose(); // ValueNotifier 해제
    super.dispose();
  }

  Future<void> _fetchCurrentStockPrice() async {
    try {
      final data =
          await StockDetailApi().getCurrentStockPrice(widget.stockCode);
      _currentStockPriceNotifier.value = data;
    } catch (e) {
      print('Error fetching current stock price: $e');
    }
  }

  void _startPriceUpdateTimer() {
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchCurrentStockPrice();
    });
  }

  // Future<void> _fetchStockNews({bool refresh = false}) async {
  //   if (_isLoadingNews) return;

  //   setState(() => _isLoadingNews = true);

  //   if (refresh) {
  //     setState(() {
  //       _currentPage = 1;
  //       _newsData = [];
  //       _hasMoreNews = true;
  //     });
  //   }

  //   try {
  //     final news = await StockDetailApi().getStockNews(
  //       widget.stockCode,
  //       page: _currentPage,
  //       pageSize: _pageSize,
  //     );

  //     setState(() {
  //       if (news.isEmpty) {
  //         _hasMoreNews = false;
  //       } else {
  //         _newsData.addAll(news);
  //         _currentPage++;
  //       }
  //       _isLoadingNews = false;
  //     });
  //   } catch (e) {
  //     print('Error fetching stock news: $e');
  //     setState(() {
  //       _isLoadingNews = false;
  //       if (_newsData.isEmpty) {
  //         _hasMoreNews = false;
  //       }
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to load stock news: ${e.toString()}')),
  //     );
  //   }
  // }

  Future<void> _fetchStockNews({bool refresh = false}) async {
    if (_isLoadingNews) return;

    setState(() => _isLoadingNews = true);

    if (refresh) {
      setState(() {
        _currentPage = 1;
        _newsData = [];
        _hasMoreNews = true;
      });
    }

    try {
      final news = await StockDetailApi().getStockNews(
        widget.stockCode,
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        if (news.isEmpty) {
          _hasMoreNews = false;
        } else {
          // 중복 제거 로직 추가
          final newNewsItems = news
              .where((newItem) => !_newsData.any((existingItem) =>
                  existingItem['newsId'] == newItem['newsId']))
              .toList();
          _newsData.addAll(newNewsItems);
          if (newNewsItems.length < _pageSize) {
            _hasMoreNews = false;
          } else {
            _currentPage++;
          }
        }
        _isLoadingNews = false;
      });
    } catch (e) {
      print('Error fetching stock news: $e');
      setState(() {
        _isLoadingNews = false;
        if (_newsData.isEmpty) {
          _hasMoreNews = false;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stock news: ${e.toString()}')),
      );
    }
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
        open: _parseDoublee(item['openingPrice']),
        high: _parseDoublee(item['highestPrice']),
        low: _parseDoublee(item['lowestPrice']),
        close: _parseDoublee(item['closingPrice']),
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

  static double? _parseDoublee(String? value) {
    if (value == null) return null;
    double? parsed = double.tryParse(value);
    if (parsed == null) return null;
    return parsed.floorToDouble(); // 소수점 이하를 버림
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.stockName),
        actions: [
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator()
                : Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _isLoading ? null : _toggleFavorite,
          ),
        ],
      ),
      body: Column(
        children: [
          ValueListenableBuilder<CurrentStockPriceResponse?>(
            valueListenable: _currentStockPriceNotifier,
            builder: (context, currentStockPrice, child) {
              if (currentStockPrice == null) {
                return const CircularProgressIndicator();
              }
              return _buildStockInfo(currentStockPrice);
            },
          ),
          // _buildChartSection(),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10), // 라벨 좌우 여백 추가
                  child: const Text(
                    '차트',
                    style: TextStyle(fontSize: 16), // 글씨 크기 증가
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10), // 라벨 좌우 여백 추가
                  child: const Text(
                    '종목 정보',
                    style: TextStyle(fontSize: 16), // 글씨 크기 증가
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10), // 라벨 좌우 여백 추가
                  child: const Text(
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
    DateTime currentDate = DateTime.now().subtract(const Duration(days: 30));
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
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return stockData;
  }

  String formatNumber(String numStr) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(double.parse(numStr));
  }

  Widget _buildStockInfo(CurrentStockPriceResponse currentStockPrice) {
    double priceChange = double.parse(currentStockPrice.prdyVrss);
    double priceChangePercentage = double.parse(currentStockPrice.prdyCtrt);
    Color changeColor = priceChange >= 0 ? Colors.red : Colors.blue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                '${formatNumber(currentStockPrice.stckPrpr)}원',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                '${priceChange >= 0 ? '+' : ''}${formatNumber(currentStockPrice.prdyVrss)}원 (${currentStockPrice.prdyCtrt}%)',
                style: TextStyle(fontSize: 16, color: changeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return SizedBox(
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
    final selectedData = _getSelectedData();
    if (selectedData == null || selectedData.isEmpty) {
      return const Center(child: Text('데이터를 불러오는 데 실패했습니다. 다시 시도해 주세요.'));
    }

    List<Candle> candles = selectedData.map((item) {
      return Candle(
        date: DateTime.parse(item['date']),
        high: double.parse(item['highestPrice']),
        low: double.parse(item['lowestPrice']),
        open: double.parse(item['openingPrice']),
        close: double.parse(item['closingPrice']),
        volume: double.parse(item['volume']),
      );
    }).toList();

    // 현재 가격 정보를 마지막 캔들로 추가
    if (_currentStockPrice != null) {
      DateTime now = DateTime.now();
      double currentPrice = double.parse(_currentStockPrice!.stckPrpr);

      // 마지막 캔들의 정보를 기반으로 새 캔들 생성
      Candle lastCandle = candles.last;
      candles.add(Candle(
        date: now,
        high: max(currentPrice, lastCandle.high),
        low: min(currentPrice, lastCandle.low),
        open: lastCandle.close, // 마지막 종가를 시가로 사용
        close: currentPrice,
        volume: lastCandle.volume, // 볼륨 정보가 없으므로 마지막 캔들의 볼륨을 사용
      ));
    }

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
      return const Center(child: Text('데이터를 불러오는 데 실패했습니다. 다시 시도해 주세요.'));
    }

    List<FlSpot> spots = selectedData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(),
          double.parse(entry.value['closingPrice'].toString()));
    }).toList();

    // 현재 가격을 마지막 데이터 포인트로 추가
    if (_currentStockPrice != null) {
      spots.add(FlSpot(
          spots.length.toDouble(), double.parse(_currentStockPrice!.stckPrpr)));
    }

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
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
            titlesData: const FlTitlesData(
              bottomTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
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
                      'Date : ${date.year}/${date.month}/${date.day}\n${selectedData[flSpot.x.toInt()]['time'] != null ? 'Time : ${selectedData[flSpot.x.toInt()]['time']}\n' : ''}Price: ${flSpot.y.toStringAsFixed(0)}',
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
                    const FlLine(
                      color: Colors.grey,
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 8,
                          color: Colors.grey,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                '자세히 보기',
                style: TextStyle(
                  fontSize: 16,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(
                  !_showLineChart
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: !_showLineChart ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _showLineChart = !_showLineChart;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading ||
                  _isLoadingday ||
                  _isLoadingweek ||
                  _isLoadingmonth
              ? const Center(child: CircularProgressIndicator())
              : _showLineChart
                  ? _buildLineChart()
                  : _getSelectedData() != null &&
                          _getSelectedData()!.length >= 3
                      ? InteractiveChart(
                          candles: _convertToCandleData(_getSelectedData()!))
                      : const Center(
                          child: Text('데이터를 불러오는 데 실패했습니다. 다시 시도해 주세요.')),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      return const Center(child: CircularProgressIndicator());
    }
    String safeToString(dynamic value) {
      if (value == null) return '정보 없음';
      return value.toString();
    }

    String getFinancialData(String key) {
      var value = details[key];
      if (value == null) {
        print('$key is null in details map'); // 디버깅을 위한 로그
        return '정보 없음';
      }
      return safeToString(value);
    }

    const TextStyle tileTextStyle = TextStyle(fontSize: 16);
    return ListView(
      children: [
        ListTile(
            title: const Text('시장 구분', style: tileTextStyle),
            trailing: Text(safeToString(details['marketIdCode']),
                style: tileTextStyle)),
        ListTile(
            title: const Text('업종', style: tileTextStyle),
            trailing: Text(safeToString(details['industryCodeName']),
                style: tileTextStyle)),
        ListTile(
            title: const Text('상장일', style: tileTextStyle),
            trailing: Text(safeToString(details['listingDate']),
                style: tileTextStyle)),
        ListTile(
            title: const Text('자본금', style: tileTextStyle),
            trailing:
                Text(safeToString(details['capital']), style: tileTextStyle)),
        ListTile(
            title: const Text('상장주식수', style: tileTextStyle),
            trailing: Text(safeToString(details['listedStockCount']),
                style: tileTextStyle)),
        ListTile(
            title: const Text('매출액', style: tileTextStyle),
            trailing: Text(safeToString(details['salesRevenue']),
                style: tileTextStyle)),
        ListTile(
            title: const Text('당기순이익', style: tileTextStyle),
            trailing:
                Text(safeToString(details['netIncome']), style: tileTextStyle)),
        ListTile(
            title: const Text('시가총액', style: tileTextStyle),
            trailing:
                Text(safeToString(details['marketCap']), style: tileTextStyle)),
        ListTile(
            title: const Text('전일종가', style: tileTextStyle),
            trailing: Text(safeToString(details['previousClosePrice']),
                style: tileTextStyle)),
        ListTile(
            title: const Text('250일 고가', style: tileTextStyle),
            trailing: Text(safeToString(details['high250Price']),
                style: tileTextStyle)),
        ListTile(
            title: const Text('250일 저가', style: tileTextStyle),
            trailing: Text(safeToString(details['low250Price']),
                style: tileTextStyle)),
        ListTile(
            title: const Text('연중 고가', style: tileTextStyle),
            trailing: Text(safeToString(details['yearlyHighPrice']),
                style: tileTextStyle)),
        ListTile(
            title: const Text('연중 저가', style: tileTextStyle),
            trailing: Text(safeToString(details['yearlyLowPrice']),
                style: tileTextStyle)),
        ListTile(
            title: const Text('배당금', style: tileTextStyle),
            trailing: Text(safeToString(details['dividendAmount']),
                style: tileTextStyle)),
        ListTile(
            title: const Text('배당수익률', style: tileTextStyle),
            trailing: Text(safeToString(details['dividendYield']),
                style: tileTextStyle)),
        ListTile(
            title: const Text('PER', style: tileTextStyle),
            trailing: Text(getFinancialData('per'), style: tileTextStyle)),
        ListTile(
            title: const Text('EPS', style: tileTextStyle),
            trailing: Text(getFinancialData('eps'), style: tileTextStyle)),
        ListTile(
            title: const Text('PBR', style: tileTextStyle),
            trailing: Text(getFinancialData('pbr'), style: tileTextStyle)),
        ListTile(
            title: const Text('BPS', style: tileTextStyle),
            trailing: Text(getFinancialData('bps'), style: tileTextStyle)),
        ListTile(
            title: const Text('ROE', style: tileTextStyle),
            trailing: Text(getFinancialData('roe'), style: tileTextStyle)),
        ListTile(
            title: const Text('ROA', style: tileTextStyle),
            trailing: Text(getFinancialData('roa'), style: tileTextStyle)),
      ],
    );
  }

  Widget _buildNewsTab() {
    if (_isLoadingNews && _newsData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_newsData.isEmpty && !_hasMoreNews) {
      return const Center(child: Text('관련 뉴스가 없습니다.'));
    }

    return RefreshIndicator(
      onRefresh: () => _fetchStockNews(refresh: true),
      child: ListView.separated(
        itemCount: _newsData.length + (_hasMoreNews ? 1 : 0),
        separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
        itemBuilder: (context, index) {
          if (index == _newsData.length) {
            if (_hasMoreNews && !_isLoadingNews) {
              Future.microtask(() => _fetchStockNews());
            }
            return _hasMoreNews
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink();
          }

          final news = _newsData[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailScreen(
                      newsId: news['newsId'].toString(),
                    ),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${news['press'] ?? 'Unknown'} | ${news['date'] ?? 'No Date'}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child:
                        news['imageUrl'] != null && news['imageUrl'].isNotEmpty
                            ? Image.network(
                                news['imageUrl'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  return const Icon(Icons.error, size: 60);
                                },
                              )
                            : const Icon(Icons.article, size: 60),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget _buildNewsTab() {
  //   if (_isLoadingNews && _newsData.isEmpty) {
  //     return Center(child: CircularProgressIndicator());
  //   }

  //   if (_newsData.isEmpty && !_hasMoreNews) {
  //     return Center(child: Text('관련 뉴스가 없습니다.'));
  //   }

  //   return RefreshIndicator(
  //     onRefresh: () => _fetchStockNews(refresh: true),
  //     child: ListView.separated(
  //       itemCount: _newsData.length + (_hasMoreNews ? 1 : 0),
  //       separatorBuilder: (context, index) => Center(
  //         child: FractionallySizedBox(
  //           widthFactor: 0.9,
  //           child: Divider(
  //             color: Colors.grey[300],
  //             height: 1,
  //           ),
  //         ),
  //       ),
  //       itemBuilder: (context, index) {
  //         if (index == _newsData.length && _hasMoreNews) {
  //           _fetchStockNews();
  //           return Center(
  //             child: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: CircularProgressIndicator(),
  //             ),
  //           );
  //         }

  //         if (index >= _newsData.length) {
  //           return SizedBox.shrink();
  //         }

  //         final news = _newsData[index];
  //         return FractionallySizedBox(
  //           widthFactor: 0.9,
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 8.0),
  //             child: ListTile(
  //               title: Text(
  //                 news['title'] ?? 'No Title',
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //               subtitle: Padding(
  //                 padding: const EdgeInsets.only(top: 4.0),
  //                 child: Text(
  //                   '${news['press'] ?? 'Unknown'} | ${news['date'] ?? 'No Date'}',
  //                   style: TextStyle(fontSize: 14),
  //                 ),
  //               ),
  //               leading: ClipRRect(
  //                 borderRadius: BorderRadius.circular(8.0),
  //                 child: news['imageUrl'] != null && news['imageUrl'].isNotEmpty
  //                     ? Image.network(
  //                         news['imageUrl'],
  //                         width: 60,
  //                         height: 60,
  //                         fit: BoxFit.cover,
  //                         errorBuilder: (context, error, stackTrace) {
  //                           print('Error loading image: $error');
  //                           return Icon(Icons.error, size: 60);
  //                         },
  //                       )
  //                     : Icon(Icons.article, size: 60),
  //               ),
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => NewsDetailScreen(
  //                       newsId: news['newsId'].toString(),
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget _buildNewsTab() {
  //   if (_isLoadingNews && _newsData.isEmpty) {
  //     return Center(child: CircularProgressIndicator());
  //   }

  //   if (_newsData.isEmpty && !_hasMoreNews) {
  //     return Center(child: Text('관련 뉴스가 없습니다.'));
  //   }

  //   return RefreshIndicator(
  //     onRefresh: () => _fetchStockNews(refresh: true),
  //     child: ListView.separated(
  //       itemCount: _newsData.length + (_hasMoreNews ? 1 : 0),
  //       separatorBuilder: (context, index) => Center(
  //         child: FractionallySizedBox(
  //           widthFactor: 0.9,
  //           child: Divider(
  //             color: Colors.grey[300],
  //             height: 1,
  //           ),
  //         ),
  //       ),
  //       itemBuilder: (context, index) {
  //         if (index == _newsData.length) {
  //           if (_hasMoreNews && !_isLoadingNews) {
  //             // 다음 페이지 로드를 위해 Future.microtask 사용
  //             Future.microtask(() => _fetchStockNews());
  //           }
  //           return _hasMoreNews
  //               ? Center(
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: CircularProgressIndicator(),
  //                   ),
  //                 )
  //               : SizedBox.shrink();
  //         }

  //         final news = _newsData[index];
  //         return FractionallySizedBox(
  //           widthFactor: 0.9,
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 8.0),
  //             child: ListTile(
  //               title: Text(
  //                 news['title'] ?? 'No Title',
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //               subtitle: Padding(
  //                 padding: const EdgeInsets.only(top: 4.0),
  //                 child: Text(
  //                   '${news['press'] ?? 'Unknown'} | ${news['date'] ?? 'No Date'}',
  //                   style: TextStyle(fontSize: 14),
  //                 ),
  //               ),
  //               leading: ClipRRect(
  //                 borderRadius: BorderRadius.circular(8.0),
  //                 child: news['imageUrl'] != null && news['imageUrl'].isNotEmpty
  //                     ? Image.network(
  //                         news['imageUrl'],
  //                         width: 60,
  //                         height: 60,
  //                         fit: BoxFit.cover,
  //                         errorBuilder: (context, error, stackTrace) {
  //                           print('Error loading image: $error');
  //                           return Icon(Icons.error, size: 60);
  //                         },
  //                       )
  //                     : Icon(Icons.article, size: 60),
  //               ),
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => NewsDetailScreen(
  //                       newsId: news['newsId'].toString(),
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          if (_currentStockPriceNotifier.value != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StockTradingPage(
                  stockName: widget.stockName,
                  stockCode: widget.stockCode,
                  currentPrice:
                      double.parse(_currentStockPriceNotifier.value!.stckPrpr),
                  priceChange:
                      double.parse(_currentStockPriceNotifier.value!.prdyVrss),
                  priceChangePercentage:
                      double.parse(_currentStockPriceNotifier.value!.prdyCtrt),
                  totalHoldingQuantity: 0,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('현재 주가 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A2E6A),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          '거래하기',
          style: TextStyle(color: Colors.white),
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
      textDirection: ui.TextDirection.ltr, // 여기를 수정
      textAlign: TextAlign.center,
    );

    void drawPoint(int index, double price, String label) {
      final x = (index - minX) / (maxX - minX) * size.width;
      final y = size.height - ((price - minY) / (maxY - minY) * size.height);

      canvas.drawCircle(Offset(x, y), 4, paint);

      textPainter.text = TextSpan(
        text: '$label: ${price.toStringAsFixed(0)}',
        style: const TextStyle(color: Colors.blue, fontSize: 10),
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
        style: const TextStyle(color: Colors.blue, fontSize: 10),
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
