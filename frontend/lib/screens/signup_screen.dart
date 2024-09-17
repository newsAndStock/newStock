import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
                      // 이메일 입력 필드 및 버튼
                      const Text(
                        "이메일*",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextFieldWithOverlayButton(
                        hintText: "이메일을 입력해주세요",
                        buttonText: "중복체크",
                      ), // 이메일 필드
                      const SizedBox(height: 10),
                      // 닉네임 입력 필드 및 버튼
                      const Text(
                        "닉네임 *",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      _buildTextFieldWithOverlayButton(
                        hintText: "닉네임을 입력해주세요",
                        buttonText: "중복체크",
                      ), // 닉네임 필드
                      const SizedBox(height: 20),
                      // 비밀번호 입력 필드
                      const Text(
                        "비밀번호 *",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      _buildCustomTextField(
                          hintText: "비밀번호를 입력해주세요",
                          isPassword: true), // 비밀번호 필드
                      const SizedBox(height: 20),
                      const Text(
                        "비밀번호 확인 *",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      _buildCustomTextField(
                          hintText: "비밀번호를 한 번 더 입력해주세요",
                          isPassword: true), // 비밀번호 확인 필드
                      const SizedBox(height: 20),
                      // 회원가입 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor:
                                const Color(0xFF3A2E6A), // 버튼 배경 색상
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            "회원가입",
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

  // 커스텀 텍스트 필드 + 버튼 빌더 메서드
  // 텍스트 필드와 중복확인 버튼을 겹쳐서 배치하는 메서드
  Widget _buildTextFieldWithOverlayButton({
    required String hintText,
    required String buttonText,
  }) {
    final FocusNode focusNode = FocusNode();
    return Stack(
      children: [
        Focus(
          focusNode: focusNode,
          child: Builder(builder: (context) {
            final hasFocus = focusNode.hasFocus;
            return TextField(
              decoration: InputDecoration(
                hintText: hintText,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ), // 크기 줄이기
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Colors.black, // 포커스 상태일 때 검정색 테두리
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: hasFocus
                        ? Colors.black
                        : Colors.grey.withOpacity(0.5), // 포커스 상태에 따른 색상 변경
                  ),
                ),
              ),
            );
          }),
        ),
        Positioned(
          right: 5, // 오른쪽 끝에 위치하도록 설정
          top: 0, // 텍스트필드 안에서 수직으로 위치
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: const Color(0xFFF1F5F9), // 버튼 배경 색상
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              minimumSize: const Size(0, 40), // 버튼 크기 조정
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
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
      child: Builder(builder: (context) {
        final hasFocus = focusNode.hasFocus;
        return TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ), // 크기 줄이기
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Colors.black, // 포커스 상태일 때 검정색 테두리
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: hasFocus
                    ? Colors.black
                    : Colors.grey.withOpacity(0.5), // 포커스 상태에 따른 색상 변경
              ),
            ),
          ),
        );
      }),
    );
  }
}
