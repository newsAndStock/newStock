import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

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
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16), // 라벨 좌우 여백 추가
                          child: Text(
                            '거래많은 주식',
                            style: TextStyle(fontSize: 16), // 글씨 크기 증가
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16), // 라벨 좌우 여백 추가
                          child: Text(
                            '최근 검색어',
                            style: TextStyle(fontSize: 16), // 글씨 크기 증가
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
                title: Text('${index + 1}. 주식 ${index + 1}'),
                // trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Handle stock selection
                },
              ),
            ),
          ),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.85,
              child: Divider(
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
  // 검색어 height를 줄이고 싶을 때 쓰는 코드
//   Widget _buildTrendingStocks() {
//   return ListView.builder(
//     itemCount: 5,
//     itemBuilder: (context, index) {
//       return Column(
//         children: [
//           SizedBox(
//             height: 40, // ListTile의 높이를 줄임
//             child: Center(
//               child: FractionallySizedBox(
//                 widthFactor: 0.9,
//                 child: ListTile(
//                   contentPadding: EdgeInsets.symmetric(horizontal: 8),
//                   title: Text(
//                     '${index + 1}. 주식 ${index + 1}',
//                     style: TextStyle(fontSize: 14), // 글자 크기를 줄임
//                   ),
//                   onTap: () {
//                     // Handle stock selection
//                   },
//                 ),
//               ),
//             ),
//           ),
//           Center(
//             child: FractionallySizedBox(
//               widthFactor: 0.85,
//               child: Divider(
//                 color: Color(0xFFB4B4B4),
//                 thickness: 1,
//                 height: 1,
//               ),
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }

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
                trailing: Icon(
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
              child: Divider(
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
  //
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
                  decoration: InputDecoration(
                    hintText: '키워드를 검색해보세요!',
                    hintStyle:
                        TextStyle(color: Color(0xFFB4B4B4), fontSize: 15),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    // Handle search submission
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // 검색 기능 구현
                },
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
