import 'package:flutter/material.dart';

class FavoriteStocks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('관심종목',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        SizedBox(
          height: 105, // 높이 조정
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            scrollDirection: Axis.horizontal,
            children: [
              _buildFavoriteStockItem('티디에스팜', '42,200원', '+0.5%'),
              SizedBox(width: 12),
              _buildFavoriteStockItem('아이스크림미디어', '24,500원', '-23.2%'),
              SizedBox(width: 12),
              _buildFavoriteStockItem('가나다라마바사아자차카타파하', '24,500원', '-23.2%'),
              SizedBox(width: 12),
              _buildFavoriteStockItem('아이스크림미디어', '24,500원', '-23.2%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteStockItem(String name, String price, String change) {
    final isPositive = !change.startsWith('-');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: 165,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2), // 그림자의 위치 변경
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name.length > 8 ? name.substring(0, 8) : name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Icon(Icons.favorite, color: Color(0xff312E81), size: 16),
            ],
          ),
          SizedBox(height: 8),
          Text(price, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(change,
              style: TextStyle(color: isPositive ? Colors.red : Colors.blue)),
        ],
      ),
    );
  }
}
