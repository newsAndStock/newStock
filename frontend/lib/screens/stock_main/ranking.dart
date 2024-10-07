import 'package:flutter/material.dart';
import 'package:frontend/api/stock_api/my_page_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  late Future<Map<String, dynamic>> _rankingFuture;
  static String apiServerUrl = dotenv.get("API_SERVER_URL");

  @override
  void initState() {
    super.initState();
    _rankingFuture = MyPageApi().getRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _rankingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final rankingData = snapshot.data!;
            final rankingSaveTime = rankingData['rankSaveTime'];
            final rankings = (rankingData['ranking'] as Map<String, dynamic>)
                .entries
                .toList();
            rankings.sort((a, b) => b.value.compareTo(a.value)); // 내림차순 정렬

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text('랭킹', style: TextStyle(color: Colors.black)),
                  backgroundColor: Colors.white,
                  floating: true,
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '랭킹 갱신일: $rankingSaveTime',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '현재 순위: ${rankings.indexWhere((item) => item.key == '1234') + 1}위',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = rankings[index];
                      return _buildRankingItem(
                        entry.key,
                        entry.value,
                        index + 1,
                        index < 3,
                      );
                    },
                    childCount: rankings.length,
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildRankingItem(
      String name, double percentage, int rank, bool isTop3) {
    double widthFactor;
    if (rank == 1) {
      widthFactor = 0.9;
    } else if (rank == 2) {
      widthFactor = 0.8;
    } else if (rank == 3) {
      widthFactor = 0.75;
    } else {
      widthFactor = 0.65;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          child: Container(
            decoration: BoxDecoration(
              color: isTop3 ? Color(0xFF3A2E6A) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$rank위 $name',
                    style: TextStyle(
                      color: isTop3 ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isTop3 ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
