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
    final String state = indexData['state'] as String? ?? 'Unknown';

    // 상승/하락 여부 확인
    bool isUp = state == '상승';

    // difference에서 숫자와 퍼센트 추출
    List<String> parts = difference.split(' ');
    String numericDifference = parts.isNotEmpty ? parts[0] : '0';
    String percentChange = parts.length > 1 ? parts[1] : '0%';

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
                  '   ${name == '환율' ? '원/달러 환율' : name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$price ($percentChange)   ',
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
