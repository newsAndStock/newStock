import 'package:flutter/material.dart';

class NewsCategory extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;
  final String selectedCategory;

  const NewsCategory({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  _NewsCategoryState createState() => _NewsCategoryState();
}

class _NewsCategoryState extends State<NewsCategory> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: widget.categories
            .map((category) => Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: buildCategoryChip(
                      category, widget.selectedCategory == category),
                ))
            .toList(),
      ),
    );
  }

  Widget buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        widget.onCategorySelected(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3A2E6A) : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF3A2E6A) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 그림자 색상
              blurRadius: 6, // 흐림 정도 (elevation에 해당)
              offset: const Offset(0, 3), // 그림자의 위치 (x, y)
              spreadRadius: 1, // 그림자 퍼짐 정도
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
