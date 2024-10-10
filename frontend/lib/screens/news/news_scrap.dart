import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/api/news_api_service.dart';
import 'package:frontend/screens/news/news_my_scrap.dart';

class NewsScrapScreen extends StatefulWidget {
  final String scrapId;

  const NewsScrapScreen({Key? key, required this.scrapId}) : super(key: key);

  @override
  _NewsScrapScreenState createState() => _NewsScrapScreenState();
}

class _NewsScrapScreenState extends State<NewsScrapScreen> {
  quill.QuillController? _controller; // null로 시작
  final FocusNode _focusNode = FocusNode();
  final storage = FlutterSecureStorage();
  late Future<void> scrapDataFuture;
  String? scrapTitle;

  @override
  void initState() {
    super.initState();
    scrapDataFuture = _loadScrapData();
  }

  Future<void> _loadScrapData() async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please log in.');
      }

      // 서버에서 스크랩 데이터 가져오기
      final scrapData =
          await NewsService().fetchScrap(accessToken, widget.scrapId);

      // UTF-8로 데이터 디코딩 (필요에 따라)
      String decodedContent = utf8.decode(scrapData.content.codeUnits);
      String decodedTitle =
          utf8.decode(scrapData.title.codeUnits); // title도 UTF-8로 디코딩
      print('Decoded Scrap Data: $decodedContent'); // 가져온 데이터 로그 출력
      print('Decoded Title: $decodedTitle'); // 가져온 타이틀 로그 출력

      // Delta JSON이 아니라 일반 텍스트일 경우 처리
      if (decodedContent.isNotEmpty) {
        // 일반 텍스트를 Delta Document로 변환
        final doc = quill.Document()..insert(0, decodedContent);

        setState(() {
          scrapTitle = decodedTitle;
          _controller = quill.QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          );
        });
      } else {
        print('No content found in scrapData.');
      }
    } catch (e) {
      print('Failed to load scrap data: $e');
    }
  }

  // 형광펜 기능을 추가하는 메서드
  void _applyBackgroundColor() {
    _controller?.formatSelection(quill.Attribute(
      'background',
      quill.AttributeScope.inline,
      '#FFFF00', // 노란색 배경
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
            // _controller가 초기화된 후에만 에디터를 렌더링
            if (_controller == null) {
              return const Center(child: Text('Editor is not initialized.'));
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scrapTitle ?? "스크랩 수정하기",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    thickness: 1,
                    color: Color.fromARGB(255, 201, 201, 201),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: quill.QuillEditor(
                      controller: _controller!,
                      scrollController: ScrollController(),
                      focusNode: _focusNode,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.format_bold),
                        onPressed: () {
                          _controller?.formatSelection(quill.Attribute.bold);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_italic),
                        onPressed: () {
                          _controller?.formatSelection(quill.Attribute.italic);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_underline),
                        onPressed: () {
                          _controller
                              ?.formatSelection(quill.Attribute.underline);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_color_fill),
                        onPressed: _applyBackgroundColor, // 형광펜 기능 버튼
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            String? accessToken =
                                await storage.read(key: 'accessToken');
                            if (accessToken == null || accessToken.isEmpty) {
                              throw Exception(
                                  'No access token found. Please log in.');
                            }

                            final contentJson = jsonEncode(
                                _controller?.document.toDelta().toJson());

                            print('저장된 뉴스 내용 (Delta JSON): $contentJson');

                            await NewsService().updateScrap(
                                accessToken, widget.scrapId, contentJson);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('스크랩이 성공적으로 수정되었습니다.')),
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NewsMyScrapScreen(),
                              ),
                            );
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
                              vertical: 16.0, horizontal: 40.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                        ),
                        child: const Text(
                          '저장하기',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
