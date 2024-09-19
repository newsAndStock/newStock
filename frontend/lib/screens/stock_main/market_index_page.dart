import 'package:flutter/material.dart';

class MarketIndexPage extends StatelessWidget {
  const MarketIndexPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주요지수'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildIndexCard('KOSPI', 2588.43, -76.20, -2.8),
          _buildIndexCard('KOSDAQ', 734.00, -26.37, -3.4),
          _buildIndexCard('NASDAQ', 17136.30, -577.32, -3.2),
          _buildIndexCard('S&P 500', 5528.93, -119.47, -2.1),
          _buildIndexCard('환율', 1342.40, 1.40, 0.1),
        ],
      ),
    );
  }

  Widget _buildIndexCard(
      String name, double value, double change, double changePercent) {
    Color backgroundColor;
    if (change > 0) {
      backgroundColor = Colors.red[50]!;
    } else if (change < 0) {
      backgroundColor = Colors.blue[50]!;
    } else {
      backgroundColor = Colors.white;
    }

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
                      '${change > 0 ? '+' : ''}${change.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        color: change > 0 ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${changePercent > 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 16,
                        color: change > 0 ? Colors.red : Colors.blue,
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
