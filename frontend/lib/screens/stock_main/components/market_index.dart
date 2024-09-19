import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:frontend/screens/stock_main/market_index_page.dart';

class MarketIndex extends StatefulWidget {
  final int currentIndex;

  const MarketIndex({Key? key, required this.currentIndex}) : super(key: key);

  @override
  _MarketIndexState createState() => _MarketIndexState();
}

class _MarketIndexState extends State<MarketIndex>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<Map<String, dynamic>> _indices = [
    {
      'name': 'KOSPI',
      'value': 2588.43,
      'change': -76.20,
      'changePercent': -2.8
    },
    {
      'name': 'KOSDAQ',
      'value': 734.00,
      'change': -26.37,
      'changePercent': -3.4
    },
    {
      'name': 'NASDAQ',
      'value': 17136.30,
      'change': -577.32,
      'changePercent': -3.2
    },
    {
      'name': 'S&P 500',
      'value': 5528.93,
      'change': -119.47,
      'changePercent': -2.1
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(MarketIndex oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.85,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MarketIndexPage()),
            );
          },
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
                  offset: const Offset(0, 3), // 그림자의 위치 변경
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Opacity(
                  opacity: _animation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _animation.value)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '   ' + _indices[widget.currentIndex]['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                // Text(
                                //   _indices[widget.currentIndex]['value']
                                //       .toStringAsFixed(2),
                                //   style: const TextStyle(fontSize: 16),
                                // ),
                                const SizedBox(width: 8),
                                Text(
                                  // ${_indices[widget.currentIndex]['change'] > 0 ? '+' : ''}${_indices[widget.currentIndex]['change'].toStringAsFixed(2)}
                                  '${_indices[widget.currentIndex]['value']} (${_indices[widget.currentIndex]['changePercent'].toStringAsFixed(1)}%)   ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _indices[widget.currentIndex]
                                                ['change'] >
                                            0
                                        ? Colors.red
                                        : Colors.blue,
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
              },
            ),
          ),
        ),
      ),
    );
  }
}
