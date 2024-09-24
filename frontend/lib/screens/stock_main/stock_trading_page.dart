import 'package:flutter/material.dart';

class StockTradingPage extends StatefulWidget {
  final String stockName;
  final double currentPrice;
  final double priceChange;
  final double priceChangePercentage;

  const StockTradingPage({
    Key? key,
    required this.stockName,
    required this.currentPrice,
    required this.priceChange,
    required this.priceChangePercentage,
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
  final double _availableBalance = 1000000;
  bool _showKeypad = false;
  bool _showPriceVolumeChart = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _limitPrice = widget.currentPrice;
    _limitPriceController.text = widget.currentPrice.toStringAsFixed(0);
    _quantityFocusNode.addListener(_onQuantityFocusChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityController.dispose();
    _quantityFocusNode.removeListener(_onQuantityFocusChange);
    _quantityFocusNode.dispose();
    _limitPriceController.dispose();
    super.dispose();
  }

  void _onQuantityFocusChange() {
    setState(() {
      _showKeypad = _quantityFocusNode.hasFocus;
      if (!_isMarketOrder) {
        _showPriceVolumeChart = !_quantityFocusNode.hasFocus;
      }
    });
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
              // Implement favorite functionality
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
      bottomNavigationBar: _buildBuyButton(),
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
    // Similar to _buildBuyTab(), but with sell-specific modifications
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
                ],
              ),
            ),
          ),
        );
      },
    ); // Placeholder
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
              Text('띵슈롱님의 가용자산',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
              Text('1,000,000원',
                  style: TextStyle(color: Colors.white, fontSize: 23)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOrderTypeSelector() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          color: Color(0xffF1F5F9)),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<bool>(
              title: Text('시장가'),
              value: true,
              groupValue: _isMarketOrder,
              onChanged: (value) => setState(() => _isMarketOrder = value!),
            ),
          ),
          Expanded(
            child: RadioListTile<bool>(
              title: Text('지정가'),
              value: false,
              groupValue: _isMarketOrder,
              onChanged: (value) => setState(() => _isMarketOrder = value!),
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      // 높이 제한을 설정합니다. 필요에 따라 조정하세요.
      height: 240, // 예시 높이
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < 7; i++)
              _buildPriceVolumeRow(
                sellVolume: 48459 - i * 1000,
                price: 74800 - i * 100,
                buyVolume: 71096 + i * 100000,
                isCurrentPrice: i == 3,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceVolumeRow({
    required int sellVolume,
    required int price,
    required int buyVolume,
    bool isCurrentPrice = false,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _limitPrice = price.toDouble();
          _limitPriceController.text = price.toString();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        color: isCurrentPrice ? Colors.grey[200] : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                sellVolume.toString(),
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.blue),
              ),
            ),
            Container(
              width: 80,
              alignment: Alignment.center,
              child: Text(
                price.toString(),
                style: TextStyle(
                  fontWeight:
                      isCurrentPrice ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Expanded(
              child: Text(
                buyVolume.toString(),
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInput() {
    return TextField(
      controller: _quantityController,
      focusNode: _quantityFocusNode,
      decoration: InputDecoration(
        labelText: '주문수량',
        suffixText: '주',
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) =>
          setState(() => _quantity = int.tryParse(value) ?? 0),
    );
  }

  Widget _buildTotalAmount() {
    double totalAmount = _isMarketOrder
        ? widget.currentPrice * _quantity
        : _limitPrice * _quantity;
    return ListTile(
      title: Text('주문금액'),
      trailing: Text('${totalAmount.toStringAsFixed(0)}원'),
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
              child: Text('최대'),
            );
          }
          if (index == 10) return Center(child: Text('0'));
          if (index == 11) {
            return TextButton(
              onPressed: _deleteLastDigit,
              child: Icon(Icons.backspace),
            );
          }
          return TextButton(
            onPressed: () => _updateQuantity(index + 1),
            child: Text('${index + 1}'),
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
      _quantityController.text = _quantity.toString();
    });
  }

  Widget _buildBuyButton() {
    return ElevatedButton(
      child: Text(
        '매수하기',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => _showConfirmationSheet(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3A2E6A),
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }

  void _showConfirmationSheet() {
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
                '삼성전자',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '구매 1,000주',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '주당 구매가',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        '74,300원',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )
                    ],
                  )),
              FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '수수료(0.015%)',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        '11,205원',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )
                    ],
                  )),
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
                        '74,311,205원',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )
                    ],
                  )),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text(
                  '매수하기',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  // Implement buy logic
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
