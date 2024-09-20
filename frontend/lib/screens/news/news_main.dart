import 'package:flutter/material.dart';
import 'package:frontend/screens/main_screen.dart';
import 'package:frontend/screens/news/news_all.dart';
import 'package:frontend/screens/news/news_detail.dart';
import 'package:frontend/widgets/common/news_card.dart';
import 'package:frontend/widgets/common/news_category.dart';

class NewsMainScreen extends StatefulWidget {
  const NewsMainScreen({Key? key}) : super(key: key);

  @override
  _NewsMainScreenState createState() => _NewsMainScreenState();
}

class _NewsMainScreenState extends State<NewsMainScreen> {
  String selectedCategory = '금융'; // 기본 선택된 카테고리
  int selectedNewsIndex = -1; // 선택된 뉴스 인덱스 (-1: 선택 안 됨)

  // 뉴스 데이터
  final Map<String, List<String>> newsByCategory = {
    '금융': [
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
    // 현재 선택된 카테고리에 따른 뉴스 리스트 (4개만 가져오기)
    List<String> newsList =
        newsByCategory[selectedCategory]?.take(4).toList() ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(),
                    ),
                  );
                },
                child: SizedBox(
                  height: 20, // Adjust this size for the logo
                  child: Image.asset(
                    'assets/images/NEWstock.png', // Ensure this is the correct path to your image
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to notifications page
                },
                child: const SizedBox(
                  height: 30, // Adjust the size for the notification icon
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 30, // You can adjust the size of the icon
                    color: Colors.black, // Change color if necessary
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: const Color(0xFFf1f5f9),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 16), // 내장 padding 추가
                  child: Row(
                    children: const [
                      Icon(Icons.search),
                      SizedBox(width: 10),
                      Text(
                        '종목명을 검색해보세요!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 최근 뉴스와 전체보기 버튼을 한 줄에 배치
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '최근 뉴스',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 전체보기 클릭 시 페이지 이동 처리
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NewsAllScreen(), // 전체 뉴스 페이지로 이동
                        ),
                      );
                    },
                    child: const Text(
                      '전체보기 >',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none, // 그림자가 잘리지 않도록 설정
                padding: const EdgeInsets.symmetric(horizontal: 20), // 좌우 간격 추가
                children: [
                  NewsCard(
                    imageUrl:
                        'https://pds.joongang.co.kr/news/component/htmlphoto_mmdata/202305/31/e48e559b-086b-40d5-8686-7583f09e5a95.jpg',
                    title: '도로공사-카카오모빌리티 협약',
                    onPressed: () => {},
                  ),
                  const SizedBox(width: 20), // 카드 간 간격 추가
                  NewsCard(
                    imageUrl:
                        'https://pds.joongang.co.kr/news/component/htmlphoto_mmdata/202305/31/e48e559b-086b-40d5-8686-7583f09e5a95.jpg',
                    title: '공공 민간 협력 기반 교통안전 서비스',
                    onPressed: () => {},
                  ),
                  const SizedBox(width: 20), // 카드 간 간격 추가
                  NewsCard(
                    imageUrl:
                        'https://pds.joongang.co.kr/news/component/htmlphoto_mmdata/202305/31/e48e559b-086b-40d5-8686-7583f09e5a95.jpg',
                    title: '정책상호공유 및 서비스 업무협약',
                    onPressed: () => {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  // 스크랩 기사 클릭 시 동작
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 20), // 내부 패딩 설정
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // 그림자 색상
                        blurRadius: 10, // 그림자 흐림 정도
                        spreadRadius: 2, // 그림자 퍼짐 정도
                        offset: const Offset(0, 3), // 그림자 위치
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '스크랩 기사 바로가기',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.black, // 아이콘 색상
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Categories section 가로 스크롤
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    NewsCategory(
                      categories: [
                        '금융',
                        '증권',
                        '산업/재계',
                        '부동산',
                        '글로벌 경제',
                        '경제 일반'
                      ],
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
            // 뉴스 리스트를 감싸는 박스 (그림자 포함)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 선택된 카테고리에 따른 뉴스 리스트 (4개만 보여주기)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: newsList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            // 뉴스 항목에만 패딩 적용
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: GestureDetector(
                                onTap: () {
                                  // 뉴스 상세 페이지로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewsDetailScreen(
                                        title: newsList[index],
                                        dateTime: '2024-11-22',
                                        content: '111111111111111111',
                                        imageUrl:
                                            'https://pds.joongang.co.kr/news/component/htmlphoto_mmdata/202305/31/e48e559b-086b-40d5-8686-7583f09e5a95.jpg',
                                      ),
                                    ),
                                  );
                                },
                                child:
                                    buildNewsListTile(newsList[index], index),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30), // 끝 부분에 스크롤 가능한 공간 추가
          ],
        ),
      ),
    );
  }

  Widget buildNewsListTile(String title, int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedNewsIndex == index
                ? Colors.purple // 선택된 뉴스일 경우 보더 색상 변경
                : Colors.transparent, // 선택되지 않은 경우 투명 보더
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
                    '2024.08.30, 12:29', // 임시 날짜와 시간 정보
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
              width: 120,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image:
                      AssetImage('assets/images/newsarticle.png'), // 이미지 경로 수정
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
