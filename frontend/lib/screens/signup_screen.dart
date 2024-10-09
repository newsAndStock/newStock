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

  String? emailCheckMessage;
  String? nickNameCheckMessage;
  String? passwordMessage;
  String? passwordConfirmMessage;
  bool isLoading = false;
  String? errorMessage;

  bool isEmailChecked = false;
  bool isNickNameChecked = false;
  bool isPasswordValid = false;

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final passwordRegex = RegExp(
      r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$'); // 8자 이상, 특수기호, 숫자, 영어 포함

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validatePassword);
    passwordConfirmController.addListener(_validatePasswordConfirm);
  }

  @override
  void dispose() {
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = passwordController.text;
    setState(() {
      if (passwordRegex.hasMatch(password)) {
        passwordMessage = "사용 가능한 비밀번호입니다.";
        isPasswordValid = true;
      } else {
        passwordMessage = "비밀번호는 8자 이상, 특수기호, 숫자 및 영어를 포함해야 합니다.";
        isPasswordValid = false;
      }
    });
  }

  void _validatePasswordConfirm() {
    final password = passwordController.text;
    final passwordConfirm = passwordConfirmController.text;
    setState(() {
      if (password == passwordConfirm) {
        passwordConfirmMessage = "비밀번호가 일치합니다.";
      } else {
        passwordConfirmMessage = "비밀번호가 일치하지 않습니다!";
      }
    });
  }

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

    // 이메일, 닉네임 중복 확인이 완료되지 않은 경우
    if (!isEmailChecked || !isNickNameChecked) {
      setState(() {
        errorMessage = "이메일과 닉네임 중복 확인을 완료해주세요.";
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
        print(response.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SigninScreen()),
        );
      } else {
        // 회원가입 실패 시 처리
        setState(() {
          errorMessage = "회원가입 실패";
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        errorMessage = "회원가입에 오류가 발생했습니다";
      });
      print(stackTrace); // 스택 트레이스 출력
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkemail() async {
    final email = emailController.text;
    // 이메일 형식 확인
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        emailCheckMessage = "이메일 형식이 올바르지 않습니다!";
      });
      return; // 이메일 형식이 올바르지 않으면 API 요청을 보내지 않음
    }

    try {
      final response = await MemberApiService().checkEmail(email);
      if (response.statusCode == 200) {
        print(response.body);
        final isAvailable = jsonDecode(response.body) as bool;
        print(isAvailable);
        setState(() {
          if (!isAvailable) {
            emailCheckMessage = "사용 가능한 이메일입니다.";
            isEmailChecked = true;
          } else {
            emailCheckMessage = "이미 사용 중인 이메일입니다.";
            isEmailChecked = false;
          }
        });
      }
    } catch (e, stackTrace) {
      print(stackTrace);
      setState(() {
        emailCheckMessage = "이메일 중복 확인 중 오류가 발생했습니다.";
      });
    }
  }

  Future<void> _checknickname() async {
    final nickName = nickNameController.text;
    try {
      final response = await MemberApiService().checkNickname(nickName);
      if (response.statusCode == 200) {
        final isAvailable = jsonDecode(response.body) as bool;

        setState(() {
          if (!isAvailable) {
            nickNameCheckMessage = "사용 가능한 닉네임입니다.";
            isNickNameChecked = true;
          } else {
            nickNameCheckMessage = "이미 사용 중인 닉네임입니다.";
            isNickNameChecked = false;
          }
        });
      }
    } catch (e, stackTrace) {
      print(stackTrace);
      setState(() {
        nickNameCheckMessage = "닉네임 중복 확인 중 오류가 발생했습니다.";
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
                        onPressed: _checkemail,
                      ),
                      if (emailCheckMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(emailCheckMessage!,
                              style: TextStyle(
                                  color: isEmailChecked
                                      ? Colors.green
                                      : Colors.red)),
                        ),
                      const SizedBox(height: 10),
                      const Text("닉네임 *", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      _buildTextFieldWithOverlayButton(
                        hintText: "닉네임을 입력해주세요",
                        buttonText: "중복확인",
                        controller: nickNameController,
                        onPressed: _checknickname,
                      ),
                      if (nickNameCheckMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(nickNameCheckMessage!,
                              style: TextStyle(
                                  color: isNickNameChecked
                                      ? Colors.green
                                      : Colors.red)),
                        ),
                      const SizedBox(height: 15),
                      const Text("비밀번호 *", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      _buildCustomTextField(
                        hintText: "비밀번호를 입력해주세요",
                        isPassword: true,
                        controller: passwordController,
                      ),
                      if (passwordMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            passwordMessage!,
                            style: TextStyle(
                              color:
                                  isPasswordValid ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Text("비밀번호 확인 *", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      _buildCustomTextField(
                        hintText: "비밀번호를 한 번 더 입력해주세요",
                        isPassword: true,
                        controller: passwordConfirmController,
                      ),
                      if (passwordConfirmMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            passwordConfirmMessage!,
                            style: TextStyle(
                              color: passwordConfirmMessage == "비밀번호가 일치합니다."
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
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
    required VoidCallback onPressed,
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
            onPressed: onPressed,
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
