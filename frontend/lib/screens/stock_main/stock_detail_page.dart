import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:fl_chart/fl_chart.dart';

class StockDetailPage extends StatefulWidget {
  final String stockName;

  const StockDetailPage({Key? key, required this.stockName}) : super(key: key);

  @override
  _StockDetailPageState createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCandlesticks = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stockName),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              // 즐겨찾기 기능 구현
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStockInfo(),
          // _buildChartSection(),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: '차트'),
              Tab(text: '종목 정보'),
              Tab(text: '관련 뉴스'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChartTab(),
                _buildStockInfoTab(),
                _buildNewsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildStockInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '74,500원',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '+300원 (0.4%)',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 300,
      child: Stack(
        children: [
          _showCandlesticks ? _buildCandlestickChart() : _buildLineChart(),
          Positioned(
            right: 16,
            bottom: 16,
            child: IconButton(
              icon: Icon(_showCandlesticks
                  ? Icons.show_chart
                  : Icons.candlestick_chart),
              onPressed: () {
                setState(() {
                  _showCandlesticks = !_showCandlesticks;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandlestickChart() {
    final List<Candle> candles = List.generate(
      30,
      (index) => Candle(
        date: DateTime.now().subtract(Duration(days: 30 - index)),
        high: 75000 + (index * 100),
        low: 73000 + (index * 100),
        open: 74000 + (index * 100),
        close: 74500 + (index * 100),
        volume: 1000000 + (index * 10000),
      ),
    );

    return Candlesticks(
      candles: candles,
    );
  }

  Widget _buildLineChart() {
    final List<FlSpot> spots = List.generate(
      30,
      (index) => FlSpot(index.toDouble(), 74000 + (index * 100)),
    );

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
      ),
    );
  }

  Widget _buildChartTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '주가 추이',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _buildChartSection(),
        ),
      ],
    );
  }

  Widget _buildStockInfoTab() {
    return ListView(
      children: [
        ListTile(title: Text('시가총액'), trailing: Text('229.7900억 원')),
        ListTile(title: Text('PER'), trailing: Text('37.36')),
        ListTile(title: Text('EPS'), trailing: Text('1,993원')),
        ListTile(title: Text('52주 최고'), trailing: Text('75,800원')),
        ListTile(title: Text('52주 최저'), trailing: Text('51,300원')),
        ListTile(title: Text('거래량'), trailing: Text('9,123,456주')),
      ],
    );
  }

  Widget _buildNewsTab() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${widget.stockName} 관련 뉴스 ${index + 1}'),
          subtitle: Text(
              '뉴스 출처 | ${DateTime.now().subtract(Duration(hours: index)).toString().substring(0, 16)}'),
          leading: Icon(Icons.article),
          onTap: () {
            // 뉴스 상세 페이지로 이동
          },
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        child: Text('거래하기'),
        onPressed: () {
          // 거래 기능 구현
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          minimumSize: Size(double.infinity, 50),
        ),
      ),
    );
  }
}
