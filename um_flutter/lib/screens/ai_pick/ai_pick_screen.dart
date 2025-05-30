import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'ai_placelist_screen.dart';
import 'package:um_test/screens/home/write_course_screen.dart';

class AiPickScreen extends StatefulWidget {
  const AiPickScreen({super.key});

  @override
  State<AiPickScreen> createState() => _AiPickScreenState();
}

class _AiPickScreenState extends State<AiPickScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  final List<String> presetQuestions = [
    "인천 자전거 코스 추천해줘",
    "날씨 좋은 날 갈만한 장소",
    "송도에서 출발하는 코스",
    "월미도 근처 코스 알려줘",
    "계양구 자전거길 있어?",
  ];


  void _handleSend({String? prompt}) async {
    final rawInput = prompt ?? _controller.text.trim();

    if (rawInput.isEmpty) return;

    final lastIncheon = _messages.reversed.firstWhere(
      (m) => m.sender == 'user' && m.text.contains("인천"),
      orElse: () => ChatMessage(sender: 'user', text: ''),
    );

    final processedInput = (!rawInput.contains("인천") && lastIncheon.text.isNotEmpty)
        ? "이전 인천 관련 대화의 연장 질문입니다. 인천 관련해서 더 추천해줘: $rawInput"
        : rawInput;

    setState(() {
      _messages.add(ChatMessage(sender: 'user', text: rawInput)); // 화면에는 사용자의 원문 표시
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
          - 줄바꿈(\n)을 활용해 보기 좋게 단락을 나누세요.
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

  List<String> extractPlaces(String aiReply) {
    final lines = aiReply.split('\n');
    final List<String> places = [];

    for (var line in lines) {
      var text = line.trim();

      // 1. 너무 짧거나 비어 있는 줄은 제외
      if (text.isEmpty || text.length < 3) continue;

      // 2. 마무리 인사말, 안내 멘트 필터링
      if (text.contains("여행되세요") || text.contains("즐기세요") || text.contains("감사합니다")) continue;

      // 3. "1. 송도 ~"처럼 번호로 시작하는 줄만 추출 (제목 줄만)
      if (!RegExp(r'^\d+\.\s').hasMatch(text)) continue;

      // 4. 특수문자 제거 (단순화)
      text = text.replaceAll(RegExp(r'[^\w\s가-힣]'), '');

      // 5. 장소 이름만 뽑기 (숫자 제거 포함)
      final cleaned = text.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();

      // 6. 너무 긴 문장은 제외
      if (cleaned.length > 30) continue;

      places.add(cleaned);
    }

    return places;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 자전거 코스 추천')),
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
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: presetQuestions.map((q) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () => _handleSend(prompt: q),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(q, style: const TextStyle(fontSize: 13)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

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

// ✅ 클래스 바깥에 위치해야 정상 작동
class ChatMessage {
  final String sender;
  final String text;

  ChatMessage({required this.sender, required this.text});
}
