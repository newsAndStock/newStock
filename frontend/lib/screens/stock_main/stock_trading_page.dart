import 'package:flutter/material.dart';
import 'package:frontend/api/stock_api/favorite_stock_api.dart';
import 'package:frontend/api/stock_api/trading_api/fixed_price_api.dart';
import 'package:frontend/api/stock_api/trading_api/in_trading_api.dart';
import 'package:frontend/api/stock_api/trading_api/market_price_api.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure storage import
import 'dart:async';
import 'package:frontend/api/stock_api/stock_detail_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _limitPrice = widget.currentPrice;
    _limitPriceController.text = widget.currentPrice.toStringAsFixed(0);
    _quantityFocusNode.addListener(_onQuantityFocusChange);
    _totalHoldingQuantity = widget.totalHoldingQuantity;
    _tabController.addListener(_handleTabChange);
    _availableBalance = 0;
    _balanceType = 'USER';
    _holdingCounts = 0;
    _fetchCurrentStockPrice();
    _startPriceUpdateTimer();
    _checkFavoriteStatus();

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

  void _startPriceUpdateTimer() {
    _priceUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _fetchCurrentStockPrice();
    });
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
    super.dispose();
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

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {}); // 탭이 변경될 때 상태 업데이트
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
    double priceChangePercentage = double.parse(_currentStockPrice!.prdyCtrt);
    Color changeColor = priceChange >= 0 ? Colors.red : Colors.blue;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_currentStockPrice!.stckPrpr}원',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '${priceChange >= 0 ? '+' : ''}${_currentStockPrice!.prdyVrss}원 (${_currentStockPrice!.prdyCtrt}%)',
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
              Text('${_availableBalance.toStringAsFixed(0)}원',
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
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40)),
          color: Color(0xffF1F5F9)),
      child: ListTile(
        title: Text('시장가로 즉시 체결됩니다.'),
        subtitle: Text('※ 현재 보이는 가격과 다를 수 있어요!'),
      ),
    );
  }

  Widget _buildLimitOrderPrice() {
    return Column(
      children: [
        Container(
          height: 80, // 시장가 탭의 높이와 일치하도록 조정
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
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _limitPriceController,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() =>
                                  _limitPrice = double.tryParse(value) ?? 0);
                            },
                          ),
                        ),
                        // Text(
                        //   '원',
                        //   style: TextStyle(
                        //       fontSize: 24, fontWeight: FontWeight.bold),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                '나의 평균 구매가 72,800원',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
      ],
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

    askpEntries.sort((a, b) => int.parse(b.key).compareTo(int.parse(a.key)));
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
          for (var i = 0; i < 5 && i < askpEntries.length; i++)
            _buildPriceVolumeRow(
              volume: int.parse(askpEntries[i].value),
              price: int.parse(askpEntries[i].key),
              maxVolume: maxVolume,
              isAsk: true,
            ),
          _buildCurrentPriceRow(int.parse(_currentStockPrice!.stckPrpr)),
          for (var i = 0; i < 5 && i < bidpEntries.length; i++)
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
        ? widget.currentPrice * _quantity
        : _limitPrice * _quantity;
    return ListTile(
      // title: Text('주문금액'),
      trailing: Text(
        '예상 금액 ${totalAmount.toStringAsFixed(0)} 원',
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
    double currentPrice = _isMarketOrder ? widget.currentPrice : _limitPrice;
    int maxQuantity = (_availableBalance / currentPrice).floor();
    setState(() {
      _quantity = maxQuantity;
      _quantityController.text = _quantity.toString();
    });
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

  // 시장가 매수
  Widget _buildMarketBuyButton() {
    return Container(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3A2E6A),
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: () async {
          int maxQuantity = (_availableBalance / widget.currentPrice).floor();
          if (_quantity <= 0) {
            _showErrorDialog('입력 오류', '올바른 수량을 입력해주세요.');
          } else if (maxQuantity <= _quantity) {
            _showErrorDialog('입력 오류', '올바른 수량을 입력해주세요.');
          } else {
            String? accessToken = await storage.read(key: 'accessToken');
            if (accessToken == null) {
              throw Exception('No access token found');
            }
            try {
              String orderTime =
                  DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());
              Map<String, dynamic> result = await MarketPriceApi.buyMarket(
                token: accessToken,
                stockCode: widget.stockCode,
                quantity: _quantity,
                orderTime: orderTime,
              );

              // 결과 처리
              _showConfirmationSheet(result, true, true);
              // showDialog(
              //   context: context,
              //   builder: (context) => AlertDialog(
              //     title: Text('주문 완료'),
              //     content: Text('매수 주문이 성공적으로 처리되었습니다.\n'
              //         '주문 금액: ${result['totalPrice']}원\n'
              //         '주문 수량: ${result['quantity']}주'),
              //     actions: [
              //       TextButton(
              //         child: Text('확인'),
              //         onPressed: () => Navigator.of(context).pop(),
              //       ),
              //     ],
              //   ),
              // );
            } catch (e) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('오류'),
                  content: Text('주문 처리 중 오류가 발생했습니다: ${e.toString()}'),
                  actions: [
                    TextButton(
                      child: Text('확인'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            }
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
        onPressed: () async {
          int maxQuantity = (_availableBalance / widget.currentPrice).floor();
          if (_quantity <= 0) {
            _showErrorDialog('입력 오류', '올바른 수량을 입력해주세요.');
          } else if (maxQuantity <= _quantity) {
            _showErrorDialog('입력 오류', '올바른 수량을 입력해주세요.');
          } else {
            String? accessToken = await storage.read(key: 'accessToken');
            if (accessToken == null) {
              throw Exception('No access token found');
            }
            try {
              String orderTime =
                  DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());
              Map<String, dynamic> result = await FixedPriceApi.buyMarket(
                token: accessToken,
                stockCode: widget.stockCode,
                bid: _limitPrice,
                quantity: _quantity,
                orderTime: orderTime,
              );

              // 결과 처리
              _showConfirmationSheet(result, true, false);
              // showDialog(
              //   context: context,
              //   builder: (context) => AlertDialog(
              //     title: Text('주문 완료'),
              //     content: Text('매수 주문이 성공적으로 처리되었습니다.\n'
              //         '주문 금액: ${result['totalPrice']}원\n'
              //         '주문 수량: ${result['quantity']}주'),
              //     actions: [
              //       TextButton(
              //         child: Text('확인'),
              //         onPressed: () => Navigator.of(context).pop(),
              //       ),
              //     ],
              //   ),
              // );
            } catch (e) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('오류'),
                  content: Text('주문 처리 중 오류가 발생했습니다: ${e.toString()}'),
                  actions: [
                    TextButton(
                      child: Text('확인'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            }
          }
        },
        child:
            Text('매수하기', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
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
        onPressed: () async {
          if (_quantity <= 0) {
            _showErrorDialog('입력 오류', '올바른 수량을 입력해주세요.');
          } else if (_quantity > _totalHoldingQuantity) {
            _showErrorDialog('보유 수량 초과', '보유한 주식 수량보다 많이 팔 수 없습니다.');
          } else {
            String? accessToken = await storage.read(key: 'accessToken');
            if (accessToken == null) {
              throw Exception('No access token found');
            }
            try {
              String orderTime =
                  DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());
              Map<String, dynamic> result = await MarketPriceApi.sellMarket(
                token: accessToken,
                stockCode: widget.stockCode,
                quantity: _quantity,
                orderTime: orderTime,
              );

              // 결과 처리
              _showConfirmationSheet(result, false, true);
              // showDialog(
              //   context: context,
              //   builder: (context) => AlertDialog(
              //     title: Text('주문 완료'),
              //     content: Text('매도 주문이 성공적으로 처리되었습니다.\n'
              //         '주문 금액: ${result['totalPrice']}원\n'
              //         '주문 수량: ${result['quantity']}주'),
              //     actions: [
              //       TextButton(
              //         child: Text('확인'),
              //         onPressed: () => Navigator.of(context).pop(),
              //       ),
              //     ],
              //   ),
              // );
            } catch (e) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('오류'),
                  content: Text('주문 처리 중 오류가 발생했습니다: ${e.toString()}'),
                  actions: [
                    TextButton(
                      child: Text('확인'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            }
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
        onPressed: () async {
          if (_quantity <= 0) {
            _showErrorDialog('입력 오류', '올바른 수량을 입력해주세요.');
          } else if (_quantity > _totalHoldingQuantity) {
            _showErrorDialog('보유 수량 초과', '보유한 주식 수량보다 많이 팔 수 없습니다.');
          } else {
            String? accessToken = await storage.read(key: 'accessToken');
            if (accessToken == null) {
              throw Exception('No access token found');
            }
            try {
              String orderTime =
                  DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());
              Map<String, dynamic> result = await FixedPriceApi.sellMarket(
                token: accessToken,
                stockCode: widget.stockCode,
                bid: _limitPrice,
                quantity: _quantity,
                orderTime: orderTime,
              );

              // 결과 처리
              _showConfirmationSheet(result, false, false);
              // showDialog(
              //   context: context,
              //   builder: (context) => AlertDialog(
              //     title: Text('주문 완료'),
              //     content: Text('매도 주문이 성공적으로 처리되었습니다.\n'
              //         '주문 금액: ${result['totalPrice']}원\n'
              //         '주문 수량: ${result['quantity']}주'),
              //     actions: [
              //       TextButton(
              //         child: Text('확인'),
              //         onPressed: () => Navigator.of(context).pop(),
              //       ),
              //     ],
              //   ),
              // );
            } catch (e) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('오류'),
                  content: Text('주문 처리 중 오류가 발생했습니다: ${e.toString()}'),
                  actions: [
                    TextButton(
                      child: Text('확인'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            }
          }
        },
        child:
            Text('매도하기', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
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
                      '${(result['totalPrice'] / result['quantity']).toStringAsFixed(0)}원',
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
