import 'package:flutter/material.dart';
import 'package:frontend/api/member_api_service.dart';
import 'package:frontend/screens/signin_screen.dart';

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  Future<void> _resetPassword() async {
    final email = emailController.text;
    setState(() {});

    try {
      final response = await MemberApiService().resetPassword(email);
      if (response.statusCode == 200) {
        // 성공: 로그인 페이지로 이동
        _showAlertDialog("성공", "비밀번호 재설정 메일이 발송되었습니다.", () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SigninScreen()),
          );
        });
      } else {
        // 실패: 오류 알림창
        _showAlertDialog("오류", "비밀번호 재설정에 실패했습니다. 이메일을 확인해주세요.");
      }
    } catch (e) {
      _showAlertDialog("오류", "서버 요청 중 오류가 발생했습니다.");
    }
  }

  // 알림창을 띄우는 메서드
  void _showAlertDialog(String title, String message,
      [VoidCallback? onConfirm]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onConfirm != null) {
                  onConfirm();
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          // 스크롤 가능하도록 SingleChildScrollView 추가
          child: Column(
            children: [
              // 첫 번째 Flexible: 로고 배치
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        "assets/images/NEWstock.png",
                      ), // 로고 크기 설정
                    ],
                  ),
                ),
              ),
              // 두 번째 Flexible: 입력 폼 및 그림자 효과 있는 컨테이너
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(25), // 입력 폼 내 패딩 추가
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1, color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // 그림자 색상 및 투명도
                        offset: const Offset(5, 5), // 오른쪽 5px, 아래쪽 5px 이동
                        blurRadius: 10, // 그림자의 흐림 정도
                        spreadRadius: 1, // 그림자 퍼짐 정도
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "이메일",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      _buildCustomTextField(
                        hintText: "가입시 사용한 이메일을 입력해주세요",
                        isPassword: false,
                        controller: emailController,
                      ),
                      const SizedBox(height: 20),
                      // 로그인 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _resetPassword,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor:
                                const Color(0xFF3A2E6A), // 버튼 배경 색상
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            "비밀번호 변경",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 기본 커스텀 텍스트 필드 빌더 메서드
Widget _buildCustomTextField({
  required String hintText,
  required bool isPassword,
  required TextEditingController controller,
}) {
  final FocusNode focusNode = FocusNode();
  return Focus(
    focusNode: focusNode,
    child: Builder(
      builder: (context) {
        final hasFocus = focusNode.hasFocus;
        return TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Colors.black,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: hasFocus ? Colors.black : Colors.grey.withOpacity(0.5),
              ),
            ),
          ),
        );
      },
    ),
  );
}
