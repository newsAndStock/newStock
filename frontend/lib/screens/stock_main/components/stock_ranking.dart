import 'package:flutter/material.dart';

class StockItem {
  final String name;
  final String code;
  final String price;
  final String change;
  final String changePercentage;
  final String logoUrl;

  StockItem({
    required this.name,
    required this.code,
    required this.price,
    required this.change,
    required this.changePercentage,
    required this.logoUrl,
  });
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              stockItem.logoUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
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
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StockPageComponent extends StatefulWidget {
  final double? height;
  const StockPageComponent({Key? key, this.height}) : super(key: key);

  @override
  _StockPageComponentState createState() => _StockPageComponentState();
}

class _StockPageComponentState extends State<StockPageComponent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['상승', '하락', '인기', '거래량', '거래대금'];
  String selectedCategory = '상승';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<StockItem> _getStocksForCategory(String category) {
    // 테스트 데이터
    return [
      StockItem(
        name: '삼성전자',
        code: '005930',
        price: '74,300원',
        change: '+300원',
        changePercentage: '0.41%',
        logoUrl: 'https://via.placeholder.com/40',
      ),
      StockItem(
        name: '삼성전자',
        code: '005930',
        price: '74,300원',
        change: '+300원',
        changePercentage: '0.41%',
        logoUrl: 'https://via.placeholder.com/40',
      ),
      StockItem(
        name: '삼성전자',
        code: '005930',
        price: '74,300원',
        change: '+300원',
        changePercentage: '0.41%',
        logoUrl: 'https://via.placeholder.com/40',
      ),
      StockItem(
        name: '삼성전자',
        code: '005930',
        price: '74,300원',
        change: '+300원',
        changePercentage: '0.41%',
        logoUrl: 'https://via.placeholder.com/40',
      ),
    ];
  }

  Widget _buildCategoryItem(String category) {
    bool isSelected = category == selectedCategory;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
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
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: _getStocksForCategory(selectedCategory).length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) => StockComponent(
                  stockItem: _getStocksForCategory(selectedCategory)[index],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
