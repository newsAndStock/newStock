import 'package:flutter/material.dart';

// News 클래스는 가정된 데이터 구조입니다. 실제로 사용할 데이터 구조에 맞게 수정하세요.
class News {
  final String title;
  final String date;
  final String press;
  final String imageUrl;

  News({
    required this.title,
    required this.date,
    required this.press,
    required this.imageUrl,
  });
}

class NewsListTile extends StatelessWidget {
  final News news;

  const NewsListTile({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.transparent, // 투명 보더
          width: 2, // 보더 두께 설정
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽: 제목과 작성일자
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2, // 제목이 두 줄을 넘지 않도록 설정
                  overflow: TextOverflow.ellipsis, // 내용이 길면 생략 표시
                ),
                const SizedBox(height: 5),
                Text(
                  news.date, // 뉴스 데이터에서 날짜 가져오기
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  news.press, // 뉴스 데이터에서 신문사 이름 가져오기
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // 오른쪽: 썸네일
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(news.imageUrl), // 뉴스 이미지 URL 사용
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
