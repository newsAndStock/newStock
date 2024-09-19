import 'package:flutter/material.dart';

class RecommendedNews extends StatelessWidget {
  final double height;

  const RecommendedNews({Key? key, this.height = 300}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('추천뉴스',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _buildNewsItem(
                  'LG엔솔, 40만 원선 돌파 ... 2차 전지株 일제히 강세',
                  '서울경제 | 4시간 전',
                  'assets/news_image.png',
                ),
                _buildNewsItem(
                  'LG엔솔, 40만 원선 돌파 ... 2차 전지株 일제히 강세',
                  '서울경제 | 4시간 전',
                  'assets/news_image.png',
                ),
                _buildNewsItem(
                  'LG엔솔, 40만 원선 돌파 ... 2차 전지株 일제히 강세',
                  '서울경제 | 4시간 전',
                  'assets/news_image.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(String title, String source, String imagePath) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  source,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
