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
            item['price'] as String? ?? '0',
            item['difference'] as String? ?? '0',
            item['rate'] as String? ?? '0%',
          );
        },
      ),
    );
  }

  Widget _buildIndexCard(
      String name, String price, String difference, String rate) {
    bool isUp = !difference.startsWith('-');
    Color backgroundColor = isUp ? Colors.red[50]! : Colors.blue[50]!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name == 'USD' ? '원/달러 환율' : name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$difference $rate',
                      style: TextStyle(
                        fontSize: 18,
                        color: isUp ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.bold,
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
