import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/api/quiz_api_service.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/widgets/common/custom_dialog.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuizNumber = 1; // 현재 퀴즈 번호 (1부터 시작)
  TextEditingController _inputController =
      TextEditingController(); // 입력 필드 컨트롤러
  FocusNode _focusNode = FocusNode(); // 숨겨진 입력 필드의 포커스 노드
  final int _quizCount = 3; // 하루에 풀 수 있는 퀴즈 개수 고정
  Map<String, dynamic>? _currentQuiz; // 현재 퀴즈 데이터 (서버로부터 받는 한 문제)
  final QuizApiService _apiService = QuizApiService();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String? _accessToken; // 저장된 액세스 토큰

  @override
  void initState() {
    super.initState();
    _loadAccessTokenAndQuiz();
  }

  // 1. 액세스 토큰을 불러오고 퀴즈 상태를 불러옴
  Future<void> _loadAccessTokenAndQuiz() async {
    _accessToken = await _getAccessToken(); // 저장된 액세스 토큰 불러오기

    if (_accessToken == null) {
      print("No access token found. Redirecting to login...");
    } else {
      _loadQuizNumberAndFetchQuiz(); // 액세스 토큰을 기반으로 퀴즈 번호를 불러옴
    }
  }

  // 저장된 액세스 토큰 불러오기
  Future<String?> _getAccessToken() async {
    return await storage.read(key: 'accessToken'); // 저장된 accessToken
  }

  // 마지막 퀴즈 번호를 불러오고 서버에서 새로운 퀴즈 데이터를 가져오는 함수
  Future<void> _loadQuizNumberAndFetchQuiz() async {
    try {
      String? savedQuizNumber =
          await storage.read(key: '${_accessToken}_currentQuizNumber');

      if (savedQuizNumber == null ||
          int.tryParse(savedQuizNumber) == null ||
          int.parse(savedQuizNumber) > _quizCount) {
        _currentQuizNumber = 1;
        await storage.write(
            key: '${_accessToken}_currentQuizNumber', value: '1'); // 1로 초기화
      } else {
        _currentQuizNumber = int.parse(savedQuizNumber);
      }

      if (_currentQuizNumber > _quizCount) {
        _showCompletionOrErrorDialog('오늘의 퀴즈를 모두 풀었습니다!');
      } else {
        _fetchNewQuiz();
      }
    } catch (e) {
      print('Failed to load quiz number: $e');
      _currentQuizNumber = 1; // 오류 시 퀴즈 번호 초기화
    }
  }

  // 서버에서 새로운 퀴즈 데이터를 가져오는 함수 (단일 객체 처리)
  Future<void> _fetchNewQuiz() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      Map<String, dynamic> quizData =
          await _apiService.getQuizData(accessToken);

      // 서버로부터 받은 응답에서 "code"가 4008인 경우 처리
      if (quizData.containsKey('code') && quizData['code'] == '4008') {
        print("오늘 퀴즈 완료!");
        _showCompletionOrErrorDialog('오늘의 퀴즈를 모두 풀었습니다!');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        return; // 함수를 종료합니다.
      }

      setState(() {
        _currentQuiz = quizData; // 퀴즈 데이터 설정
        _inputController.clear(); // 입력 필드 초기화
      });
    } catch (e) {
      print('Failed to fetch quiz data: $e');

      _showCompletionOrErrorDialog('오늘의 퀴즈를 모두 풀었습니다!');
    }
  }

  // 퀴즈 정답 제출 함수
  Future<void> _submitAnswer() async {
    if (_currentQuiz == null || _currentQuizNumber > _quizCount) {
      return;
    }

    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      String userAnswer = _inputController.text;
      int quizId = _currentQuiz!['id']; // 현재 퀴즈의 ID

      bool isCorrect =
          await _apiService.submitQuizAnswer(accessToken, quizId, userAnswer);

      if (isCorrect) {
        int points = (_currentQuizNumber == _quizCount) ? 400000 : 300000;
        _showResultDialog(true, points);
      } else {
        _showResultDialog(false, 0);
      }

      _moveToNextQuiz(isCorrect);
    } catch (e) {
      print('Failed to submit answer: $e');
      _showCompletionOrErrorDialog('정답을 제출하는 중 오류가 발생했습니다.');
    }
  }

  // 퀴즈 건너뛰기 함수
  Future<void> _skipQuiz() async {
    if (_currentQuiz == null || _currentQuizNumber > _quizCount) {
      return;
    }

    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      await _apiService.skipQuiz(accessToken);
      _moveToNextQuiz(false); // 건너뛰기 했으므로 오답 처리
    } catch (e) {
      print('Failed to skip quiz: $e');
      _showCompletionOrErrorDialog('퀴즈를 건너뛰는 중 오류가 발생했습니다.');
    }
  }

  // 퀴즈를 제출하거나 건너뛸 때 다음 퀴즈로 이동
  void _moveToNextQuiz(bool isAnswerCorrect) async {
    setState(() {
      if (_currentQuizNumber < _quizCount) {
        _currentQuizNumber++;
        _saveQuizNumber(); // 현재 퀴즈 번호 저장
        _fetchNewQuiz();
      } else {
        _saveQuizNumber(); // 마지막 퀴즈 번호 저장
        _showCompletionDialogWithPoints(isAnswerCorrect);
      }
    });
  }

  // 현재 퀴즈 번호를 저장
  Future<void> _saveQuizNumber() async {
    await storage.write(
        key: '${_accessToken}_currentQuizNumber',
        value: _currentQuizNumber.toString());
  }

  // 포인트 적립 다이얼로그를 먼저 보여준 후, 완료 창을 띄우는 함수
  void _showCompletionDialogWithPoints(bool isAnswerCorrect) {
    if (isAnswerCorrect) {
      _showResultDialog(true, 400000, isLastQuiz: true);
    } else {
      _showResultDialog(false, 0, isLastQuiz: true);
    }
  }

  // 정답/오답 결과를 보여주는 다이얼로그
  void _showResultDialog(bool isCorrect, int points,
      {bool isLastQuiz = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          title: isCorrect ? '🎉정답입니다' : '😭오답입니다',
          message: isCorrect ? '$points 포인트가 적립되었습니다!' : '다음 문제로 넘어갈게요!',
          buttonText: '확인',
          onConfirm: () {
            Navigator.of(context).pop();
            if (isLastQuiz) {
              _showCompletionOrErrorDialog('오늘의 퀴즈를 모두 풀었습니다!');
            }
          },
        );
      },
    );
  }

  // 오류 및 완료 다이얼로그
  void _showCompletionOrErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          title: '오늘의 퀴즈 완료',
          message: message,
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

  // 입력된 텍스트를 글자별로 박스에 나누어 보여주는 함수
  Widget _buildAnswerBoxes(String answer) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
        children: List.generate(answer.length, (index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 5), // 박스 간격 10 (양쪽 5씩)
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: Text(
                    _inputController.text.length > index
                        ? _inputController.text[index]
                        : '',
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuiz == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            '경제 퀴즈',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 퀴즈 데이터에서 현재 퀴즈 정보를 가져옴
    String question = _currentQuiz!['question'] ?? 'No question available';
    String answer = _currentQuiz!['answer'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '경제 퀴즈',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.8, // 너비를 80%로 설정
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A2E6A),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '오늘의 퀴즈 $_currentQuizNumber/$_quizCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  question,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildAnswerBoxes(answer),
                const SizedBox(height: 20),
                TextField(
                  controller: _inputController,
                  focusNode: _focusNode,
                  maxLength: answer.length,
                  textAlign: TextAlign.center,
                  showCursor: false, // 커서를 숨김
                  style: const TextStyle(
                    color: Colors.transparent, // 입력된 텍스트도 투명하게 설정
                    height: 0.01, // 줄 간격 최소화
                  ),
                  decoration: const InputDecoration(
                    counterText: '', // 글자 수 표시 없애기
                    border: InputBorder.none, // 기본 테두리 제거
                    enabledBorder: InputBorder.none, // 비활성화 시 테두리 제거
                    focusedBorder: InputBorder.none, // 포커스 상태 테두리 제거
                    disabledBorder: InputBorder.none, // 비활성화 상태 테두리 제거
                    errorBorder: InputBorder.none, // 에러 상태 테두리 제거
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 0),
                SizedBox(
                  width: 250,
                  child: OutlinedButton(
                    onPressed: _submitAnswer,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      side: const BorderSide(
                        color: Color(0xFF3A2E6A),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
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
                  child: const Text(
                    '모르겠어요 넘어갈래요!',
                    style: TextStyle(
                      color: Colors.black,
                    ),
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
