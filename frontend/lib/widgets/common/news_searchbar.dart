import 'package:flutter/material.dart';

class NewsSearchbar extends StatelessWidget {
  const NewsSearchbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // 그림자의 위치 변경
          ),
        ],
      ),
      child: const Center(
        child: TextField(
          decoration: InputDecoration(
            hintText: '키워드를 검색해보세요!',
            hintStyle: TextStyle(color: const Color(0xFFBDBDBD)),
            border: InputBorder.none,
            icon: Icon(Icons.search),
            isCollapsed: true, // TextField의 기본 패딩 제거
          ),
        ),
      ),
    );
  }
}
