import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onPressed;

  const NewsCard({
    required this.imageUrl,
    required this.title,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // 클릭 시 실행할 함수
      style: ElevatedButton.styleFrom(
        elevation: 3,
        padding: const EdgeInsets.all(0), // 내부 패딩 제거
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      child: Container(
        width: 300, // 가로 고정 값
        height: 300, // 세로 고정 값
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover, // 이미지를 컨테이너에 맞춤
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2, // 타이틀이 두 줄까지 표시되도록 설정
              overflow: TextOverflow.ellipsis, // 긴 텍스트는 말줄임표로 처리
            ),
          ),
        ),
      ),
    );
  }
}
