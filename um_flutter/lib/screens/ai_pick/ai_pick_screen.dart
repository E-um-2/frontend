import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'ai_placelist_screen.dart';

const Color primaryColor = Color(0xFF40CDBC);

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
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

    final processedInput = (!rawInput.contains("인천") &&
        lastIncheon.text.isNotEmpty)
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
          'content':
          '''
너는 ‘이음이’라는 대한민국 인천 자전거 관광 추천 앱의 인공지능이야.  
사용자의 요청에 따라 인천광역시 안에 있는 실제 자전거 관광지를 정중한 말투로 추천하는 역할을 맡고 있어.

❗ 반드시 지켜야 할 규칙은 아래와 같아:

1. 사용자가 언급한 지역이 **대한민국 인천광역시 소속**인지 반드시 확인해.  
   - 예: 인천, 송도, 계양구, 청라, 영종도, 월미도 등  
   - 인천 소속이 아닌 지역은 절대 추천하지 마.

2. 장소는 **실제로 존재하고, 자전거를 타기 좋은 곳**만 추천해야 해.  
   - 장소 수가 3개 미만이어도 괜찮아. 있는 만큼 정성껏 추천해줘.

3. 반드시 **아래 출력 형식만 그대로 사용해서** 답변해.  
   - 서두나 인사말, 설명 등은 절대 쓰지 마.  
   - 형식을 변형하거나 다른 말 덧붙이지 마.  
   - 출력은 아래 예시처럼, 오직 숫자 + 장소명 + 줄바꿈 + 설명 형태로만 구성할 것:

1. 장소명
설명 (2~3줄, 자연스럽고 설득력 있게, 이모지를 섞어 시각적으로 보기 좋게 작성)

2. 장소명
설명

3. 장소명
설명

📌 추가 지침:
- 이모지(🚲 📍 🌊 🏞️ ☕ 등)는 자연스럽고 보기 좋게 섞어서 사용해.
- 장소명에는 따옴표, 볼드체 사용 절대 금지. 일반 텍스트로만 작성해.

          '''
        },
        ..._messages.map((m) =>
        {
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

  List<Map<String, String>> extractPlaces(String aiReply) {
    final lines = aiReply.trim().split('\n');
    final List<Map<String, String>> results = [];

    for (int i = 0; i < lines.length - 1; i++) {
      final titleLine = lines[i].trim();
      final descLine = lines[i + 1].trim();

      if (!RegExp(r'^\d+\.\s+').hasMatch(titleLine)) continue;
      final title = titleLine.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();

      if (title.isEmpty || descLine.isEmpty) continue;

      results.add({
        'title': title,
        'description': descLine,
      });

      i++; // 다음 라인은 이미 description으로 썼으니 skip
    }

    return results;
  }


  String getButtonLabel(String question) {
    if (question.contains("맛집")) return "🍽️ 맛집 위치 지도에서 보기";
    if (question.contains("보관소")) return "🔒 자전거 보관소 지도에서 보기";
    if (question.contains("코스") || question.contains("자전거"))
      return "위치 보러 가기";
    return "위치 보러 가기";
  }

  @override
  Widget build(BuildContext context) {
    final aiReply = _messages
        .lastWhere(
          (m) => m.sender == 'ai',
      orElse: () => ChatMessage(sender: 'ai', text: ''),
    )
        .text;

    final extractedPlaces = extractPlaces(aiReply);
    final lastUserQuestion = _messages
        .lastWhere((m) => m.sender == 'user',
        orElse: () => ChatMessage(sender: 'user', text: ''))
        .text;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '이음봇',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ..._messages.map((msg) =>
                    Align(
                      alignment: msg.sender == 'user'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: msg.sender == 'user'
                              ? primaryColor.withOpacity(0.2)
                              : Colors.grey[200],
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
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AiPlaceListScreen(
                                            places: extractedPlaces),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(getButtonLabel(lastUserQuestion),
                                  style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: ElevatedButton(
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("다시 추천 받기",
                                  style: TextStyle(fontSize: 16)),
                            ),
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
                        backgroundColor: const Color(0xFFF2F2F2),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: Text(q,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
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
                      hintText: '이음봇에게 무엇이든 물어보세요!',
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
