import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/api/quiz_api_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0; // 현재 퀴즈 인덱스
  List<TextEditingController> _controllers = [];
  List<Map<String, dynamic>> _quizData = [];
  final QuizApiService _apiService = QuizApiService();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  // API에서 퀴즈 데이터를 가져오는 함수
  Future<void> _fetchQuizData() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      List<Map<String, dynamic>> quizData =
          await _apiService.getQuizData(accessToken);
      setState(() {
        _quizData = quizData;
        _initializeControllers();
      });
    } catch (e) {
      print('Failed to fetch quiz data: $e');
    }
  }

  // 퀴즈 건너뛰기 함수
  Future<void> _skipQuiz() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // 서버에 퀴즈 건너뛰기 요청
      await _apiService.skipQuiz(accessToken);

      // 다음 퀴즈 데이터 다시 불러오기
      await _fetchQuizData();
    } catch (e) {
      print('Failed to skip quiz: $e');
    }
  }

  // 퀴즈 정답 제출 함수
  Future<void> _submitAnswer() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // 사용자가 입력한 정답을 가져옴
      String userAnswer =
          _controllers.map((controller) => controller.text).join();

      // 퀴즈 ID 가져오기
      int quizId = _quizData[_currentIndex]['id'] as int;

      // 서버에 정답 제출
      bool isCorrect =
          await _apiService.submitQuizAnswer(accessToken, quizId, userAnswer);

      // 제출 후 결과에 따른 처리
      if (isCorrect) {
        int points = (_currentIndex == 2) ? 400000 : 300000; // 포인트 설정
        _showResultDialog(true, points);
      } else {
        _showResultDialog(false, 0);
      }

      // 다음 퀴즈 데이터 다시 불러오기
      await _fetchQuizData();
    } catch (e) {
      print('Failed to submit answer: $e');
    }
  }

  // 정답/오답 결과를 보여주는 다이얼로그 함수
  void _showResultDialog(bool isCorrect, int points) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCorrect)
                    Text(
                      '🎉 정답! 축하합니다',
                      style: TextStyle(
                        color: Color(0xFF3A2E6A), // 메인 컬러
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      '오답입니다!',
                      style: TextStyle(
                        color: Color(0xFF3A2E6A), // 메인 컬러
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
              SizedBox(height: 8),
              Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ],
          ),
          content: isCorrect
              ? Text(
                  '$points 포인트가 적립되었습니다',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                )
              : Text(
                  '다시 시도해보세요!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                _fetchQuizData(); // 정답일 때 새로운 퀴즈 데이터를 다시 가져옴
              },
              child: Text(
                '확인',
                style: TextStyle(color: Color(0xFF3A2E6A)),
              ),
            ),
          ],
        );
      },
    );
  }

  // word 길이에 맞춰 컨트롤러를 초기화하는 함수
  void _initializeControllers() {
    if (_quizData.isEmpty) return;

    String word = (_quizData[_currentIndex]['answer'] ?? '') as String;
    _controllers =
        List.generate(word.length, (index) => TextEditingController());
  }

  // 한 글자를 입력할 때 다음 필드로 자동 포커스 이동
  void _nextField(String value, int index) {
    RegExp completeHangul = RegExp(r'^[가-힣ㄱ-ㅎㅏ-ㅣ]+$');

    if (value.isNotEmpty && index < _controllers.length - 1) {
      FocusScope.of(context).nextFocus(); // 다음 필드로 포커스 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quizData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            '경제 퀴즈',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    String question = (_quizData[_currentIndex]['question'] ??
        'No question available') as String;
    String answer = (_quizData[_currentIndex]['answer'] ?? '') as String;

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
        elevation: 0,
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
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                '오늘의 퀴즈 ${_currentIndex + 1}/3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              question,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(answer.length, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 1),
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
                              color: const Color(0xFF3A2E6A),
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
              width: 250,
              child: OutlinedButton(
                onPressed: _submitAnswer,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  side: BorderSide(
                    color: Color(0xFF3A2E6A),
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
              onPressed: _skipQuiz,
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
