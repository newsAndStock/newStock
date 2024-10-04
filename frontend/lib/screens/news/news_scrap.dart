import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:frontend/api/news_api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NewsScrapScreen extends StatefulWidget {
  final String scrapId; // 스크랩 ID를 전달받음

  const NewsScrapScreen({
    Key? key,
    required this.scrapId,
  }) : super(key: key);

  @override
  _NewsScrapScreenState createState() => _NewsScrapScreenState();
}

class _NewsScrapScreenState extends State<NewsScrapScreen> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final storage = FlutterSecureStorage();
  late Future<void> scrapDataFuture;
  String? scrapTitle; // 제목을 저장할 변수

  @override
  void initState() {
    super.initState();
    scrapDataFuture = _loadScrapData(); // 스크랩 데이터 로드
  }

  Future<void> _loadScrapData() async {
    try {
      // 액세스 토큰 가져오기
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please log in.');
      }

      // 스크랩 데이터 가져오기
      final scrapData =
          await NewsService().fetchScrap(accessToken, widget.scrapId);

      // 스크랩 제목을 상태 변수에 저장
      setState(() {
        scrapTitle = scrapData.title;
      });

      // 에디터 초기화
      final doc = quill.Document()..insert(0, scrapData.content);
      _controller = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );

      setState(() {}); // UI 업데이트
    } catch (e) {
      print('Failed to load scrap data: $e');
    }
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
        title: const Text("스크랩 수정"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: scrapDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load scrap: ${snapshot.error}'),
            );
          } else {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 영역
                      Text(
                        scrapTitle ?? "스크랩 수정하기", // 스크랩 제목 표시
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
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
                              _controller
                                  .formatSelection(quill.Attribute.italic);
                            },
                            padding: const EdgeInsets.all(8.0),
                            iconSize: 24,
                          ),
                          // Underline (밑줄) 버튼
                          IconButton(
                            icon: const Icon(Icons.format_underline),
                            onPressed: () {
                              _controller
                                  .formatSelection(quill.Attribute.underline);
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    // 액세스 토큰 가져오기
                                    String? accessToken =
                                        await storage.read(key: 'accessToken');
                                    if (accessToken == null ||
                                        accessToken.isEmpty) {
                                      throw Exception(
                                          'No access token found. Please log in.');
                                    }

                                    // 현재 편집기에서 수정한 텍스트 가져오기
                                    final content =
                                        _controller.document.toPlainText();
                                    print('저장된 뉴스 내용: $content');

                                    // 스크랩 업데이트 API 호출
                                    await NewsService().updateScrap(
                                        accessToken, widget.scrapId, content);

                                    // 수정 후 성공 메시지를 표시하고 이전 화면으로 돌아가기
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('스크랩이 성공적으로 수정되었습니다.')),
                                    );

                                    Navigator.pop(context);
                                  } catch (e) {
                                    print('Failed to update scrap: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('스크랩 수정 실패: $e')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3A2E6A),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40.0),
                                  ),
                                ),
                                child: const Text(
                                  '저장하기',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
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
            );
          }
        },
      ),
    );
  }
}
