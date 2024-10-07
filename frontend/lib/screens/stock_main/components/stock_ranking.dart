import 'package:flutter/material.dart';
import 'package:frontend/api/stock_api/stock_ranking_api.dart';
import 'package:frontend/screens/stock_main/stock_detail_page.dart';

class StockItem {
  final String name;
  final String code;
  final String price;
  final String change;
  final String changePercentage;
  final String changeSign;

  StockItem({
    required this.name,
    required this.code,
    required this.price,
    required this.change,
    required this.changePercentage,
    required this.changeSign,
  });

  factory StockItem.fromApi(Map<String, dynamic> data) {
    return StockItem(
      name: data['stockName'],
      code: data['stockCode'],
      price: data['currentPrice'],
      change: data['priceChangeAmount'],
      changePercentage: data['priceChangeRate'],
      changeSign: data['priceChangeSign'],
    );
  }
}

class StockPageComponent extends StatefulWidget {
  final double? height;
  const StockPageComponent({Key? key, this.height}) : super(key: key);

  @override
  _StockPageComponentState createState() => _StockPageComponentState();
}

class _StockPageComponentState extends State<StockPageComponent> {
  final List<String> _categories = ['상승', '하락', '거래량', '시가총액'];
  String selectedCategory = '상승';
  List<StockItem> _stocks = [];
  bool _isLoading = false;
  String? _error;

  final StockRankingApi _api = StockRankingApi();

  @override
  void initState() {
    super.initState();
    _fetchStocks();
  }

  void _navigateToStockDetail(String stockCode, String stockName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailPage(
          stockCode: stockCode,
          stockName: stockName,
        ),
      ),
    );
  }

  Future<void> _fetchStocks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String category;
      switch (selectedCategory) {
        case '상승':
          category = 'topchangestocks';
          break;
        case '하락':
          category = 'bottomchangestocks';
          break;
        case '거래량':
          category = 'topvolume';
          break;
        case '시가총액':
          category = 'topcapitalizationstocks';
          break;
        default:
          category = 'topchangestocks';
      }

      final data = await _api.getStockRanking(category);
      setState(() {
        _stocks = data.map((item) => StockItem.fromApi(item)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildCategoryItem(String category) {
    bool isSelected = category == selectedCategory;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
        _fetchStocks();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3A2E6A) : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF3A2E6A) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: _categories.map((category) {
                  final index = _categories.indexOf(category);
                  return Row(
                    children: [
                      _buildCategoryItem(category),
                      if (index < _categories.length - 1)
                        const SizedBox(width: 10),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _stocks.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () => _navigateToStockDetail(
                              _stocks[index].code,
                              _stocks[index].name,
                            ),
                            child: StockComponent(
                              stockItem: _stocks[index],
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class StockComponent extends StatelessWidget {
  final StockItem stockItem;

  const StockComponent({Key? key, required this.stockItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stockItem.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(stockItem.code, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stockItem.price,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${stockItem.change} (${stockItem.changePercentage})',
                style: TextStyle(
                  color: stockItem.changeSign == '2' ? Colors.red : Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
