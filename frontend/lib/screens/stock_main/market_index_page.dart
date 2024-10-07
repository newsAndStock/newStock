import 'package:flutter/material.dart';

class MarketIndexPage extends StatelessWidget {
  final List<Map<String, dynamic>> indices;

  const MarketIndexPage({Key? key, required this.indices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('주요지수'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: indices.length,
        itemBuilder: (context, index) {
          final item = indices[index];
          return _buildIndexCard(
            item['name'] as String? ?? 'Unknown',
            _getCloseToday(item),
            item['price_difference'] as double? ?? 0.0,
            item['fluctuation_rate'] as double? ?? 0.0,
          );
        },
      ),
    );
  }

  double _getCloseToday(Map<String, dynamic> item) {
    return (item['ndxCloseToday'] as double?) ??
        (item['usdkrwCloseToday'] as double?) ??
        (item['kosdaqCloseToday'] as double?) ??
        (item['kospiCloseToday'] as double?) ??
        0.0;
  }

  Widget _buildIndexCard(String name, double value, double priceDifference,
      double fluctuationRate) {
    Color backgroundColor = priceDifference > 0
        ? Colors.red[50]!
        : (priceDifference < 0 ? Colors.blue[50]! : Colors.white);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${priceDifference > 0 ? '+' : ''}${priceDifference.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        color: priceDifference > 0 ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${fluctuationRate > 0 ? '+' : ''}${fluctuationRate.toStringAsFixed(2)}%)',
                      style: TextStyle(
                        fontSize: 16,
                        color: priceDifference > 0 ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
