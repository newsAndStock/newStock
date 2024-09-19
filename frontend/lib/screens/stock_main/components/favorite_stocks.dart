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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFavoriteStockItem('티디에스팜', '42,200원', '+0.5%'),
              SizedBox(width: 12),
              _buildFavoriteStockItem('아이스크림미디어', '24,500원', '-23.2%'),
              // 더 많은 관심종목 아이템을 추가할 수 있습니다.
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteStockItem(String name, String price, String change) {
    final isPositive = !change.startsWith('-');
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.favorite, color: Colors.purple, size: 16),
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
