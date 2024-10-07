import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  // onSearch 파라미터를 추가합니다.
  const SearchBar({Key? key, required this.controller, required this.onSearch})
      : super(key: key);

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
                  controller: controller,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: '키워드를 검색해보세요!',
                    hintStyle:
                        TextStyle(color: Color(0xFFB4B4B4), fontSize: 15),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) =>
                      onSearch(value), // 검색어 입력 후 엔터를 누르면 onSearch 호출
                ),
              ),
              ElevatedButton(
                onPressed: () =>
                    onSearch(controller.text), // 버튼 클릭 시 onSearch 호출
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
