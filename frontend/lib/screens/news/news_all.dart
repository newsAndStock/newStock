import 'package:flutter/material.dart';
import 'package:frontend/screens/news/news_detail.dart';
import 'package:frontend/widgets/common/news_category.dart';

class NewsAllScreen extends StatefulWidget {
  const NewsAllScreen({Key? key}) : super(key: key);

  @override
  _NewsAllScreenState createState() => _NewsAllScreenState();
}

class _NewsAllScreenState extends State<NewsAllScreen> {
  String selectedCategory = '금융'; // 기본 선택된 카테고리

  // 뉴스 데이터
  final Map<String, List<String>> newsByCategory = {
    '금융': [
      '저축은행, 적자는 늘었지만 연체율은 줄었다..."내년 상반기 저점 통과"',
      'LG엔솔, 40만 원선 돌파 ... 2차 전지株 일제히 강세',
      '금융시장 회복세, 경제지표 상승',
      '금리 인하 기대감 상승',
      '경제 전문가들, 금융시장 낙관'
    ],
    '증권': [
      '카카오 주가 급등 ... 증권사들 분석 강화',
      '주식시장, 새로운 변곡점 도달',
      '코스피 3,000선 회복 기대',
      '테슬라 주식, 장기 투자 매력도 상승'
    ],
    '부동산': [
      '서울 부동산 가격 다시 상승세',
      '부동산 시장, 규제 완화로 활성화 예상',
      '전세 가격, 하락세 멈춰',
      '부동산 전문가, 가격 반등 예상'
    ],
  };

  @override
  Widget build(BuildContext context) {
    // 현재 선택된 카테고리에 따른 뉴스 리스트
    List<String> newsList = newsByCategory[selectedCategory]?.toList() ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '최근 뉴스',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // 카테고리 선택 탭
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  NewsCategory(
                    categories: ['금융', '증권', '산업/재계', '부동산', '글로벌 경제', '경제 일반'],
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    // 뉴스 항목에만 패딩 적용
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 5),
                      child: GestureDetector(
                        onTap: () {
                          // 뉴스 상세 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailScreen(
                                title: newsList[index],
                                dateTime: '2024-11-22',
                                content: '22222221111111',
                                imageUrl:
                                    'https://pds.joongang.co.kr/news/component/htmlphoto_mmdata/202305/31/e48e559b-086b-40d5-8686-7583f09e5a95.jpg',
                              ),
                            ),
                          );
                        },
                        child: buildNewsListTile(newsList[index]),
                      ),
                    ),
                    if (index != newsList.length - 1) // 마지막 항목은 구분선 없음
                      Divider(
                        color: Colors.grey.shade300,
                        thickness: 0.5,
                        indent: 20, // 좌우 패딩만큼 간격 맞추기
                        endIndent: 20,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNewsListTile(String title) {
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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2, // 제목이 두 줄을 넘지 않도록 설정
                  overflow: TextOverflow.ellipsis, // 내용이 길면 생략 표시
                ),
                const SizedBox(height: 5),
                const Text(
                  '2024.08.30, 오후 12:29', // 임시 날짜와 시간 정보
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                const Text(
                  '서울경제 | 4시간 전',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
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
              image: const DecorationImage(
                image: AssetImage('assets/images/newsarticle.png'), // 이미지 경로 수정
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
