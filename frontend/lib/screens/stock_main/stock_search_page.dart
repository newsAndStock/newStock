import 'package:flutter/material.dart';
import 'package:frontend/api/stock_api/stock_search_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _topVolumeStocks = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _recentSearches = [];
  bool _isLoadingTrendingStock = false;
  bool _isLoadingSearch = false;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTopVolumeStocks();
    // _fetchRecentSearches();
  }

  Future<void> _fetchTopVolumeStocks() async {
    setState(() {
      _isLoadingTrendingStock = true;
    });

    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }
      final stocks = await StockSearchgApi.getTopVolumeStocks(accessToken);
      setState(() {
        _topVolumeStocks = stocks;
        _isLoadingTrendingStock = false;
      });
    } catch (e) {
      print('Error fetching top volume stocks: $e');
      setState(() {
        _isLoadingTrendingStock = false;
      });
    }
  }

  // Future<void> _fetchRecentSearches() async {
  //   try {
  //     String? accessToken = await storage.read(key: 'accessToken');
  //     if (accessToken == null) {
  //       throw Exception('No access token found');
  //     }
  //     final keywords = await StockSearchgApi.getRecentKeywords(accessToken);
  //     setState(() {
  //       _recentSearches = keywords;
  //     });
  //   } catch (e) {
  //     print('Error fetching recent searches: $e');
  //   }
  // }

  Future<void> _searchStocks(String keyword) async {
    setState(() {
      _isLoadingSearch = true;
    });

    try {
      String? accessToken = await storage.read(key: 'accessToken');
      int memberId = 11; //일단 kimsw0516@naver.com memberId 값으로 저장

      if (accessToken == null) {
        throw Exception('No access token found');
      }
      final stocks = await StockSearchgApi.searchStocks(keyword, accessToken);
      await StockSearchgApi.saveRecentKeyword(accessToken, memberId, keyword);
      setState(() {
        _searchResults = stocks;
        _isLoadingSearch = false;
      });
      // _fetchRecentSearches();
    } catch (e) {
      print('Error searching stocks: $e');
      setState(() {
        _isLoadingSearch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('주식 검색'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              controller: _searchController,
              onSearch: _searchStocks,
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(
                          child:
                              Text('거래많은 주식', style: TextStyle(fontSize: 16))),
                      Tab(
                          child:
                              Text('최근 검색어', style: TextStyle(fontSize: 16))),
                    ],
                    labelColor: Color(0xff3A2E6A),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _searchResults.isNotEmpty
                            ? _buildSearchResults()
                            : _buildTrendingStocks(),
                        _buildRecentSearches(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingStocks() {
    if (_isLoadingTrendingStock) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _topVolumeStocks.length,
      itemBuilder: (context, index) {
        final stock = _topVolumeStocks[index];
        return _buildStockListItem(stock, index);
      },
    );
  }

  Widget _buildSearchResults() {
    if (_isLoadingSearch) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final stock = _searchResults[index];
        return _buildStockListItem(stock, index);
      },
    );
  }

  Widget _buildStockListItem(Map<String, dynamic> stock, int index) {
    return Column(
      children: [
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: ListTile(
              title: Text('${index + 1}. ${stock['stockName']}'),
              subtitle: Text('${stock['stockCode']}'),
              onTap: () {
                // Handle stock selection
              },
            ),
          ),
        ),
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.85,
            child: Divider(color: Color(0xFFB4B4B4), thickness: 1, height: 1),
          ),
        )
      ],
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Text(
          '최근 검색어가 없습니다.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _recentSearches.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.9,
                child: ListTile(
                  title: Text(_recentSearches[index]),
                  trailing:
                      Icon(Icons.close, size: 15, color: Color(0xFFB4B4B4)),
                  onTap: () => _searchStocks(_recentSearches[index]),
                ),
              ),
            ),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.85,
                child:
                    Divider(color: Color(0xFFB4B4B4), thickness: 1, height: 1),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const SearchBar({Key? key, required this.controller, required this.onSearch})
      : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
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
                child: EditableText(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  cursorColor: Colors.blue,
                  backgroundCursorColor: Colors.grey,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.search,
                  onSubmitted: widget.onSearch,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(100),
                  ],
                  maxLines: 1,
                  // cursorColo: Colors.blue,
                  // backgroundCursorColor: Colors.grey,
                ),
              ),
              ElevatedButton(
                onPressed: () => widget.onSearch(widget.controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffF1F5F9),
                  foregroundColor: Colors.black,
                  elevation: 3,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size(60, 36),
                ),
                child: Text('검색', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
