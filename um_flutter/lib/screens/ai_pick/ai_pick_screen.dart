import 'package:flutter/material.dart';

class AiRecommendationScreen extends StatelessWidget {
  const AiRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'AI 추천',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '혹시 인천에 자전거 타기 좋은 경로 추천해줄래?\n데이트 할거야',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '인천에서 자전거 데이트를 즐기기에 좋은 코스를 추천드릴게요. 아름다운 풍경과 함께 여유로운 시간을 보낼 수 있는 곳들입니다.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildCourse(
              number: '1.',
              title: '커넬웨이 수변공원 (청라)',
              description:
                  '청라호수공원에서 시작되는 인공수로를 따라 조성된 산책로와 자전거도로가 이어지는 코스로, 주변에 카페와 식당이 있어 데이트 코스로 안성맞춤입니다.',
              images: ['assets/images/img1.png', 'assets/images/img2.png'],
            ),
            _buildCourse(
              number: '2.',
              title: '인천대공원 -> 소래포구 -> 송도 달빛축제공원 코스',
              description:
                  '약 20km의 코스로, 인천대공원에서 출발해 송산 자전거도로를 따라 소래포구를 지나 송도 달빛축제공원까지 이어집니다. 탄탄한 도로 상태와 풍경이 매력적이며, 중간중간 쉬어갈 수 있는 명소와 먹거리가 많아 추천드립니다.',
              images: [],
            ),
            _buildCourse(
              number: '3.',
              title: '카페를 곁들인 산책 터널',
              description:
                  '카페와 체험 공간이 함께 있는 산책로와 연결된 터널에서 즐길 수 있는 코스로, 오랜만에 색다른 분위기 속에 자전거를 타며 데이트 하기 좋은 장소입니다. 위치는 송도 인근에 추천드립니다.',
              images: [],
            ),
            const Spacer(),
            TextField(
              decoration: InputDecoration(
                hintText: '무엇이든 물어보세요!',
                prefixIcon: const Icon(Icons.chat_bubble_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCourse({
    required String number,
    required String title,
    required String description,
    List<String> images = const [],
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                number,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (images.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(images[index], width: 100, fit: BoxFit.cover),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
              ),
            )
        ],
      ),
    );
  }
}
