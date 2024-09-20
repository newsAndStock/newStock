import 'package:flutter/material.dart';
import 'package:frontend/screens/news/news_search_result.dart';

class NewsSearchScreen extends StatelessWidget {
  const NewsSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('뉴스 검색'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SearchBar(), // 검색바 (검색어 입력 및 이동)
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '인기 검색어',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '최근 검색어',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                    labelColor: Color(0xff3A2E6A),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTrendingStocks(),
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
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Column(children: [
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: ListTile(
                title: Text('${index + 1}. 뉴스 ${index + 1}'),
                onTap: () {
                  // Handle stock selection
                },
              ),
            ),
          ),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.85,
              child: const Divider(
                color: Color(0xFFB4B4B4),
                thickness: 1,
                height: 1,
              ),
            ),
          )
        ]);
      },
    );
  }

  Widget _buildRecentSearches() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Column(children: [
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: ListTile(
                title: Text('최근 검색어 ${index + 1}'),
                trailing: const Icon(
                  Icons.close,
                  size: 15,
                  color: Color(0xFFB4B4B4),
                ),
                onTap: () {
                  // Handle recent search selection
                },
              ),
            ),
          ),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.85,
              child: const Divider(
                color: Color(0xFFB4B4B4),
                thickness: 1,
                height: 1,
              ),
            ),
          ),
        ]);
      },
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

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
                  controller: searchController, // 검색어 입력 받는 TextField
                  decoration: const InputDecoration(
                    hintText: '키워드를 검색해보세요!',
                    hintStyle:
                        TextStyle(color: Color(0xFFB4B4B4), fontSize: 15),
                    border: InputBorder.none,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // 검색 버튼 클릭 시 검색어를 결과 페이지로 전달
                  String searchTerm = searchController.text;
                  if (searchTerm.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsSearchResultScreen(
                          searchTerm: searchTerm,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF1F5F9),
                  foregroundColor: Colors.black,
                  elevation: 3,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(60, 36),
                ),
                child: const Text('검색', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
