import 'package:flutter/material.dart';

class MarketIndex extends StatelessWidget {
  final Map<String, dynamic> indexData;
  final VoidCallback onTap;

  const MarketIndex({Key? key, required this.indexData, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = indexData['name'] as String? ?? 'Unknown';
    final double value = _getCloseToday(indexData);
    final double priceDifference =
        indexData['price_difference'] as double? ?? 0.0;
    final double fluctuationRate =
        indexData['fluctuation_rate'] as double? ?? 0.0;

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
                  '   $name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(2)} (${fluctuationRate.toStringAsFixed(2)}%)   ',
                  style: TextStyle(
                    fontSize: 16,
                    color: priceDifference > 0 ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
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
}
