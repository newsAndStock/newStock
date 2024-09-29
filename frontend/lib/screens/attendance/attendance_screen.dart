import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/api/attendance_api_service.dart';
import 'package:frontend/widgets/attendance/attendance_calendar.dart';
import 'package:frontend/widgets/attendance/roulette_widget.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<DateTime> checkedDates = [];
  AttendanceApiService _apiService = AttendanceApiService();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCheckedDates();
  }

  // 출석 체크된 날짜를 API로부터 가져옴
  Future<void> _loadCheckedDates() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      int month = DateTime.now().month;
      List<DateTime> dates =
          await _apiService.getCheckedDates(accessToken, month);

      setState(() {
        checkedDates = dates;
      });
    } catch (e) {
      print('Failed to load attendance dates: $e');
    }
  }

  // 포인트 추가 API 호출
  Future<void> _addPoints(int points) async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      await _apiService.addPoints(accessToken, points);
      setState(() {
        checkedDates.add(DateTime.now());
      });

      _showRewardDialog(points);
    } catch (e) {
      print('Failed to add points: $e');
    }
  }

  // 포인트 적립 안내 Dialog
  void _showRewardDialog(int points) {
    showDialog(
      context: context,
      builder: (context) {
        final double screenWidth = MediaQuery.of(context).size.width;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: screenWidth * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '출석체크 완료',
                  style: TextStyle(
                    color: Color(0xFF3A2E6A), // 메인 컬러
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center, // 중앙 정렬
                ),
                SizedBox(height: 8),
                Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                SizedBox(height: 16),
                Text(
                  '$points 포인트가 적립되었습니다',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center, // 중앙 정렬
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(color: Color(0xFF3A2E6A)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('출석체크', style: TextStyle(color: Colors.black)),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),

              // 룰렛 위젯
              RouletteWidget(
                onRewardEarned: (points) {
                  _addPoints(points);
                },
              ),

              SizedBox(height: 40),

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

              // 달력 위젯
              AttendanceCalendar(
                screenWidth: screenWidth,
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                checkedDates: checkedDates,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
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
