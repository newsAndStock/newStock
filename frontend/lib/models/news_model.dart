class News {
  final String newsId;
  final int? scrapId;
  final String title;
  final String createDate;
  final String date;
  final String content;
  final String press;
  final String imageUrl;
  final String category;

  News({
    required this.newsId,
    this.scrapId,
    required this.title,
    required this.createDate,
    required this.date,
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
      date: json['date'] ?? '',
      content: json['content'] ?? '',
      press: json['press'] ?? '',
      imageUrl: json['imageUrl'] != null
          ? json['imageUrl']
          : 'https://image.zdnet.co.kr/2024/10/04/3f073eac132912442902ec1d98a9d7b3.jpg',
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
      'date': date,
      'content': content,
      'press': press,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  // copyWith 메서드 추가
  News copyWith({
    String? newsId,
    int? scrapId,
    String? title,
    String? createDate,
    String? date,
    String? content,
    String? press,
    String? imageUrl,
    String? category,
  }) {
    return News(
      newsId: newsId ?? this.newsId,
      scrapId: scrapId ?? this.scrapId,
      title: title ?? this.title,
      createDate: createDate ?? this.createDate,
      date: date ?? this.date,
      content: content ?? this.content,
      press: press ?? this.press,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }
}
