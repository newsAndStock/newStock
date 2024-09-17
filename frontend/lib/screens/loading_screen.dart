import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/screens/signin_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late Animation<Offset> _offsetAnimation1;
  late Animation<Offset> _offsetAnimation2;
  late Animation<Offset> _offsetAnimation3;

  @override
  void initState() {
    super.initState();

    // 첫 번째 이미지 애니메이션 설정
    _controller1 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _offsetAnimation1 = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller1,
      curve: Curves.easeInOut,
    ));

    // 두 번째 이미지 애니메이션 설정
    _controller2 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _offsetAnimation2 = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller2,
      curve: Curves.easeInOut,
    ));

    // 세 번째 이미지 애니메이션 설정
    _controller3 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _offsetAnimation3 = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller3,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 순차적 실행
    _controller1.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller2.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _controller3.forward();
    });

    // 페이지 이동을 위해 Timer 설정
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SigninScreen()));
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 첫 번째 이미지: NEW
              Transform.translate(
                offset: const Offset(0, -10),
                child: SlideTransition(
                  position: _offsetAnimation1,
                  child: Image.asset(
                    'assets/images/NEW.png',
                  ),
                ),
              ),
              // 두 번째 이미지: S
              SlideTransition(
                position: _offsetAnimation2,
                child: Image.asset(
                  'assets/images/S.png',
                ),
              ),
              // 세 번째 이미지: TOCK
              Transform.translate(
                offset: const Offset(0, 10),
                child: SlideTransition(
                  position: _offsetAnimation3,
                  child: Image.asset(
                    'assets/images/TOCK.png',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Image.asset(
            "assets/images/AppDesciption.png",
          ),
        ],
      ),
    );
  }
}
