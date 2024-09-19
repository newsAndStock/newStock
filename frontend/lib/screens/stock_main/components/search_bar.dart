import 'package:flutter/material.dart';

class SearchBarStock extends StatelessWidget {
  const SearchBarStock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, // 고정된 높이 지정
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Center(
        child: TextField(
          decoration: InputDecoration(
            hintText: '종목명을 검색해보세요!',
            border: InputBorder.none,
            icon: Icon(Icons.search),
            isCollapsed: true, // TextField의 기본 패딩 제거
          ),
        ),
      ),
    );
  }
}
