import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'ai_placelist_screen.dart';

const Color primaryColor = Color(0xFF40CDBC);

class AiPickScreen extends StatefulWidget {
  const AiPickScreen({super.key});

  @override
  State<AiPickScreen> createState() => _AiPickScreenState();
}

class _AiPickScreenState extends State<AiPickScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _lastUserPrompt;

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
      _messages.add(ChatMessage(sender: 'user', text: rawInput));
      _isLoading = true;
      _lastUserPrompt = rawInput;
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
- 사용자의 질문에 다음 키워드(지역명)가 포함되면 모두 인천 관련 질문으로 간주하세요:

  ✅ 인천 전체 구·군:
  "인천", "송도", "중구", "동구", "미추홀구", "연수구", "남동구", "부평구", "계양구", "서구", "강화군", "옹진군"

  ✅ 주요 읍·면·동:
  "강화읍", "길상면", "양도면", "불은면", "송해면", "백령면", "대청면", "연평면", "자월면", "영흥면",
  "운서동", "영종동", "중산동", "북성동", "연안동", "신포동", "용유동",
  "숭의동", "주안동", "도화동", "문학동", "용현동", "학익동",
  "송도동", "연수동", "동춘동", "옥련동", "청학동",
  "구월동", "간석동", "논현동", "만수동", "서창동",
  "부평동", "산곡동", "갈산동", "청천동", "십정동",
  "작전동", "계산동", "효성동", "임학동",
  "청라동", "검암동", "당하동", "가정동", "석남동", "원당동"

📍 [근처 장소 응답 기준]
- 사용자가 "근처", "주변", "가까운", "부근", "인근" 같은 단어를 썼다면, 실제 물리적으로 가까운 장소(보통 3~5km 이내)만 추천하세요.
- 예를 들어 "월미도 근처 코스"라고 하면 월미도 주변 도보/자전거 거리의 장소만 제시하세요.
- 송도, 강화도처럼 멀리 떨어진 곳은 "근처"로 취급하지 마세요.

- 질문이 모호하더라도 문맥상 인천에 대한 추가 질문일 경우에는 자연스럽게 이어서 답변하세요.
- 단, "서울", "부산", "제주" 등 인천 외 지역이 명확히 언급되면 "죄송합니다, 인천 지역 여행만 도와드릴 수 있습니다."라고 답변하세요.

📌 [장소 수]
- 항상 장소를 **최소 3곳 이상** 추천하세요.

📝 [답변 형식]
- 각 추천 장소는 "1. 장소명\\n설명" 형태로 작성하세요.
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
      if (text.isEmpty || text.length < 3) continue;
      if (text.contains("여행되세요") || text.contains("즐기세요") || text.contains("감사합니다")) continue;
      if (!RegExp(r'^\d+\.\s').hasMatch(text)) continue;

      text = text.replaceAll(RegExp(r'[^\w\s가-힣()\-]'), '');

      final cleaned = text.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
      if (cleaned.length < 3) continue;

      places.add(cleaned);
    }

    return places;
  }

  String getButtonLabel(String question) {
    if (question.contains("맛집")) return "🍽️ 맛집 위치 지도에서 보기";
    if (question.contains("보관소")) return "🔒 자전거 보관소 지도에서 보기";
    if (question.contains("코스") || question.contains("자전거")) return "🚲 추천 자전거 코스 지도에서 보기";
    return "📍 장소 위치 지도에서 보기";
  }

  @override
  Widget build(BuildContext context) {
    final aiReply = _messages.lastWhere(
      (m) => m.sender == 'ai',
      orElse: () => ChatMessage(sender: 'ai', text: ''),
    ).text;

    final extractedPlaces = extractPlaces(aiReply);
    final lastUserQuestion = _messages.lastWhere((m) => m.sender == 'user', orElse: () => ChatMessage(sender: 'user', text: '')).text;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 챗봇 도우미 - 이음이'),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ..._messages.map((msg) => Align(
                      alignment: msg.sender == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: msg.sender == 'user' ? primaryColor.withOpacity(0.2) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg.text),
                      ),
                    )),
                const SizedBox(height: 12),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (extractedPlaces.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AiPlaceListScreen(places: extractedPlaces),
                              ),
                            );
                          },
                          icon: const Icon(Icons.map),
                          label: Text(getButtonLabel(lastUserQuestion)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _messages.clear();
                                    _controller.clear();
                                    _lastUserPrompt = null;
                                    _isLoading = false;
                                  });
                                },
                          icon: const Icon(Icons.refresh),
                          label: const Text("🔄 다시 추천 받기"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
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
                        backgroundColor: primaryColor.withOpacity(0.1),
                        foregroundColor: primaryColor,
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
                      hintText: '이음이에게 무엇이든 물어보세요!',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: const Icon(Icons.chat_bubble_outline),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: primaryColor),
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
