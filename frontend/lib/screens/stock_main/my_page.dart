import 'package:flutter/material.dart';
import 'package:frontend/api/stock_api/my_page_api.dart';
import 'package:frontend/screens/stock_main/components/in_contract_component.dart';
import 'package:frontend/screens/stock_main/ranking.dart';
import 'package:frontend/screens/stock_main/stock_detail_page.dart';
import 'package:intl/intl.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late Future<Map<String, dynamic>> _userDataFuture;
  late Future<List<Map<String, dynamic>>> _stockHelds;

  @override
  void initState() {
    super.initState();
    _userDataFuture = MyPageApi().getMyDetail();
    _stockHelds = MyPageApi().getMyStocks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('마이페이지'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userData = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    child: _buildUserInfoCard(userData),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RankingPage(
                                    userNickname: userData['nickname'],
                                  )));
                    },
                  ),
                  InContractComponent(),
                  _buildAccountSummaryCard(userData),
                  _buildStockList(),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  String formatNumber(int numStr) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(numStr);
  }

  Widget _buildUserInfoCard(Map<String, dynamic> userData) {
    double roi = double.parse(userData['roi']);
    String imagePath;
    if (roi > 0) {
      imagePath = 'assets/images/up.png';
    } else if (roi < 0) {
      imagePath = 'assets/images/down.png';
    } else {
      imagePath = 'assets/images/default.png';
    }
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xff3A2E6A),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${userData['nickname']}님,',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    '현재 순위는 ${userData['rank']}위입니다!',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          // Icon(Icons.celebration, color: Colors.yellow, size: 48),
          Image.asset(imagePath, width: 70, height: 70),
        ],
      ),
    );
  }

  Widget _buildAccountSummaryCard(Map<String, dynamic> userData) {
    return FractionallySizedBox(
      widthFactor: 0.95,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildAccountItem(
                  '총자산', '${formatNumber(userData['totalPrice'])}원'),
              _buildAccountItem('예수금', '${formatNumber(userData['deposit'])}원'),
              _buildAccountItem(
                  '손익', '${formatNumber(userData['profitAndLoss'])}원',
                  isProfit: userData['profitAndLoss'] >= 0),
              _buildAccountItem('수익률', '${userData['roi']}%',
                  isProfit: double.parse(userData['roi']) >= 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountItem(String label, String value,
      {bool isProfit = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 16)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isProfit ? Colors.red : Colors.blue,
                ),
              ),
            ],
          ),
          label != '수익률'
              ? Divider(
                  color: Color(0xFFB4B4B4),
                  thickness: 0.2,
                  height: 1,
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildStockList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text('보유종목',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _stockHelds,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return Column(
                children: snapshot.data!
                    .map((stock) => _buildStockItem(stock))
                    .toList(),
              );
            } else {
              return Center(child: Text('No stocks available'));
            }
          },
        ),
      ],
    );
  }

  Widget _buildStockItem(Map<String, dynamic> stock) {
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockDetailPage(
                stockName: stock['name'],
                stockCode: stock['stockCode'],
              ),
            ),
          );
        });
      },
      child: FractionallySizedBox(
        widthFactor: 0.85,
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(stock['name'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
                        Text('${formatNumber(stock['currentPrice'])} 원',
                            style: TextStyle(fontSize: 14)),
                        Text('${formatNumber(stock['userPrice'])} 원',
                            style: TextStyle(fontSize: 14)),
                        Text('${formatNumber(stock['quantity'])}주',
                            style: TextStyle(fontSize: 14)),
                        Text('${formatNumber(stock['profitAndLoss'])}원',
                            style: TextStyle(
                                fontSize: 14,
                                color: (stock['profitAndLoss'] as int) >= 0
                                    ? Colors.red
                                    : Colors.blue)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
