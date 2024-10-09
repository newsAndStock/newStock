import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/api/attendance_api_service.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/widgets/attendance/attendance_calendar.dart';
import 'package:frontend/widgets/attendance/roulette_widget.dart';
import 'package:frontend/widgets/common/custom_dialog.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<DateTime> checkedDates = [];
  bool _isAttendanceChecked = false; // 출석 완료 여부 관리하는 변수
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

        // 오늘 날짜가 출석 체크된 날짜에 포함되어 있으면 출석 완료 상태로 설정
        if (checkedDates.any((date) =>
            date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day)) {
          _isAttendanceChecked = true;
        }
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

      // API 응답 값 받기
      final response = await _apiService.addPoints(accessToken, points);

      // 상태 코드가 201이면 정상적으로 출석 완료
      if (response.statusCode == 201) {
        setState(() {
          checkedDates.add(DateTime.now());
          _isAttendanceChecked = true; // 출석 완료 상태로 설정
        });
        _showRewardDialog(points); // 포인트 적립 알림창 띄움
      } else {
        // 상태 코드가 201이 아닐 경우 이미 출석이 완료된 것으로 간주
        setState(() {
          _isAttendanceChecked = true; // 출석 완료 상태로 설정
        });
        _showAlreadyCheckedDialog(); // 출석 완료 알림창 띄움
      }
    } catch (e) {
      print('Failed to add points: $e');
    }
  }

  // 출석 완료 알림 다이얼로그
  void _showAlreadyCheckedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          title: '출석체크 완료',
          message: '이미 출석체크를 완료하셨습니다!',
          buttonText: '확인',
          onConfirm: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(),
              ),
            );
          },
        );
      },
    );
  }

  // 포인트 적립 안내 Dialog
  void _showRewardDialog(int points) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          title: '출석체크 완료',
          message: '$points 포인트가 적립되었습니다!',
          buttonText: '확인',
          onConfirm: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // 출석 완료 상태에 따라 클릭만 제어하는 룰렛 위젯
  Widget _buildRouletteWidget() {
    return GestureDetector(
      onTap: () {
        if (_isAttendanceChecked) {
          _showAlreadyCheckedDialog(); // 이미 출석이 완료되었을 때 알림창 띄움
        }
      },
      child: AbsorbPointer(
        absorbing: _isAttendanceChecked, // 출석 완료 상태라면 클릭 방지
        child: RouletteWidget(
          onRewardEarned: (points) {
            if (!_isAttendanceChecked) {
              _addPoints(points); // 출석이 완료되지 않았을 때만 포인트 적립
            }
          },
        ),
      ),
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

              // 룰렛 위젯 (출석 완료 시 클릭만 방지)
              _buildRouletteWidget(),

              SizedBox(height: 40),

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
