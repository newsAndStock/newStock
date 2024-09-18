import 'package:flutter/material.dart';
import 'package:frontend/screens/find_password_screen.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/signup_screen.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

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
                        hintText: "이메일을 입력해주세요",
                        isPassword: false,
                      ), // 이메일 필드
                      const SizedBox(height: 20),
                      const Text(
                        "비밀번호",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      _buildCustomTextField(
                        hintText: "비밀번호를 입력해주세요",
                        isPassword: true,
                      ), // 비밀번호 필드
                      const SizedBox(height: 20),
                      // 로그인 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor:
                                const Color(0xFF3A2E6A), // 버튼 배경 색상
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            "로그인",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 비밀번호 찾기 링크
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("비밀번호를 잊으셨나요? "),
                          GestureDetector(
                            onTap: () {
                              // PasswordFindScreen으로 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FindPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "비밀번호 찾기",
                              style: TextStyle(
                                color: Color(0xFF3A2E6A),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 회원가입 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("아직 회원이 아니시라면? "),
                  GestureDetector(
                    onTap: () {
                      // SignUpScreen으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "회원가입하러 가기",
                      style: TextStyle(
                        color: Color(0xFF3A2E6A),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 기본 커스텀 텍스트 필드 빌더 메서드
  Widget _buildCustomTextField({
    required String hintText,
    required bool isPassword,
  }) {
    final FocusNode focusNode = FocusNode();
    return Focus(
      focusNode: focusNode,
      child: Builder(
        builder: (context) {
          final hasFocus = focusNode.hasFocus;
          return TextField(
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
}
