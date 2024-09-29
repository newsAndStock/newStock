import 'package:flutter/material.dart';
import 'package:roulette/roulette.dart';
import 'dart:math';

class RouletteWidget extends StatefulWidget {
  final Function(int) onRewardEarned;

  RouletteWidget({required this.onRewardEarned});

  @override
  _RouletteWidgetState createState() => _RouletteWidgetState();
}

class _RouletteWidgetState extends State<RouletteWidget>
    with SingleTickerProviderStateMixin {
  late RouletteController _controller;
  final List<int> rewards = [100000, 50000, 30000, 10000];

  @override
  void initState() {
    super.initState();
    _controller = RouletteController(
      vsync: this,
      group: RouletteGroup.uniform(
        rewards.length,
        colorBuilder: (index) {
          if (index == 0) return Color(0xFF3A2E6A);
          if (index == 1) return Color(0xFFF1F5F9);
          if (index == 2) return Color(0xFF3A2E6A);
          return Color(0xFFF1F5F9);
        },
        textBuilder: (index) {
          if (index == 0) return '10만P';
          if (index == 1) return '5만P';
          if (index == 2) return '3만P';
          return '1만P';
        },
        textStyleBuilder: (index) {
          return TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color:
                (index == 1 || index == 3) ? Color(0xFF3A2E6A) : Colors.white,
          );
        },
      ),
    );
  }

  // 룰렛 돌리기
  void _startRoulette() {
    final randomTarget = Random().nextInt(rewards.length);
    _controller.rollTo(randomTarget, clockwise: true, offset: 0.5);
    widget.onRewardEarned(rewards[randomTarget]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                spreadRadius: 4,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Roulette(
            controller: _controller,
            style: RouletteStyle(
              dividerThickness: 4,
              centerStickerColor: Colors.white,
              centerStickSizePercent: 0.2,
              textLayoutBias: 0.7,
            ),
          ),
        ),
        Positioned(
          child: GestureDetector(
            onTap: _startRoulette,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'START',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A2E6A),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -60,
          child: Image.asset(
            'assets/images/pin.png',
            width: 90,
            height: 130,
          ),
        ),
      ],
    );
  }
}
