import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:frontend/screens/news/news_my_scrap.dart';

class NewsScrapScreen extends StatefulWidget {
  final String title;
  final String content;
  final String dateTime;

  const NewsScrapScreen({
    Key? key,
    required this.title,
    required this.content,
    required this.dateTime,
  }) : super(key: key);

  @override
  _NewsScrapScreenState createState() => _NewsScrapScreenState();
}

class _NewsScrapScreenState extends State<NewsScrapScreen> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final doc = quill.Document()..insert(0, widget.content);
    _controller = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  void _applyBackgroundColor() {
    // 배경색을 문자열 값으로 설정 (형광펜 효과: 노란색)
    _controller.formatSelection(quill.Attribute(
      'background',
      quill.AttributeScope.inline,
      '#FFFF00',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("스크랩하기"),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 영역
                Text(
                  widget.title, // 받아온 데이터로 제목 표시
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // 기자 정보와 날짜
                Text(
                  '기자... 음', // 기자 정보
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.dateTime, // 작성 일시
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                // 구분선
                const Divider(
                  thickness: 1,
                  color: Color.fromARGB(255, 201, 201, 201),
                ),
                const SizedBox(height: 20),
                // 텍스트 편집 영역
                Expanded(
                  child: quill.QuillEditor(
                    controller: _controller,
                    scrollController: ScrollController(),
                    focusNode: _focusNode,
                  ),
                ),
                const SizedBox(height: 16),
                // 툴바와 저장하기 버튼을 가로로 배치
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bold (굵게) 버튼
                    IconButton(
                      icon: const Icon(Icons.format_bold),
                      onPressed: () {
                        _controller.formatSelection(quill.Attribute.bold);
                      },
                      padding: const EdgeInsets.all(8.0),
                      iconSize: 24,
                    ),
                    // Italic (기울임) 버튼
                    IconButton(
                      icon: const Icon(Icons.format_italic),
                      onPressed: () {
                        _controller.formatSelection(quill.Attribute.italic);
                      },
                      padding: const EdgeInsets.all(8.0),
                      iconSize: 24,
                    ),
                    // Underline (밑줄) 버튼
                    IconButton(
                      icon: const Icon(Icons.format_underline),
                      onPressed: () {
                        _controller.formatSelection(quill.Attribute.underline);
                      },
                      padding: const EdgeInsets.all(8.0),
                      iconSize: 24,
                    ),
                    // Highlight (형광펜) 버튼
                    IconButton(
                      icon: const Icon(Icons.format_color_fill),
                      onPressed: _applyBackgroundColor, // 배경색 설정
                      padding: const EdgeInsets.all(8.0),
                      iconSize: 24,
                    ),
                    const SizedBox(width: 16), // 툴바와 버튼 사이의 간격
                    // 저장하기 버튼
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            final content = _controller.document.toPlainText();
                            print('저장된 뉴스 내용: $content');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NewsMyScrapScreen(),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A2E6A),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                          ),
                          child: const Text(
                            '저장하기',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
