import 'package:flutter/material.dart';
import 'package:frontend/data/quiz/quiz_data.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 7; // 현재 퀴즈 인덱스
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  // word 길이에 맞춰 컨트롤러를 초기화하는 함수
  void _initializeControllers() {
    String word = quizData[_currentIndex]['word'] as String;
    _controllers =
        List.generate(word.length, (index) => TextEditingController());
  }

  // 한 글자를 입력할 때 다음 필드로 자동 포커스 이동
  void _nextField(String value, int index) {
    if (value.length == 1 && index < _controllers.length - 1) {
      FocusScope.of(context).nextFocus(); // 다음 필드로 포커스 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    String word = quizData[_currentIndex]['word'] as String;
    String description = quizData[_currentIndex]['description'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '경제 퀴즈',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0, // 그림자 제거
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3A2E6A),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 1), // 그림자 위치
                  ),
                ],
              ),
              child: Text(
                '오늘의 퀴즈 1/3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              description,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(word.length, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // skyblue 배경색
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 1), // 그림자 위치
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controllers[index],
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: const Color(0xFF3A2E6A), // 포커스 시 보더 색상
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) => _nextField(value, index),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 250, // 버튼을 가로로 꽉 차게
              child: OutlinedButton(
                onPressed: () {
                  // 제출하기 버튼 액션
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  side: BorderSide(
                    color: Color(0xFF3A2E6A), // 보더 색상
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  '제출하기',
                  style: TextStyle(
                    color: Color(0xFF3A2E6A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // 넘어가기 버튼 액션
              },
              child: Text(
                '모르겠어요 넘어갈래요!',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
