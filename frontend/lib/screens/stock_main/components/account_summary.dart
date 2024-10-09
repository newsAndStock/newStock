import 'package:flutter/material.dart';
import 'package:frontend/api/stock_api/my_page_api.dart';
import 'package:frontend/screens/stock_main/my_page.dart';
import 'package:intl/intl.dart';

class AccountSummary extends StatefulWidget {
  const AccountSummary({Key? key}) : super(key: key);

  @override
  _AccountSummaryState createState() => _AccountSummaryState();
}

class _AccountSummaryState extends State<AccountSummary> {
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = MyPageApi().getMyDetail();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final userData = snapshot.data!;
          return _buildAccountSummaryCard(userData);
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildAccountSummaryCard(Map<String, dynamic> userData) {
    final numberFormat = NumberFormat('#,###');
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy.MM.dd HH:mm').format(now);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2E6A),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${userData['nickname']}님, 안녕하세요!',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text('$formattedDate 기준',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              TextButton(
                child: const Text('내 계좌보기 >',
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyPage()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(context, '총자산',
                  '${numberFormat.format(userData['totalPrice'])}원',
                  valueColor: Color(0xFF3A2E6A)),
              _buildSummaryItem(context, '수익률', '${userData['roi']}%',
                  valueColor: double.parse(userData['roi']) >= 0
                      ? Colors.red
                      : Colors.blue),
              _buildSummaryItem(context, '랭킹', '${userData['rank']}',
                  valueColor: Color(0xFF3A2E6A)),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String title, String value,
      {Color? valueColor}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.23,
      height: MediaQuery.of(context).size.width * 0.18,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value == '0' ? '-' : (title == '랭킹' ? value + '위' : value),
              style: TextStyle(
                color: valueColor ?? const Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
