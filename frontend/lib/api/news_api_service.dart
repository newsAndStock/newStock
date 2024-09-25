// lib/services/news/news_service.dart

import 'package:frontend/models/news/news_model.dart';
import 'package:frontend/data/news/mock_news_data.dart';

class NewsService {
  // 임시 데이터를 불러오는 메서드
  Future<List<News>> fetchNews() async {
    // 실제 API가 아니라 로컬 데이터를 사용하는 부분
    return mockNewsData.map((data) => News.fromJson(data)).toList();
  }
}
