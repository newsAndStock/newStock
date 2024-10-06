class News {
  final String newsId;
  final int? scrapId;
  final String title;
  final String createDate;
  final String content;
  final String press;
  final String imageUrl;
  final String category;

  News({
    required this.newsId,
    this.scrapId,
    required this.title,
    required this.createDate,
    required this.content,
    required this.press,
    required this.imageUrl,
    required this.category,
  });

  // JSON 데이터를 모델 객체로 변환하는 팩토리 메서드
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      newsId: json['newsId'] ?? '',
      scrapId: json['scrapId'] != null ? json['scrapId'] as int : null,
      title: json['title'] ?? '',
      createDate: json['createDate'] ?? '',
      content: json['content'] ?? '',
      press: json['press'] ?? '',
      imageUrl: json['imageUrl'] != null && json['imageUrl'].isNotEmpty
          ? json['imageUrl']
          : 'https://flexible.img.hani.co.kr/flexible/normal/970/646/imgdb/original/2024/1006/20241006501469.jpg',
      category: json['category'] ?? '',
    );
  }

  // 모델 객체를 JSON 형식으로 변환하는 메서드 (스크랩 기능에 필요할 수 있음)
  Map<String, dynamic> toJson() {
    return {
      'scrapId': scrapId,
      'newsId': newsId,
      'title': title,
      'createDate': createDate,
      'content': content,
      'press': press,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}
