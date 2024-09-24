import 'package:flutter/material.dart';
import 'package:roulette/roulette.dart';
import 'dart:math';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late RouletteController _controller;
  final List<int> rewards = [100000, 50000, 30000, 10000];
  int rewardIndex = 0;

  @override
  void initState() {
    super.initState();

    // RouletteController 초기화
    _controller = RouletteController(
      vsync: this,
      group: RouletteGroup.uniform(
        rewards.length,
        colorBuilder: (index) {
          // 색상을 순서에 맞게 설정
          if (index == 0) return Color(0xFF3A2E6A);
          if (index == 1) return Color(0xFFF1F5F9);
          if (index == 2) return Color(0xFF3A2E6A);
          return Color(0xFFF1F5F9);
        },
        textBuilder: (index) {
          // 텍스트를 섹션에 맞게 설정
          if (index == 0) return '10만P';
          if (index == 1) return '5만P';
          if (index == 2) return '3만P';
          return '1만P';
        },
        textStyleBuilder: (index) {
          return TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color:
                (index == 1 || index == 3) ? Color(0xFF3A2E6A) : Colors.white,
          );
        },
      ),
    );
  }

  void _startRoulette() {
    // 포인트를 미리 설정할 필요 없음
    final randomTarget = Random().nextInt(rewards.length);
    // 섹션의 중앙으로 멈추도록 offset을 설정
    _controller.rollTo(randomTarget, clockwise: true, offset: 0.5);
    setState(() {
      rewardIndex = randomTarget;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('출석 체크'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 룰렛 UI
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: Roulette(
                  controller: _controller,
                  style: RouletteStyle(
                    dividerThickness: 4,
                    centerStickerColor: Colors.white,
                    centerStickSizePercent: 0.2, // 중앙에 있는 동그라미 크기
                    textLayoutBias: 0.7, // 텍스트 위치 조정
                  ),
                ),
              ),
              // 중앙에 있는 START 버튼을 GestureDetector로 바꾸어 클릭 이벤트 연결
              Positioned(
                child: GestureDetector(
                  onTap: _startRoulette, // START 버튼 클릭 시 룰렛 돌리기
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A2E6A),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 이미지로 커스텀된 핀 추가
              Positioned(
                top: -38, // 핀을 룰렛 위에 배치
                child: Image.asset(
                  'assets/images/pin.png', // 추가한 핀 이미지
                  width: 90, // 이미지 크기 조정
                  height: 130,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Text(
          //   '당첨된 포인트: ${rewards[rewardIndex]} P',
          //   style: TextStyle(fontSize: 24),
          // ),
        ],
      ),
    );
  }
}
