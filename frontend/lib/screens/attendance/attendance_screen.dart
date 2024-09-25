import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure storage import
import 'package:frontend/api/attendance_api_service.dart';
import 'package:roulette/roulette.dart';
import 'package:table_calendar/table_calendar.dart';
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

  // 출석체크된 날짜 리스트
  List<DateTime> checkedDates = [];
  AttendanceApiService _apiService = AttendanceApiService();
  final FlutterSecureStorage storage =
      FlutterSecureStorage(); // Secure storage instance

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = RouletteController(
      vsync: this,
      group: RouletteGroup.uniform(
        rewards.length,
        colorBuilder: (index) {
          if (index == 0) return Color(0xFF3A2E6A); // 보라색
          if (index == 1) return Color(0xFFF1F5F9); // 밝은 회색
          if (index == 2) return Color(0xFF3A2E6A); // 보라색
          return Color(0xFFF1F5F9); // 밝은 회색
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
    _loadCheckedDates(); // 출석 체크된 날짜 로드
  }

  // 출석 체크된 날짜를 API로부터 가져옴
  Future<void> _loadCheckedDates() async {
    try {
      // Secure storage에서 accessToken 가져오기
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      int month = DateTime.now().month; // 현재 달을 가져옴
      List<DateTime> dates =
          await _apiService.getCheckedDates(accessToken, month);

      print("API로부터 받은 출석 체크된 날짜: $dates");

      // UI에 반영하기 위해 상태를 업데이트
      setState(() {
        checkedDates = dates;
      });
    } catch (e) {
      print('Failed to load attendance dates: $e');
    }
  }

  // 포인트 추가 API 호출
  // Future<void> _addPoints(int points) async {
  //   try {
  //     String? accessToken = await storage.read(key: 'accessToken');
  //     if (accessToken == null) {
  //       throw Exception('No access token found');
  //     }

  //     await _apiService.addPoints(accessToken, points);
  //     print('포인트 추가 성공: $points P');
  //   } catch (e) {
  //     print('Failed to add points: $e');
  //   }
  // }

  // 룰렛 돌리기
  void _startRoulette() {
    final randomTarget = Random().nextInt(rewards.length);
    _controller.rollTo(randomTarget, clockwise: true, offset: 0.5);
    setState(() {
      rewardIndex = randomTarget;
    });

    // 포인트 추가 API 호출
    // _addPoints(rewards[randomTarget]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width; // 화면 너비를 가져옴

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('출석체크', style: TextStyle(color: Colors.black)),
        elevation: 0, // 그림자 제거
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40), // 상단 여백

              // 룰렛 UI
              Stack(
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
                  // START 버튼
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
                  // 핀 이미지 추가
                  Positioned(
                    top: -60,
                    child: Image.asset(
                      'assets/images/pin.png',
                      width: 90,
                      height: 130,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40), // 룰렛과 텍스트 사이의 여백

              // 아래 텍스트
              Text(
                '룰렛 돌리고 받은 포인트로 투자하러 가자!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A2E6A),
                ),
              ),

              SizedBox(height: 30),

              // 달력 UI (화면 너비의 80%만 차지하도록 수정)
              Container(
                width: screenWidth * 0.8, // 화면 너비의 80%만 차지
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 237, 237, 237), // 테두리 색상
                    width: 1, // 테두리 두께
                  ),
                  borderRadius: BorderRadius.circular(30), // 테두리 모서리를 둥글게 만듦
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2024, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return checkedDates.any((d) =>
                        d.year == day.year &&
                        d.month == day.month &&
                        d.day == day.day);
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false, // 다른 달의 날짜 숨기기
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF3A2E6A), // 선택된 날짜의 배경색
                      shape: BoxShape.circle, // 동그라미 모양으로 표시
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.grey[300], // 오늘 날짜 배경색
                      shape: BoxShape.circle, // 오늘 날짜도 동그라미로 표시
                    ),
                    weekendTextStyle: TextStyle(
                      color: Colors.black, // 주말 텍스트 색상
                      fontWeight: FontWeight.bold,
                    ),
                    defaultTextStyle: TextStyle(
                      color: Colors.black, // 기본 텍스트 색상
                      fontSize: 16,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekendStyle: TextStyle(
                      color: Color(0xFF3A2E6A), // 주말 텍스트 색상 변경
                    ),
                    weekdayStyle: TextStyle(
                      color: Colors.black, // 평일 텍스트 색상
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false, // 2 weeks 버튼 숨기기
                    titleCentered: true, // 달력 제목 중앙 정렬
                    titleTextStyle: TextStyle(
                      fontSize: 20, // 월 이름 폰트 크기
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A2E6A), // 월 이름 텍스트 색상
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors.black, // 이전 달 화살표 색상
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors.black, // 다음 달 화살표 색상
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
              ),

              SizedBox(height: 20),

              // 하단 안내 텍스트
              Text(
                '룰렛 이벤트에 참여하면 자동 출석처리 됩니다.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
