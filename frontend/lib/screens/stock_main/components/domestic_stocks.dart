import 'package:flutter/material.dart';

class DomesticStocks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('국내 실시간 랭킹',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRankingTab('상승', isSelected: true),
              const SizedBox(width: 8),
              _buildRankingTab('인기'),
              const SizedBox(width: 8),
              _buildRankingTab('거래량'),
              const SizedBox(width: 8),
              _buildRankingTab('거래대금'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              _buildStockItem('삼성전자', '005930', '74,300원', '+300원 (0.41%)'),
              _buildStockItem('삼성전자', '005930', '74,300원', '+300원 (0.41%)'),
              _buildStockItem('삼성전자', '005930', '74,300원', '+300원 (0.41%)'),
              _buildStockItem('삼성전자', '005930', '74,300원', '+300원 (0.41%)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingTab(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStockItem(
      String name, String code, String price, String change) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Image.asset('assets/samsung_logo.png', width: 40, height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(code,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(change, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ],
      ),
    );
  }
}
