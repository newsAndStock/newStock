import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 알림 초기화
  Future<void> initialize() async {
    // Android 초기화 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/newstock_logo_icon');

    // iOS 초기화 설정 추가
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Android와 iOS 설정을 모두 포함한 초기화 설정
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 알림 표시
  Future<void> showNotification(String id, String title, String body) async {
    print("알림 수신 - 제목: $title, 내용: $body");
    // int notificationId = 0;

    // notificationId = int.parse(id);
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'newstock',
      '주식 거래 알림',
      channelDescription: '주식 거래 이벤트 알림을 위한 채널입니다',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // notificationId, // 알림 ID
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
