import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final String description;
  final String title;
  final String imagePath;
  final VoidCallback onPressed;

  const CardButton({
    Key? key,
    required this.description,
    required this.title,
    required this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40), // BorderRadius 적용
        ),
        elevation: 3, // 그림자 추가
      ),
      child: Container(
        height: 250,
        width: double.infinity, // 고정된 너비 설정
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40), // BorderRadius 맞춤
            color: const Color(0xFFF1F5F9).withOpacity(0.6), // 오버레이 색상 적용
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
