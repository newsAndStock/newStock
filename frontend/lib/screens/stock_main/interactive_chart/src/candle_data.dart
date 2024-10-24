import 'package:intl/intl.dart';

class CandleData {
  /// The timestamp of this data point, in milliseconds since epoch.
  final DateTime dateTime;

  /// The "open" price of this data point. It's acceptable to have null here for
  /// a few data points, but they must not all be null. If either [open] or
  /// [close] is null for a data point, it will appear as a gap in the chart.
  final double? open;

  /// The "high" price. If either one of [high] or [low] is null, we won't
  /// draw the narrow part of the candlestick for that data point.
  double? high;

  /// The "low" price. If either one of [high] or [low] is null, we won't
  /// draw the narrow part of the candlestick for that data point.
  double? low;

  /// The "close" price of this data point. It's acceptable to have null here
  /// for a few data points, but they must not all be null. If either [open] or
  /// [close] is null for a data point, it will appear as a gap in the chart.
  double? close;

  /// The volume information of this data point.
  double? volume;

  /// Data holder for additional trend lines, for this data point.
  ///
  /// For a single trend line, we can assign it as a list with a single element.
  /// For example if we want "7 days moving average", do something like
  /// `trends = [ma7]`. If there are multiple tread lines, we can assign a list
  /// with multiple elements, like `trends = [ma7, ma30]`.
  /// If we don't want any trend lines, we can assign an empty list.
  ///
  /// This should be an unmodifiable list, so please do not use `add`
  /// or `clear` methods on the list. Always assign a new list if values
  /// are changed. Otherwise the UI might not be updated.
  List<double?> trends;

  CandleData({
    required this.dateTime,
    required this.open,
    required this.close,
    required this.volume,
    this.high,
    this.low,
    List<double?>? trends,
  }) : this.trends = List.unmodifiable(trends ?? []);

  int get timestamp => dateTime.millisecondsSinceEpoch;

  static double? _parseDouble(String? value) {
    if (value == null) return null;
    return double.tryParse(value);
  }

  static DateTime _parseDateTime(String time) {
    final now = DateTime.now();
    final timeComponents = time.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(timeComponents[0]),
      int.parse(timeComponents[1]),
    );
  }

  factory CandleData.fromJson(Map<String, dynamic> json) {
    return CandleData(
      dateTime: _parseDateTime(json['time']),
      open: _parseDouble(json['openingPrice']),
      high: _parseDouble(json['highestPrice']),
      low: _parseDouble(json['lowestPrice']),
      close: _parseDouble(json['closingPrice']),
      volume: _parseDouble(json['volume']),
    );
  }

  String get time => DateFormat('HH:mm').format(dateTime);

  // 이동평균을 구하는 코드 지금은 7일기준이동평균
  static List<double?> computeMA(List<CandleData> data, [int period = 7]) {
    // If data is not at least twice as long as the period, return nulls.
    if (data.length < period * 2) return List.filled(data.length, null);

    final List<double?> result = [];
    // Skip the first [period] data points. For example, skip 7 data points.
    final firstPeriod =
        data.take(period).map((d) => d.close).whereType<double>();
    double ma = firstPeriod.reduce((a, b) => a + b) / firstPeriod.length;
    result.addAll(List.filled(period, null));

    // Compute the moving average for the rest of the data points.
    for (int i = period; i < data.length; i++) {
      final curr = data[i].close;
      final prev = data[i - period].close;
      if (curr != null && prev != null) {
        ma = (ma * period + curr - prev) / period;
        result.add(ma);
      } else {
        result.add(null);
      }
    }
    return result;
  }

  @override
  String toString() => "<CandleData ($timestamp: $close)>";
}