import 'package:flutter/material.dart';

enum PromiseType {
  buyType,
  sellType,
}

class InContract {
  final String stockName;
  final PromiseType promiseType;
  final double promisePrice;
  final double promiseQuantity;

  InContract({
    required this.stockName,
    required this.promiseType,
    required this.promisePrice,
    required this.promiseQuantity,
  });

  factory InContract.fromJson(Map<String, dynamic> json) {
    return InContract(
      stockName: json['stockName'],
      promiseType: PromiseType.values.firstWhere(
          (e) => e.toString() == 'PromiseType.${json['promiseType']}'),
      promisePrice: json['promisePrice'].toDouble(),
      promiseQuantity: json['promiseQuantity'].toDouble(),
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchContracts();
  }

  Future<void> _fetchContracts() async {
    setState(() => _isLoading = true);
    // 실제 API 호출을 시뮬레이션. 실제 구현시 http 패키지 등을 사용하여 API를 호출해야 합니다.
    await Future.delayed(Duration(seconds: 1));
    final List<Map<String, dynamic>> apiResponse = [
      {
        'stockName': '삼성전자',
        'promiseType': 'buyType',
        'promisePrice': 70000,
        'promiseQuantity': 10
      },
      {
        'stockName': 'SK하이닉스',
        'promiseType': 'sellType',
        'promisePrice': 120000,
        'promiseQuantity': 5
      },
      {
        'stockName': '네이버',
        'promiseType': 'buyType',
        'promisePrice': 350000,
        'promiseQuantity': 2
      },
      {
        'stockName': '카카오',
        'promiseType': 'sellType',
        'promisePrice': 80000,
        'promiseQuantity': 15
      },
    ];

    setState(() {
      _contracts =
          apiResponse.map((json) => InContract.fromJson(json)).toList();
      _isLoading = false;
    });
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
                      _buildContractList(PromiseType.buyType),
                      _buildContractList(PromiseType.sellType),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractList(PromiseType type) {
    final filteredContracts =
        _contracts.where((contract) => contract.promiseType == type).toList();
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
                    contract.stockName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${contract.promiseType == PromiseType.buyType ? "매수" : "매도"} ${contract.promisePrice}원 x ${contract.promiseQuantity}주',
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
              onPressed: _showConfirmationSheet,
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationSheet() {
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
                onPressed: () {
                  // Implement buy logic
                  Navigator.pop(context);
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
