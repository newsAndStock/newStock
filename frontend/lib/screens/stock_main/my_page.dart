import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserInfoCard(),
            _buildAccountSummaryCard(),
            _buildStockList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '띵슈롱님,',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  '현재 순위는 236위입니다!',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          Icon(Icons.celebration, color: Colors.yellow, size: 48),
        ],
      ),
    );
  }

  Widget _buildAccountSummaryCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAccountItem('총자산', '12,360,000원'),
            _buildAccountItem('예수금', '5,000,000원'),
            _buildAccountItem('손익', '+ 2,360,000원', isProfit: true),
            _buildAccountItem('수익률', '+23.6%', isProfit: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem(String label, String value,
      {bool isProfit = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isProfit ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList() {
    return Column(
      children: [
        _buildStockItem('삼성전자'),
        _buildStockItem('삼성에스디에스'),
        _buildStockItem('삼성중공업'),
      ],
    );
  }

  Widget _buildStockItem(String name) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('보유종목',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('현재가', style: TextStyle(fontSize: 14)),
                    Text('매입가', style: TextStyle(fontSize: 14)),
                    Text('보유량', style: TextStyle(fontSize: 14)),
                    Text('평가손익', style: TextStyle(fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('74,300 원', style: TextStyle(fontSize: 14)),
                    Text('98,400 원', style: TextStyle(fontSize: 14)),
                    Text('100주', style: TextStyle(fontSize: 14)),
                    Text('-2,400,000원',
                        style: TextStyle(fontSize: 14, color: Colors.blue)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
