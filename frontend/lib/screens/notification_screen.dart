import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('알림'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildIndexCard('삼성전자 1,000주 매수', '2024-09.03 14:11:06'),
          _buildIndexCard('삼성전자(우) 100주 매도', '2024-09.19 13:00:00'),
          _buildIndexCard('하이닉스 200주 매도', '2024-09.19 13:10:00'),
          _buildIndexCard('유한양행 1,000주 매수', '2024-09.19 13:20:00'),
        ],
      ),
    );
  }

  Widget _buildIndexCard(String message, String created_time) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Color(0xffF4F4F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '거래가 체결되었습니다.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
            ],
          ),
          Text(created_time)
        ]),
      ),
    );
  }
}
