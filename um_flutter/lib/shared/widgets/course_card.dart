import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String location;
  final String distance;
  final String duration;
  final String imageUrl;
  final bool isCompleted;

  const CourseCard({
    super.key,
    required this.title,
    required this.location,
    required this.distance,
    required this.duration,
    required this.imageUrl,
    required this.isCompleted,
  });

  Color _getCompletedColor(BuildContext context) {
    // 현재 라우트 경로 기준으로 색 결정
    final route = ModalRoute.of(context)?.settings.name ?? '';

    if (route.contains('explore')) {
      return const Color(0xFF38CCBE); // 둘러보기 색상
    } else if (route.contains('course')) {
      return const Color(0xFF00A2FF); // 내 코스 색상
    }
    return Colors.green; // 기본값 또는 fallback
  }

  @override
  Widget build(BuildContext context) {
    final completedColor = _getCompletedColor(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      location,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      "$distance | $duration",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isCompleted ? completedColor : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCompleted ? "주행완료" : "주행미완료",
                          style: TextStyle(
                            fontSize: 13,
                            color: isCompleted ? completedColor : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(thickness: 1, height: 1, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}
