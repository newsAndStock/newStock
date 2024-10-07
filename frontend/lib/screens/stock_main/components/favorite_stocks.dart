import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteStocks extends StatelessWidget {
  final Map<String, dynamic>? stocksData;
  final Function(String stockName, String stockCode) onStockTap;

  const FavoriteStocks({
    Key? key,
    required this.stocksData,
    required this.onStockTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stocksData == null || stocksData!['stocks'].isEmpty) {
      return Container(
        height: 105,
        alignment: Alignment.center,
        child: Text('관심종목이 없습니다.', style: TextStyle(fontSize: 16)),
      );
    }

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
            children: stocksData!['stocks'].map<Widget>((stock) {
              return GestureDetector(
                onTap: () =>
                    onStockTap(stock['name'], stock['stockCode']), // 수정된 부분
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildFavoriteStockItem(
                    stock['name'],
                    stock['info']['currentPrice'] + '원',
                    stock['info']['changedPrice'] + '원',
                  ),
                ),
              );
            }).toList(),
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
            offset: const Offset(0, 2),
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
