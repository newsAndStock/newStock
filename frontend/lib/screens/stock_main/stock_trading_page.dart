import 'package:flutter/material.dart';
import 'package:frontend/api/stock_api/favorite_stock_api.dart';
import 'package:frontend/api/stock_api/trading_api/fixed_price_api.dart';
import 'package:frontend/api/stock_api/trading_api/in_trading_api.dart';
import 'package:frontend/api/stock_api/trading_api/market_price_api.dart';
import 'package:frontend/screens/stock_main/stock_main.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure storage import
import 'dart:async';
import 'package:frontend/api/stock_api/stock_detail_api.dart';

class StockTradingPage extends StatefulWidget {
  final String stockName;
  final String stockCode;
  final double currentPrice;
  final double priceChange;
  final double priceChangePercentage;
  final int totalHoldingQuantity;

  const StockTradingPage({
    Key? key,
    required this.stockName,
    required this.stockCode,
    required this.currentPrice,
    required this.priceChange,
    required this.priceChangePercentage,
    required this.totalHoldingQuantity,
  }) : super(key: key);

  @override
  _StockTradingPageState createState() => _StockTradingPageState();
}

class _StockTradingPageState extends State<StockTradingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMarketOrder = true;
  int _quantity = 0;
  double _limitPrice = 0;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _limitPriceController = TextEditingController();
  final FocusNode _quantityFocusNode = FocusNode();
  late int _availableBalance;
  bool _showKeypad = false;
  bool _showPriceVolumeChart = true;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  late int _totalHoldingQuantity;
  late String _balanceType;
  late Timer? _timer;
  late dynamic _holdingCounts;

  bool _isFavorite = false;
  bool _isLoading = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  CurrentStockPriceResponse? _currentStockPrice;
  Timer? _priceUpdateTimer;

  late Future<int> _averagePriceFuture;
  bool _isInitialPriceSet = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    // _limitPrice = widget.currentPrice;
    // _limitPriceController.text = widget.currentPrice.toStringAsFixed(0);
    _quantityFocusNode.addListener(_onQuantityFocusChange);
    _totalHoldingQuantity = widget.totalHoldingQuantity;
    _availableBalance = 0;
    _balanceType = 'USER';
    _holdingCounts = 0;
    _fetchCurrentStockPrice();
    _startPriceUpdateTimer();
    _checkFavoriteStatus();
    _averagePriceFuture = _loadAveragePrice();
    _limitPriceController.addListener(_onLimitPriceChanged);

    // 비동기 초기화를 위한 Future 사용
    Future.microtask(() async {
      await _loadAvailableBalance();
      await _loadHoldingCounts(widget.stockCode);
      if (mounted) {
        setState(() {}); // 상태 업데이트를 강제로 트리거
      }
    });

    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _loadAvailableBalance();
      _loadHoldingCounts(widget.stockCode);
    });
  }

  Future<int> _loadAveragePrice() async {
    try {
      Map<String, dynamic> response =
          await InTradingApi().getAveragePrice(widget.stockCode);
      return response['averagePrice'] as int;
    } catch (e) {
      print('Error loading average price: $e');
      return 0;
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _resetQuantity();
    }
  }

  void _resetQuantity() {
    setState(() {
      _quantity = 0;
      _quantityController.text = '';
    });
  }

  void _startPriceUpdateTimer() {
    _priceUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _fetchCurrentStockPrice();
    });
  }

  String formatNumberr(double numStr) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(numStr);
  }

  void _showConfirmationDialog(
      bool isBuy, bool isMarketOrder, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isBuy ? '매수 주문 확인' : '매도 주문 확인'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('종목: ${widget.stockName}'),
              Text('수량: $_quantity 주'),
              Text('주문 유형: ${isMarketOrder ? '시장가' : '지정가'}'),
              if (!isMarketOrder) Text('지정가: ${formatNumberr(_limitPrice)} 원'),
              Text(
                  '예상 금액: ${(_isMarketOrder ? widget.currentPrice : _limitPrice) * _quantity} 원'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
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

  Future<void> _fetchCurrentStockPrice() async {
    try {
      final data =
          await StockDetailApi().getCurrentStockPrice(widget.stockCode);
      setState(() {
        _currentStockPrice = data;

        if (_currentStockPrice != null && !_isInitialPriceSet) {
          List<int> askPrices = _currentStockPrice!.askpMap.keys
              .map((e) => int.parse(e))
              .toList();
          List<int> bidPrices = _currentStockPrice!.bidpMap.keys
              .map((e) => int.parse(e))
              .toList();

          if (askPrices.isNotEmpty && bidPrices.isNotEmpty) {
            int highestBid = bidPrices.reduce((a, b) => a > b ? a : b);
            int lowestAsk = askPrices.reduce((a, b) => a < b ? a : b);
            _limitPrice = (highestBid + lowestAsk) / 2;
            _limitPriceController.text =
                formatNumber(_limitPrice.toStringAsFixed(0));
            _isInitialPriceSet = true;
          }
        }
      });
    } catch (e) {
      print('Error fetching current stock price: $e');
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _quantityController.dispose();
    _quantityFocusNode.removeListener(_onQuantityFocusChange);
    _quantityFocusNode.dispose();
    _limitPriceController.dispose();
    _timer?.cancel();
    _priceUpdateTimer?.cancel();
    _limitPriceController.removeListener(_onLimitPriceChanged);
    super.dispose();
  }

  void _onLimitPriceChanged() {
    if (!_isMarketOrder) {
      setState(() {
        _limitPrice =
            double.tryParse(_limitPriceController.text) ?? _limitPrice;
      });
    }
  }

  Future<void> _loadAvailableBalance() async {
    try {
      Map<String, int> deposit = await InTradingApi().getDeposit();
      print('API Response: $deposit'); // 디버깅을 위한 출력
      setState(() {
        if (deposit.isNotEmpty) {
          var entry = deposit.entries.first;
          _balanceType = entry.key;
          _availableBalance = entry.value;
          print(
              'Updated balance: $_balanceType - $_availableBalance'); // 디버깅을 위한 출력
        } else {
          print('Deposit map is empty'); // 디버깅을 위한 출력
        }
      });
    } catch (e) {
      print('Failed to load available balance: $e');
    }
  }

  Future<void> _loadHoldingCounts(String stockCode) async {
    try {
      Map<String, dynamic> holding =
          await InTradingApi().getHoldings(stockCode);
      print('API Response: $holding'); // 디버깅을 위한 출력
      setState(() {
        if (holding.isNotEmpty) {
          _holdingCounts = holding['holdingsCount'];
        } else {
          print('Holding map is empty'); // 디버깅을 위한 출력
        }
      });
    } catch (e) {
      print('Failed to load available balance: $e');
    }
  }

  void _onQuantityFocusChange() {
    setState(() {
      _showKeypad = _quantityFocusNode.hasFocus;
      if (!_isMarketOrder) {
        _showPriceVolumeChart = !_quantityFocusNode.hasFocus;
      }
    });
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
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16), // 라벨 좌우 여백 추가
                  child: Text(
                    '매수',
                    style: TextStyle(fontSize: 16), // 글씨 크기 증가
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16), // 라벨 좌우 여백 추가
                  child: Text(
                    '매도',
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
                _buildBuyTab(),
                _buildSellTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildStockInfo() {
    if (_currentStockPrice == null) {
      return Center(child: CircularProgressIndicator());
    }

    double priceChange = double.parse(_currentStockPrice!.prdyVrss);
    Color changeColor = priceChange >= 0 ? Colors.red : Colors.blue;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatNumber(_currentStockPrice!.stckPrpr)}원',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '${priceChange >= 0 ? '+' : ''}${formatNumber(_currentStockPrice!.prdyVrss)}원 (${formatNumber(_currentStockPrice!.prdyCtrt)}%)',
            style: TextStyle(fontSize: 16, color: changeColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyTab() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: _buildAvailableBalance(),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: _buildOrderTypeSelector(),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: _isMarketOrder
                        ? _buildMarketOrderPrice()
                        : _buildLimitOrderPrice(),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                        color: Color(0xffF1F5F9),
                      ),
                      child: Column(
                        children: [
                          FractionallySizedBox(
                              widthFactor: 0.85, child: _buildQuantityInput()),
                          FractionallySizedBox(
                              widthFactor: 0.95, child: _buildTotalAmount()),
                        ],
                      ),
                    ),
                  ),
                  if (_showKeypad) Expanded(child: _buildKeypad()),
                  if (!_isMarketOrder && _showPriceVolumeChart)
                    Expanded(child: _buildPriceVolumeChart()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSellTab() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  SizedBox(height: 15),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: _buildAvailableStock(),
                  ),
                  SizedBox(height: 15),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: _buildOrderTypeSelector(),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: _isMarketOrder
                        ? _buildMarketOrderPrice()
                        : _buildLimitOrderPrice(),
                  ),
                  SizedBox(height: 15),
                  FractionallySizedBox(
                    widthFactor: 0.9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                        color: Color(0xffF1F5F9),
                      ),
                      child: Column(
                        children: [
                          FractionallySizedBox(
                              widthFactor: 0.85, child: _buildQuantityInput()),
                          FractionallySizedBox(
                              widthFactor: 0.95, child: _buildTotalAmount()),
                        ],
                      ),
                    ),
                  ),
                  if (_showKeypad) Expanded(child: _buildKeypad()),
                  if (!_isMarketOrder && _showPriceVolumeChart)
                    Expanded(child: _buildPriceVolumeChart()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvailableBalance() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color(0xFF3A2E6A),
          borderRadius: BorderRadius.all(Radius.circular(40))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$_balanceType님의 가용자산',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
              Text('${formatNumber(_availableBalance.toStringAsFixed(0))}원',
                  style: TextStyle(color: Colors.white, fontSize: 23)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAvailableStock() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color(0xFF3A2E6A),
          borderRadius: BorderRadius.all(Radius.circular(40))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_balanceType님의 보유 주식',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              Text(
                '$_holdingCounts주',
                style: TextStyle(color: Colors.white, fontSize: 23),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Widget _buildOrderTypeSelector() {
  //   return Container(
  //     decoration: BoxDecoration(
  //         borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(40), topRight: Radius.circular(40)),
  //         color: Color(0xffF1F5F9)),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: RadioListTile<bool>(
  //             title: Text('시장가'),
  //             value: true,
  //             groupValue: _isMarketOrder,
  //             onChanged: (value) => setState(() => _isMarketOrder = value!),
  //           ),
  //         ),
  //         Expanded(
  //           child: RadioListTile<bool>(
  //             title: Text('지정가'),
  //             value: false,
  //             groupValue: _isMarketOrder,
  //             onChanged: (value) => setState(() => _isMarketOrder = value!),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildOrderTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        color: Color(0xffF1F5F9),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isMarketOrder = true),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '시장가',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      _isMarketOrder ? FontWeight.bold : FontWeight.normal,
                  color: _isMarketOrder ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
          SizedBox(width: 4),
          Text('|'),
          SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _isMarketOrder = false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '지정가',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      !_isMarketOrder ? FontWeight.bold : FontWeight.normal,
                  color: !_isMarketOrder ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketOrderPrice() {
    return Container(
      height: 70, // _buildLimitOrderPrice와 동일한 높이
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        color: Color(0xffF1F5F9),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '시장가로 즉시 체결됩니다.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // SizedBox(height: 4),
          Text(
            '※ 현재 보이는 가격과 다를 수 있어요!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitOrderPrice() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        color: Color(0xffF1F5F9),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _limitPriceController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixText: '원',
                    suffixStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          FutureBuilder<int>(
            future: _averagePriceFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('평균 구매가 로딩 중...',
                    style: TextStyle(fontSize: 12, color: Colors.grey));
              } else if (snapshot.hasError) {
                return Text('평균 구매가 정보를 불러올 수 없습니다',
                    style: TextStyle(fontSize: 12, color: Colors.grey));
              } else if (snapshot.hasData && snapshot.data! > 0) {
                int averagePrice = snapshot.data!;
                return Text(
                  '나의 평균 구매가 ${NumberFormat('#,###').format(averagePrice)}원',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                );
              } else {
                return Text('평균 구매가 정보 없음',
                    style: TextStyle(fontSize: 12, color: Colors.grey));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceVolumeChart() {
    if (_currentStockPrice == null) {
      return Center(child: CircularProgressIndicator());
    }

    List<MapEntry<String, String>> askpEntries =
        _currentStockPrice!.askpMap.entries.toList();
    List<MapEntry<String, String>> bidpEntries =
        _currentStockPrice!.bidpMap.entries.toList();

    // 매도 호가는 낮은 가격부터 높은 가격 순으로 정렬
    askpEntries.sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    // 매수 호가는 높은 가격부터 낮은 가격 순으로 정렬
    bidpEntries.sort((a, b) => int.parse(b.key).compareTo(int.parse(a.key)));

    int maxVolume = [...askpEntries, ...bidpEntries]
        .map((e) => int.parse(e.value))
        .reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          // 매도 호가 (높은 가격부터 낮은 가격 순으로 표시)
          for (var i = askpEntries.length - 1;
              i >= 0 && i >= askpEntries.length - 5;
              i--)
            _buildPriceVolumeRow(
              volume: int.parse(askpEntries[i].value),
              price: int.parse(askpEntries[i].key),
              maxVolume: maxVolume,
              isAsk: true,
            ),
          _buildCurrentPriceRow(int.parse(_currentStockPrice!.stckPrpr)),
          // 매수 호가 (높은 가격부터 낮은 가격 순으로 표시)
          for (var i = 0; i < bidpEntries.length && i < 5; i++)
            _buildPriceVolumeRow(
              volume: int.parse(bidpEntries[i].value),
              price: int.parse(bidpEntries[i].key),
              maxVolume: maxVolume,
              isAsk: false,
            ),
        ],
      ),
    );
  }

  Widget _buildPriceVolumeRow({
    required int volume,
    required int price,
    required int maxVolume,
    required bool isAsk,
  }) {
    Color barColor =
        isAsk ? Colors.blue.withOpacity(0.1) : Colors.red.withOpacity(0.1);
    Color textColor = isAsk ? Colors.blue : Colors.red;

    return InkWell(
      onTap: () {
        setState(() {
          _limitPrice = price.toDouble();
          _limitPriceController.text = price.toString();
        });
      },
      child: Container(
        height: 30,
        child: Stack(
          children: [
            _buildVolumeBar(volume, maxVolume, barColor, isAsk),
            Row(
              children: [
                Expanded(
                  child: Text(
                    isAsk ? NumberFormat('#,###').format(volume) : '',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: textColor, fontSize: 12),
                  ),
                ),
                Container(
                  width: 80,
                  alignment: Alignment.center,
                  child: Text(
                    NumberFormat('#,###').format(price),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    !isAsk ? NumberFormat('#,###').format(volume) : '',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: textColor, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeBar(int volume, int maxVolume, Color color, bool isAsk) {
    double ratio = (volume / maxVolume) * 0.7; // 최대 길이를 0.7로 제한
    return Align(
      alignment: isAsk ? Alignment.centerLeft : Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: ratio,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.horizontal(
              left: isAsk ? Radius.circular(0) : Radius.circular(4),
              right: isAsk ? Radius.circular(4) : Radius.circular(0),
            ),
          ),
          height: 20, // 박스의 높이를 늘림
        ),
      ),
    );
  }

  Widget _buildCurrentPriceRow(int currentPrice) {
    return Container(
      height: 40,
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            NumberFormat('#,###').format(currentPrice),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityInput() {
    return TextField(
      controller: _quantityController,
      focusNode: _quantityFocusNode,
      decoration: InputDecoration(
        labelText: '주문수량',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        labelStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      keyboardType: TextInputType.number,
      style: TextStyle(
        fontSize: 27,
        color: Colors.black,
      ),
      onChanged: (value) {
        if (!value.endsWith('주')) {
          _quantityController.value = TextEditingValue(
            text: value + '주',
            selection: TextSelection.collapsed(offset: value.length),
          );
        }
        setState(
            () => _quantity = int.tryParse(value.replaceAll('주', '')) ?? 0);
      },
    );
  }

  Widget _buildTotalAmount() {
    double totalAmount = _isMarketOrder
        ? (_currentStockPrice?.stckPrpr != null
            ? double.parse(_currentStockPrice!.stckPrpr) * _quantity
            : widget.currentPrice * _quantity)
        : _limitPrice * _quantity;
    return ListTile(
      trailing: Text(
        '예상 금액 ${NumberFormat('#,###').format(totalAmount.round())} 원',
        style: TextStyle(color: Color(0xff312E81), fontSize: 18),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      height: 200,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        children: List.generate(12, (index) {
          if (index == 9) {
            return TextButton(
              onPressed: _setMaxQuantity,
              child: Text('최대',
                  style: TextStyle(fontSize: 24, color: Colors.black)),
            );
          }
          if (index == 10)
            return Center(
                child: Text('0',
                    style: TextStyle(fontSize: 24, color: Colors.black)));
          if (index == 11) {
            return TextButton(
              onPressed: _deleteLastDigit,
              child: Icon(Icons.backspace, color: Colors.black),
            );
          }
          return TextButton(
            onPressed: () => _updateQuantity(index + 1),
            child: Text('${index + 1}',
                style: TextStyle(fontSize: 24, color: Colors.black)),
          );
        }),
      ),
    );
  }

  void _setMaxQuantity() {
    if (_tabController.index == 0) {
      // 매수 탭
      double currentPrice = _isMarketOrder
          ? (_currentStockPrice?.stckPrpr != null
              ? double.parse(_currentStockPrice!.stckPrpr)
              : widget.currentPrice)
          : _limitPrice;
      int maxQuantity = (_availableBalance / currentPrice).floor();
      setState(() {
        _quantity = maxQuantity;
        _quantityController.text = '$_quantity 주';
      });
    } else {
      // 매도 탭
      setState(() {
        _quantity = _holdingCounts;
        _quantityController.text = '$_quantity 주';
      });
    }
  }

  void _deleteLastDigit() {
    setState(() {
      if (_quantity > 0) {
        _quantity = (_quantity ~/ 10);
        _quantityController.text = _quantity.toString();
      }
    });
  }

  void _updateQuantity(int digit) {
    setState(() {
      if (_quantity == 0) {
        _quantity = digit;
      } else {
        _quantity = int.parse('$_quantity$digit').clamp(0, 999999);
      }
      // 여기서 '주'를 추가합니다.
      _quantityController.value = TextEditingValue(
        text: '${_quantity} 주',
        selection: TextSelection.collapsed(offset: _quantity.toString().length),
      );
    });
  }

  Widget _buildBuyButton() {
    return Container(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3A2E6A),
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: () {
          double currentPrice = _isMarketOrder
              ? (_currentStockPrice?.stckPrpr != null
                  ? double.parse(_currentStockPrice!.stckPrpr)
                  : widget.currentPrice)
              : _limitPrice;
          double totalCost = currentPrice * _quantity;
          if (_quantity <= 0 || totalCost > _availableBalance) {
            _showErrorDialog('입력 오류', '주문 수량이 올바르지 않거나 가용 자산을 초과합니다.');
          } else {
            _showConfirmationBottomSheet(
              isBuy: true,
              isMarketOrder: _isMarketOrder,
              onConfirm: () async {
                String? accessToken = await storage.read(key: 'accessToken');
                if (accessToken == null) {
                  throw Exception('No access token found');
                }
                try {
                  String orderTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                      .format(DateTime.now());
                  if (_isMarketOrder) {
                    await MarketPriceApi.buyMarket(
                      token: accessToken,
                      stockCode: widget.stockCode,
                      quantity: _quantity,
                      orderTime: orderTime,
                    );
                  } else {
                    await FixedPriceApi.buyMarket(
                      token: accessToken,
                      stockCode: widget.stockCode,
                      bid: _limitPrice,
                      quantity: _quantity,
                      orderTime: orderTime,
                    );
                  }
                  _showSuccessMessage(_isMarketOrder
                      ? '시장가 매수 신청이 완료되었습니다.'
                      : '지정가 매수 신청이 완료되었습니다.');
                  Navigator.of(context).pop(); // 현재 화면을 닫습니다.
                } catch (e) {
                  _showErrorDialog('오류', '주문 처리 중 오류가 발생했습니다: ${e.toString()}');
                }
              },
            );
          }
        },
        child:
            Text('매수하기', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  // Widget _buildSellButton() {
  //   return Container(
  //     padding: EdgeInsets.all(16),
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: Color(0xFF3A2E6A),
  //         minimumSize: Size(double.infinity, 50),
  //       ),
  //       onPressed: () {
  //         if (_quantity <= 0 || _quantity > _holdingCounts) {
  //           _showErrorDialog('입력 오류', '주문 수량이 올바르지 않거나 보유 주식 수를 초과합니다.');
  //         } else {
  //           _showConfirmationBottomSheet(
  //             isBuy: false,
  //             isMarketOrder: _isMarketOrder,
  //             onConfirm: () async {
  //               String? accessToken = await storage.read(key: 'accessToken');
  //               if (accessToken == null) {
  //                 throw Exception('No access token found');
  //               }
  //               try {
  //                 String orderTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss")
  //                     .format(DateTime.now());
  //                 Map<String, dynamic> result;
  //                 if (_isMarketOrder) {
  //                   result = await MarketPriceApi.sellMarket(
  //                     token: accessToken,
  //                     stockCode: widget.stockCode,
  //                     quantity: _quantity,
  //                     orderTime: orderTime,
  //                   );
  //                 } else {
  //                   result = await FixedPriceApi.sellMarket(
  //                     token: accessToken,
  //                     stockCode: widget.stockCode,
  //                     bid: _limitPrice,
  //                     quantity: _quantity,
  //                     orderTime: orderTime,
  //                   );
  //                 }
  //                 _showResultBottomSheet(result, false, _isMarketOrder);
  //               } catch (e) {
  //                 _showErrorDialog('오류', '주문 처리 중 오류가 발생했습니다: ${e.toString()}');
  //               }
  //             },
  //           );
  //         }
  //       },
  //       child:
  //           Text('매도하기', style: TextStyle(fontSize: 18, color: Colors.white)),
  //     ),
  //   );
  // }

  // Widget _buildBottomButton() {
  //   return _tabController.index == 0 ? _buildBuyButton() : _buildSellButton();
  // }

  Widget _buildBottomButton() {
    if (_tabController.index == 0) {
      // 매수 탭
      if (_isMarketOrder) {
        return _buildMarketBuyButton();
      } else {
        return _buildLimitBuyButton();
      }
    } else {
      // 매도 탭
      if (_isMarketOrder) {
        return _buildMarketSellButton();
      } else {
        return _buildLimitSellButton();
      }
    }
  }

  void _showConfirmationBottomSheet({
    required bool isBuy,
    required bool isMarketOrder,
    required Function onConfirm,
  }) {
    // 스타일 정의 (변경 없음)
    final TextStyle titleStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    final TextStyle contentStyle = TextStyle(
      fontSize: 16,
      color: Colors.white,
    );
    final TextStyle highlightStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    final ButtonStyle cancelButtonStyle = TextButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF3A2E6A),
      textStyle: TextStyle(fontSize: 16),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
    final ButtonStyle confirmButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF3A2E6A),
      textStyle: TextStyle(fontSize: 16),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
    double currentPrice = _currentStockPrice?.stckPrpr != null
        ? double.parse(_currentStockPrice!.stckPrpr)
        : widget.currentPrice;
    double orderPrice = isMarketOrder ? currentPrice : _limitPrice;
    double totalAmount = orderPrice * _quantity;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Color(0xFF3A2E6A),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isBuy ? '매수 주문 확인' : '매도 주문 확인',
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              _buildInfoRow('종목', widget.stockName, contentStyle),
              _buildInfoRow('수량', '$_quantity 주', contentStyle),
              _buildInfoRow(
                  '주문 유형', isMarketOrder ? '시장가' : '지정가', contentStyle),
              _buildInfoRow(
                  '주문 가격', '${formatNumberr(orderPrice)} 원', contentStyle),
              _buildInfoRow(
                  '예상 금액',
                  '${NumberFormat('#,###').format(totalAmount)} 원',
                  highlightStyle),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    child: Text('취소'),
                    style: cancelButtonStyle,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 32),
                  ElevatedButton(
                    child: Text('확인'),
                    style: confirmButtonStyle,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResultBottomSheet(
      Map<String, dynamic> result, bool isBuy, bool isMarketOrder) {
    // 스타일 정의 (변경 없음)
    final TextStyle titleStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    final TextStyle contentStyle = TextStyle(
      fontSize: 16,
      color: Colors.white,
    );
    final TextStyle highlightStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    final ButtonStyle confirmButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF3A2E6A),
      textStyle: TextStyle(fontSize: 16),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Color(0xFF3A2E6A),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('주문 완료', style: titleStyle, textAlign: TextAlign.center),
              SizedBox(height: 24),
              _buildInfoRow('종목', widget.stockName, contentStyle),
              _buildInfoRow('${isBuy ? "매수" : "매도"} 수량',
                  '${result['quantity']}주', contentStyle),
              _buildInfoRow(
                  '주문 유형', isMarketOrder ? "시장가" : "지정가", contentStyle),
              _buildInfoRow(
                  '총 ${isBuy ? "매수" : "매도"} 금액',
                  '${NumberFormat('#,###').format(result['totalPrice'])}원',
                  highlightStyle),
              SizedBox(height: 24),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: ElevatedButton(
                    child: Text('확인'),
                    style: confirmButtonStyle,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StockMainPage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, TextStyle style) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Text(label, style: style, textAlign: TextAlign.left),
          ),
          Expanded(
            flex: 2,
            child: Text(value, style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  // 시장가 매수
  Widget _buildMarketBuyButton() {
    return Container(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3A2E6A),
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: () {
          double currentPrice = _currentStockPrice?.stckPrpr != null
              ? double.parse(_currentStockPrice!.stckPrpr)
              : widget.currentPrice;
          int maxQuantity = (_availableBalance / currentPrice).floor();
          if (_quantity <= 0 || maxQuantity < _quantity) {
            _showErrorDialog('입력 오류', '올바른 수량을 입력해주세요.');
          } else {
            _showConfirmationBottomSheet(
              isBuy: true,
              isMarketOrder: true,
              onConfirm: () async {
                String? accessToken = await storage.read(key: 'accessToken');
                if (accessToken == null) {
                  throw Exception('No access token found');
                }
                try {
                  String orderTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                      .format(DateTime.now());
                  await MarketPriceApi.buyMarket(
                    token: accessToken,
                    stockCode: widget.stockCode,
                    quantity: _quantity,
                    orderTime: orderTime,
                  );
                  _showSuccessMessage('시장가 매수 신청이 완료되었습니다.');
                } catch (e) {
                  _showErrorDialog('오류', e.toString());
                }
              },
            );
          }
        },
        child:
            Text('매수하기', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  // 지정가 매수
  Widget _buildLimitBuyButton() {
    return Container(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3A2E6A),
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: () {
          int maxQuantity = (_availableBalance / _limitPrice).floor();
          if (_quantity <= 0 || maxQuantity < _quantity) {
            _showErrorDialog('입력 오류', '올바른 수량을 입력해주세요.');
          } else {
            _showConfirmationBottomSheet(
              isBuy: true,
              isMarketOrder: false,
              onConfirm: () async {
                String? accessToken = await storage.read(key: 'accessToken');
                if (accessToken == null) {
                  throw Exception('No access token found');
                }
                try {
                  String orderTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                      .format(DateTime.now());
                  await FixedPriceApi.buyMarket(
                    token: accessToken,
                    stockCode: widget.stockCode,
                    bid: _limitPrice,
                    quantity: _quantity,
                    orderTime: orderTime,
                  );
                  _showSuccessMessage('지정가 매수 신청이 완료되었습니다.');
                } catch (e) {
                  _showErrorDialog('오류', e.toString());
                }
              },
            );
          }
        },
        child:
            Text('매수하기', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: Text('확인'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // 시장가 매도
  Widget _buildMarketSellButton() {
    return Container(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3A2E6A),
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: () {
          if (_quantity <= 0 || _quantity > _holdingCounts) {
            _showErrorDialog('입력 오류', '올바른 수량을 입력해주세요.');
          } else {
            _showConfirmationBottomSheet(
              isBuy: false,
              isMarketOrder: true,
              onConfirm: () async {
                String? accessToken = await storage.read(key: 'accessToken');
                if (accessToken == null) {
                  throw Exception('No access token found');
                }
                try {
                  String orderTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                      .format(DateTime.now());
                  Map<String, dynamic> result = await MarketPriceApi.sellMarket(
                    token: accessToken,
                    stockCode: widget.stockCode,
                    quantity: _quantity,
                    orderTime: orderTime,
                  );
                  _showResultBottomSheet(result, false, true);
                } catch (e) {
                  _showErrorDialog('오류', '주문 처리 중 오류가 발생했습니다: ${e.toString()}');
                }
              },
            );
          }
        },
        child:
            Text('매도하기', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  // 지정가 매도
  Widget _buildLimitSellButton() {
    return Container(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3A2E6A),
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: () {
          if (_quantity <= 0 || _quantity > _holdingCounts) {
            _showErrorDialog('입력 오류', '주문 수량이 올바르지 않거나 보유 주식 수를 초과합니다.');
          } else {
            _showConfirmationBottomSheet(
              isBuy: false,
              isMarketOrder: false,
              onConfirm: () async {
                String? accessToken = await storage.read(key: 'accessToken');
                if (accessToken == null) {
                  _showErrorDialog('오류', '로그인 정보를 찾을 수 없습니다.');
                  return;
                }
                try {
                  print('Preparing to send sell order:'); // 디버그 로그
                  print('Stock Code: ${widget.stockCode}');
                  print('Limit Price: $_limitPrice');
                  print('Quantity: $_quantity');

                  String orderTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss")
                      .format(DateTime.now());
                  await FixedPriceApi.sellMarket(
                    token: accessToken,
                    stockCode: widget.stockCode,
                    bid: _limitPrice.toInt(),
                    quantity: _quantity,
                    orderTime: orderTime,
                  );
                  print('Sell order sent successfully'); // 성공 로그
                  _showSuccessMessage('지정가 매도 신청이 완료되었습니다.');
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error during sell order: $e'); // 에러 로그
                  _showErrorDialog(
                      '주문 처리 오류', '지정가 매도 신청 중 문제가 발생했습니다: ${e.toString()}');
                }
              },
            );
          }
        },
        child:
            Text('매도하기', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  String formatNumber(String numStr) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(double.parse(numStr));
  }

  void _showConfirmationSheet(
      Map<String, dynamic> result, bool isBuy, bool isMarketOrder) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF3A2E6A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.stockName,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              SizedBox(height: 5),
              Text(
                '${isBuy ? "매수" : "매도"} ${result['quantity']}주',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                isMarketOrder ? '시장가 주문' : '지정가 주문',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 16),
              FractionallySizedBox(
                widthFactor: 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '주당 ${isBuy ? "매수가" : "매도가"}',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      '${formatNumber((result['totalPrice'] / result['quantity']).toStringAsFixed(0))}원',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )
                  ],
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 주문 금액',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      '${result['totalPrice']}원',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text(
                  '확인',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
