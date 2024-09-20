import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/api/member_api_service.dart';
import 'package:frontend/screens/signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  // 회원가입 로직
  Future<void> _signUp() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text;
    final nickName = nickNameController.text;
    final password = passwordController.text;
    final passwordConfirm = passwordConfirmController.text;

    // 비밀번호 일치 확인
    if (password != passwordConfirm) {
      setState(() {
        errorMessage = "비밀번호가 일치하지 않습니다!";
        isLoading = false;
      });
      return;
    }

    // API 호출
    try {
      final response =
          await MemberApiService().signUp(email, nickName, password);

      if (response.statusCode == 201) {
        // 회원가입 성공 처리 - 로그인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SigninScreen()),
        );
      } else {
        // 회원가입 실패 시 처리
        setState(() {
          errorMessage = "회원가입 실패: ${jsonDecode(response.body)['message']}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "오류가 발생했습니다: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.asset("assets/images/NEWstock.png"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 1, color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(5, 5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("이메일*", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      _buildTextFieldWithOverlayButton(
                        hintText: "이메일을 입력해주세요",
                        buttonText: "중복확인",
                        controller: emailController,
                      ),
                      const SizedBox(height: 10),
                      const Text("닉네임 *", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      _buildTextFieldWithOverlayButton(
                        hintText: "닉네임을 입력해주세요",
                        buttonText: "중복확인",
                        controller: nickNameController,
                      ),
                      const SizedBox(height: 20),
                      const Text("비밀번호 *", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      _buildCustomTextField(
                        hintText: "비밀번호를 입력해주세요",
                        isPassword: true,
                        controller: passwordController,
                      ),
                      const SizedBox(height: 20),
                      const Text("비밀번호 확인 *", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      _buildCustomTextField(
                        hintText: "비밀번호를 한 번 더 입력해주세요",
                        isPassword: true,
                        controller: passwordConfirmController,
                      ),
                      const SizedBox(height: 20),
                      if (errorMessage != null)
                        Text(errorMessage!,
                            style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: const Color(0xFF3A2E6A),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("회원가입",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
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
  Widget _buildTextFieldWithOverlayButton({
    required String hintText,
    required String buttonText,
    required TextEditingController controller,
  }) {
    final FocusNode focusNode = FocusNode();
    return Stack(
      children: [
        Focus(
          focusNode: focusNode,
          child: Builder(
            builder: (context) {
              final hasFocus = focusNode.hasFocus;
              return TextField(
                controller: controller,
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
                      color: hasFocus
                          ? Colors.black
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          right: 5,
          top: 0,
          child: ElevatedButton(
            onPressed: () {
              // 중복 확인 버튼 클릭 시 처리 로직
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: const Color(0xFFF1F5F9),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              minimumSize: const Size(0, 40),
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
}
