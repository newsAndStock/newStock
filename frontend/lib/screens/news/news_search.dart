import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/api/news_api_service.dart';
import 'package:frontend/screens/news/news_search_result.dart';

class NewsSearchScreen extends StatefulWidget {
  const NewsSearchScreen({Key? key}) : super(key: key);

  @override
  _NewsSearchScreenState createState() => _NewsSearchScreenState();
}

class _NewsSearchScreenState extends State<NewsSearchScreen> {
  final NewsService _apiService = NewsService();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  List<String> _trendingKeywords = [];
  List<String> _recentSearches = [];
  bool _isLoadingTrendingKeywords = false;
  bool _isLoadingRecentSearches = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTrendingKeywords();
    _fetchRecentSearches();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      // You can add real-time search suggestion logic here
    } else {
      setState(() {});
    }
  }

  Future<void> _fetchTrendingKeywords() async {
    String todayDate = _getTodayDate();
    setState(() {
      _isLoadingTrendingKeywords = true;
    });

    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }
      final keywords =
          await _apiService.fetchTrendingKeywords(todayDate, accessToken);
      setState(() {
        _trendingKeywords = keywords;
        _isLoadingTrendingKeywords = false;
      });
    } catch (e) {
      print('Failed to load trending keywords: $e');
      setState(() {
        _isLoadingTrendingKeywords = false;
      });
    }
  }

  Future<void> _fetchRecentSearches() async {
    setState(() {
      _isLoadingRecentSearches = true;
    });

    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }
      final keywords = await _apiService.fetchRecentKeywords(accessToken);
      setState(() {
        _recentSearches = keywords;
        _isLoadingRecentSearches = false;
      });
    } catch (e) {
      print('Error fetching recent searches: $e');
      setState(() {
        _isLoadingRecentSearches = false;
      });
    }
  }

  // 삭제 함수 추가
  Future<void> _deleteRecentKeyword(String keyword) async {
    setState(() {
      _isLoadingRecentSearches = true;
    });

    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      await _apiService.deleteRecentKeyword(accessToken, keyword);

      // 삭제된 후 목록을 갱신합니다.
      setState(() {
        _recentSearches.remove(keyword);
        _isLoadingRecentSearches = false;
      });
    } catch (e) {
      print('Failed to delete recent keyword: $e');
      setState(() {
        _isLoadingRecentSearches = false;
      });
    }
  }

  String _getTodayDate() {
    final DateTime now = DateTime.now();
    return '${now.year % 100}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  void _navigateToSearchResult(String searchTerm) async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsSearchResultScreen(searchTerm: searchTerm),
        ),
      );

      // 돌아올 때 최근 검색어 갱신
      _fetchRecentSearches();
    } catch (e) {
      print('Error navigating to search result: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('뉴스 검색', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              controller: _searchController,
              onSearch: (keyword) {
                if (keyword.isNotEmpty) {
                  _navigateToSearchResult(keyword);
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: '인기 검색어'),
                      Tab(text: '최근 검색어'),
                    ],
                    labelColor: const Color(0xff3A2E6A),
                    onTap: (index) {
                      if (index == 1) {
                        _fetchRecentSearches();
                      }
                    },
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTrendingKeywords(),
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

  Widget _buildRecentSearches() {
    if (_isLoadingRecentSearches) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentSearches.isEmpty) {
      return const Center(child: Text('최근 검색어가 없습니다.'));
    }

    return ListView.builder(
      itemCount: _recentSearches.length,
      itemBuilder: (context, index) {
        final keyword = _recentSearches[index];
        return ListTile(
          title: Text(keyword),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFFB4B4B4)),
            onPressed: () async {
              await _deleteRecentKeyword(keyword);
            },
          ),
          onTap: () => _navigateToSearchResult(keyword),
        );
      },
    );
  }

  Widget _buildTrendingKeywords() {
    if (_isLoadingTrendingKeywords) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_trendingKeywords.isEmpty) {
      return const Center(child: Text('인기 검색어가 없습니다.'));
    }

    return ListView.builder(
      itemCount: _trendingKeywords.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${index + 1}. ${_trendingKeywords[index]}'),
          onTap: () => _navigateToSearchResult(_trendingKeywords[index]),
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
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: '키워드를 검색해보세요!',
                    border: InputBorder.none,
                  ),
                  onSubmitted: widget.onSearch,
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
