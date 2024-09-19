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
      appBar: AppBar(
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
          _buildStockInfo(),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: '매수'),
              Tab(text: '매도'),
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
            '${widget.currentPrice.toStringAsFixed(0)}원',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '${widget.priceChange > 0 ? '+' : ''}${widget.priceChange.toStringAsFixed(0)}원 (${widget.priceChangePercentage.toStringAsFixed(2)}%)',
            style: TextStyle(
              fontSize: 16,
              color: widget.priceChange > 0 ? Colors.red : Colors.blue,
            ),
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
                  _buildAvailableBalance(),
                  _buildOrderTypeSelector(),
                  _isMarketOrder
                      ? _buildMarketOrderPrice()
                      : _buildLimitOrderPrice(),
                  _buildQuantityInput(),
                  _buildTotalAmount(),
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
    return Container(); // Placeholder
  }

  Widget _buildAvailableBalance() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.deepPurple,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('명슈릉님의 가용자산', style: TextStyle(color: Colors.white)),
          Text('1,000,000원',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOrderTypeSelector() {
    return Row(
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
    );
  }

  Widget _buildMarketOrderPrice() {
    return ListTile(
      title: Text('시장가로 즉시 체결됩니다.'),
      subtitle: Text('※ 현재 보이는 가격과 다를 수 있어요!'),
    );
  }

  Widget _buildLimitOrderPrice() {
    return Column(
      children: [
        TextField(
          controller: _limitPriceController,
          decoration: InputDecoration(
            labelText: '지정가',
            suffixText: '원',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) =>
              setState(() => _limitPrice = double.tryParse(value) ?? 0),
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
      child: Text('매수하기'),
      onPressed: () => _showConfirmationSheet(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }

  void _showConfirmationSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('주문 확인',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('삼성전자 구매 1,000주'),
              Text('주당 구매가 74,300원'),
              Text('수수료 (0.015%) 11,205원'),
              Text('총 주문 금액 74,311,205원'),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('매수하기'),
                onPressed: () {
                  // Implement buy logic
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
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
