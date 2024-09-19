import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주식 검색'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: '거래많은 주식'),
                      Tab(text: '최근 검색어'),
                    ],
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
        return ListTile(
          title: Text('주식 ${index + 1}'),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Handle stock selection
          },
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('최근 검색어 ${index + 1}'),
          trailing: Icon(Icons.close),
          onTap: () {
            // Handle recent search selection
          },
        );
      },
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: '키워드를 검색해보세요!',
          border: InputBorder.none,
          icon: Icon(Icons.search),
          suffixIcon: Icon(Icons.mic),
        ),
        onSubmitted: (value) {
          // Handle search submission
        },
      ),
    );
  }
}
