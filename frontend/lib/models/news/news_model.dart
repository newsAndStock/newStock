// lib/models/news/news_model.dart

class News {
  final String title;
  final String date;
  final String content;
  final String press;
  final String imageUrl;
  final String category;

  News({
    required this.title,
    required this.date,
    required this.content,
    required this.press,
    required this.imageUrl,
    required this.category,
  });

  // JSON 데이터를 모델 객체로 변환하는 팩토리 메서드
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'],
      date: json['date'],
      content: json['content'],
      press: json['press'],
      imageUrl: json['image_url'],
      category: json['category'], // category 필드 추가
    );
  }

  // 모델 객체를 JSON 형식으로 변환하는 메서드 (스크랩 기능에 필요할 수 있음)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'content': content,
      'press': press,
      'image_url': imageUrl,
      'category': category, // category 필드 추가
    };
  }
}
