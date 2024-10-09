import 'package:flutter/material.dart';

// 재사용 가능한 Dialog 컴포넌트
class CustomDialog extends StatelessWidget {
  final String title; // 다이얼로그 제목
  final String message; // 다이얼로그 본문
  final String buttonText; // 버튼 텍스트
  final VoidCallback onConfirm; // 버튼 클릭 시 실행되는 콜백 함수

  const CustomDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF3A2E6A),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onConfirm,
              child: Text(
                buttonText,
                style: const TextStyle(color: Color(0xFF3A2E6A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
