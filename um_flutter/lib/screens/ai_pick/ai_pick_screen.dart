import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ai_placelist_screen.dart'; // 별도 파일로 분리된 장소 리스트 화면

List<String> extractPlaces(String aiReply) {
  final lines = aiReply.split('\n');
  final List<String> places = [];

  for (var line in lines) {
    var text = line.trim();

    // 모든 이모지 및 깨진 문자 제거
    text = text.replaceAll(
      RegExp(
        r'[\u{1F300}-\u{1F6FF}]|'   // Symbols & pictographs
        r'[\u{1F900}-\u{1F9FF}]|'   // Supplemental symbols
        r'[\u{2600}-\u{26FF}]|'     // Misc symbols
        r'[\u{2700}-\u{27BF}]|'     // Dingbats
        r'[^\u0000-\u007F\uAC00-\uD7A3\s]', // 비 ASCII, 비 한글 제거
        unicode: true,
      ),
      '',
    );

    // 설명 제거
    if (text.contains("추천") || text.contains("즐기세요") || text.contains("소개") || text.length < 2) {
      continue;
    }

    // 접미사 제거 (자전거 관련 단어)
    text = text.replaceAll(RegExp(r'(자전거\s*)?(도로|코스|길|경로)$'), '').trim();

    if (text.isNotEmpty && text.length <= 20) {
      places.add(text);
    }
  }

  return places.toSet().toList();
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  void _handleSend() async {
    final rawInput = _controller.text.trim();

    final lastIncheon = _messages.reversed.firstWhere(
      (m) => m.sender == 'user' && m.text.contains("인천"),
      orElse: () => ChatMessage(sender: 'user', text: ''),
    );

    final processedInput = (!rawInput.contains("인천") && lastIncheon.text.isNotEmpty)
        ? "이전 인천 관련 대화의 연장 질문입니다. 인천 관련해서 더 추천해줘: $rawInput"
        : rawInput;

    setState(() {
      _messages.add(ChatMessage(sender: 'user', text: rawInput));
      _isLoading = true;
    });

    _controller.clear();

    final reply = await getOpenRouterReply(processedInput);

    setState(() {
      _messages.add(ChatMessage(sender: 'ai', text: reply));
      _isLoading = false;
    });
  }

  Future<String> getOpenRouterReply(String input) async {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return '❗ OpenRouter API 키가 설정되지 않았습니다.';
    }

    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      'HTTP-Referer': 'http://localhost',
      'X-Title': 'um_flutter_gpt_app'
    };

    final body = jsonEncode({
      'model': 'openai/gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': '''
          당신은 인천 지역 여행만 전문으로 추천하는 AI입니다.

          💡 [응답 원칙]
          - 사용자가 어떤 질문을 하더라도, 그 질문이 인천과 연결될 수 있다면 인천 관련해서 답변하세요.
          - 예를 들어 "더 추천해줘", "어디가 좋아?" 같은 모호한 질문은 직전 대화 흐름을 고려해서 인천에 맞춰 응답하세요.
          - 사용자의 질문이 명확히 인천과 관련 있거나, "인천대", "송도", "월미도", "계양" 등 인천에 위치한 장소라면 모두 인천 관련 질문으로 간주하세요.
          - 질문이 모호하더라도 문맥상 인천에 대한 추가 질문일 경우에는 자연스럽게 이어서 답변하세요.
          - 단, "서울", "부산", "제주" 등 인천 외 지역이 명확히 언급되면 "죄송합니다, 인천 지역 여행만 도와드릴 수 있습니다."라고 답변하세요.

          📝 [답변 형식]
          - 줄바꿈(\\n)을 활용해 보기 좋게 단락을 나누세요.
          - 각 추천 장소는 제목 + 설명 형식으로 작성하세요.
          - 🚲 📍 🌊 같은 이모지를 적절히 활용하세요.
          '''
        },
        ..._messages.map((m) => {
              'role': m.sender == 'user' ? 'user' : 'assistant',
              'content': m.text,
            }),
        {'role': 'user', 'content': input}
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        final data = jsonDecode(response.body);
        return '❗ 오류: ${data['error']?['message'] ?? '응답 실패'}';
      }
    } catch (e) {
      return '🚨 네트워크 오류: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('OpenRouter 여행 추천')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.sender == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.text),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            child: ElevatedButton.icon(
              onPressed: () {
                final aiReply = _messages.lastWhere(
                  (m) => m.sender == 'ai',
                  orElse: () => ChatMessage(sender: 'ai', text: ''),
                ).text;

                final extractedPlaces = extractPlaces(aiReply);

                if (extractedPlaces.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("📭 AI가 추천한 장소가 없습니다.\n먼저 질문을 해주세요!")),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AiPlaceListScreen(places: extractedPlaces),
                  ),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text("📍 지도에서 추천 코스 보기"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: '여행 관련 질문을 해보세요!',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: const Icon(Icons.chat_bubble_outline),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String text;

  ChatMessage({required this.sender, required this.text});
}
