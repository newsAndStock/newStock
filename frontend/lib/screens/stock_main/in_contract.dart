import 'package:flutter/material.dart';
import 'package:frontend/api/stock_api/trading_api/in_trading_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure storage import

enum PromiseType {
  BUY,
  SELL,
}

class InContract {
  final int id;
  final String name;
  final PromiseType orderType;
  final double bid;
  final double quantity;

  InContract({
    required this.id,
    required this.name,
    required this.orderType,
    required this.bid,
    required this.quantity,
  });

  factory InContract.fromJson(Map<String, dynamic> json) {
    return InContract(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      orderType:
          json['orderType'] == 'BUY' ? PromiseType.BUY : PromiseType.SELL,
      bid: (json['bid'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
    );
  }
}

class InContractList extends StatefulWidget {
  const InContractList({Key? key}) : super(key: key);

  @override
  _InContractListState createState() => _InContractListState();
}

class _InContractListState extends State<InContractList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<InContract> _contracts = [];
  bool _isLoading = false;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchContracts();
  }

  Future<void> _fetchContracts() async {
    setState(() => _isLoading = true);
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // API 호출
      List<dynamic> buyingStocks =
          await InTradingApi.getInBuyingStocks(accessToken);
      List<dynamic> sellingStocks =
          await InTradingApi.getInSellingStocks(accessToken);

      setState(() {
        _contracts = [
          ...buyingStocks.map((json) => InContract.fromJson(json)),
          ...sellingStocks.map((json) => InContract.fromJson(json))
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load contracts: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('거래대기 목록'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '매수',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '매도',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildContractList(PromiseType.BUY),
                      _buildContractList(PromiseType.SELL),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> deletingTrades(int id) async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken == null) {
      throw Exception('No access token found');
    }
    await InTradingApi.cancelTrading(accessToken, id);
  }

  Widget _buildContractList(PromiseType type) {
    final filteredContracts =
        _contracts.where((contract) => contract.orderType == type).toList();
    return ListView.builder(
      itemCount: filteredContracts.length,
      itemBuilder: (context, index) {
        final contract = filteredContracts[index];
        return _buildIndexCard(contract);
      },
    );
  }

  Widget _buildIndexCard(InContract contract) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Color(0xffF4F4F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    contract.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${contract.orderType == PromiseType.BUY ? "매수" : "매도"} ${contract.bid}원 x ${contract.quantity}주',
                    style: const TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '거래가 대기 중입니다.',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () => _showConfirmationSheet(contract),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationSheet(InContract contract) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFFF4F4F5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '거래 취소',
                style: TextStyle(
                    color: Color(0xff3A2E6A),
                    fontSize: 23,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '거래를 취소하시겠습니까?',
                style: TextStyle(color: Color(0xff3A2E6A), fontSize: 15),
              ),
              Text(
                '취소 시 복구가 불가합니다.',
                style: TextStyle(
                  color: Color(0xff3A2E6A),
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text(
                  '취소하기',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: () async {
                  // Implement buy logic
                  await deletingTrades(contract.id);
                  Navigator.pop(context);
                  _fetchContracts();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff3A2E6A),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
