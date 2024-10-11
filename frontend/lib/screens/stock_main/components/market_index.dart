import 'package:flutter/material.dart';

class MarketIndex extends StatelessWidget {
  final Map<String, dynamic> indexData;
  final VoidCallback onTap;

  const MarketIndex({Key? key, required this.indexData, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = indexData['name'] as String? ?? 'Unknown';
    final String price = indexData['price'] as String? ?? '0';
    final String difference = indexData['difference'] as String? ?? '0';
    final String rate = indexData['rate'] as String? ?? '0%';

    // 상승/하락 여부 확인
    bool isUp = !difference.startsWith('-');

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.85,
          child: Container(
            height: 50,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '   ${name == 'USD' ? '원/달러 환율' : name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$price $rate   ',
                  style: TextStyle(
                    fontSize: 16,
                    color: isUp ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
