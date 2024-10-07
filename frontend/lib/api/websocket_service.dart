import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  static String myApprovalKey = dotenv.get("approval_key");
  final Logger log = Logger('WebSocketService');
  TradeQueue tradeQueue = TradeQueue();
  Timer? _pingTimer;
  String? lastStockCode;
  String? lastTrType;

  Stream get stream {
    if (_channel == null) {
      throw StateError('WebSocket is not connected');
    }
    return _channel!.stream;
  }

  Function(double)? onPriceUpdate;

  Future<void> connectWebsocket(Function onConnected) async {
    print('Attempting to connect to WebSocket...');
    final url = Uri.parse('ws://ops.koreainvestment.com:21000');
    _channel = WebSocketChannel.connect(url);

    try {
      await _channel!.ready;
      print('WebSocket connected successfully');

      _subscription = _channel!.stream.listen(
        (message) {
          print('Received message: $message');
          // ... 기존 코드 ...
        },
        onDone: () {
          print('WebSocket connection closed');
          _reconnect();
        },
        onError: (error) {
          print('WebSocket error: $error');
          _reconnect();
        },
      );

      _startPingTimer();
      onConnected();
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      _reconnect();
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (_channel?.closeCode == null) {
        _channel?.sink.add('ping');
      }
    });
  }

  void _reconnect() {
    _pingTimer?.cancel();
    Future.delayed(Duration(seconds: 5), () {
      if (_channel?.closeCode != null) {
        print('Attempting to reconnect...');
        connectWebsocket(() {
          print('Reconnected, resending initial message...');
          if (lastStockCode != null && lastTrType != null) {
            sendMessage(lastStockCode!, lastTrType!);
          } else {
            print('No previous message to resend');
          }
        });
      }
    });
  }

  void sendMessage(String stockCode, String trType) {
    lastStockCode = stockCode;
    lastTrType = trType;

    if (_channel == null || _channel!.closeCode != null) {
      print('WebSocket not connected, attempting to reconnect...');
      connectWebsocket(() {
        String approvalKey = myApprovalKey;
        String payload = createMessage(approvalKey, stockCode, trType);
        print('Sending message: $payload');
        _channel!.sink.add(payload);
      });
    } else {
      String approvalKey = myApprovalKey;
      String payload = createMessage(approvalKey, stockCode, trType);
      print('Sending message: $payload');
      _channel!.sink.add(payload);
    }
  }

  String createMessage(String approvalKey, String trKey, String trType) {
    return jsonEncode({
      "header": {
        "approval_key": approvalKey,
        "custtype": "P",
        "tr_type": trType,
        "content-type": "utf-8"
      },
      "body": {
        "input": {"tr_id": "H0STCNT0", "tr_key": trKey}
      }
    });
  }

  void realTimePrice(String message) {
    try {
      String stockCode = getStockCode(message);
      double price = parseSocketMessage(message);
      dealTrade(message, stockCode);
      Queue<TradeItem> sellItems =
          tradeQueue.getSellQueue()[stockCode] ?? Queue<TradeItem>();
      Queue<TradeItem> buyItems =
          tradeQueue.getBuyQueue()[stockCode] ?? Queue<TradeItem>();

      log.info('<$stockCode> 현재 가격: $price');
      log.info('<$stockCode> 매수 대기인원: ${sellItems.length}');
      log.info('<$stockCode> 매도 대기인원: ${buyItems.length}');

      if (sellItems.isEmpty && buyItems.isEmpty) {
        log.info('<$stockCode> 커넥션 종료');
        sendMessage(stockCode, "2");
      }
    } catch (e) {
      print('Error in realTimePrice: $e');
    }
  }

  String getType(String message) {
    List<String> fields = message.split('|');
    return fields[1];
  }

  String getStockCode(String message) {
    List<String> fields = message.split(RegExp(r'[|^]'));
    return fields[3];
  }

  double parseSocketMessage(String message) {
    try {
      List<String> fields = message.split('|');
      if (fields.length < 4) {
        print('Invalid message format: $message');
        return 0.0;
      }

      List<String> stockDetails = fields[3].split('^');
      if (stockDetails.length < 3) {
        print('Invalid stock details format: ${fields[3]}');
        return 0.0;
      }

      double price = double.tryParse(stockDetails[2]) ?? 0.0;
      print('Parsed price: $price');
      return price;
    } catch (e) {
      print('Error parsing socket message: $e');
      return 0.0;
    }
  }

  void dealTrade(String message, String stockCode) {
    // dealTrade 로직 구현
  }

  void dispose() {
    _pingTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
  }
}

class TradeQueue {
  Map<String, Queue<TradeItem>> sellQueue = {};
  Map<String, Queue<TradeItem>> buyQueue = {};

  Map<String, Queue<TradeItem>> getSellQueue() => sellQueue;
  Map<String, Queue<TradeItem>> getBuyQueue() => buyQueue;
}

class TradeItem {
  // TradeItem 클래스 구현
}
