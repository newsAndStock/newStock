import 'package:flutter/material.dart';

class RankingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
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
              child: Text(
                '띵슈롱님, 현재 순위는 236위입니다!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildRankingItem('주식맨', 43.2, 1, true),
              _buildRankingItem('주식킹', 42.2, 2, true),
              _buildRankingItem('일론머스크', 41.2, 3, true),
              _buildRankingItem('오예스', 33.2, 4, false),
              _buildRankingItem('야구왕', 26.2, 5, false),
              _buildRankingItem('투자고수', 25.2, 6, false),
              SizedBox(height: 20),
              _buildRankingItem('띵슈롱', 23.6, 236, false),
            ]),
          ),
        ],
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
