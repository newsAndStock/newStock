import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/api/member_api_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final response = await MemberApiService().fetchNotification();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          notifications = data.map((notification) {
            final orderType = notification['orderType'] == 'BUY' ? '매수' : '매도';
            final message =
                '${notification['stockName']} ${notification['quantity']}주 $orderType';
            final createdTime =
                notification['createdAt'].replaceAll('T', ' ').substring(5, 19);
            print("message: $message");
            return {
              'message': message,
              'createdTime': createdTime,
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

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
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildIndexCard(
              notification['message'], notification['createdTime']);
        },
      ),
    );
  }

  Widget _buildIndexCard(String message, String createdTime) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xffF4F4F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$message 거래가 체결되었습니다.',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 2, // 최대 2줄까지만 표시
                  overflow: TextOverflow.ellipsis, // 넘치는 부분은 생략 부호 처리
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              createdTime,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
