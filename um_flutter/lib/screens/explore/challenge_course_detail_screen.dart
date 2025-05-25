import 'package:flutter/material.dart';
import '../../shared/data/course_challenge_data.dart'; // 데이터 리스트
import '../../shared/widgets/nav_header.dart'; // ✅ NavHeader import

class ChallengeCourseDetailScreen extends StatelessWidget {
  final String courseId;

  const ChallengeCourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final course = challengeCourseList.firstWhere((c) => c.id == courseId);

    return Scaffold(
      appBar: NavHeader(title: course.title), // ✅ 공용 상단바로 교체
      body: SingleChildScrollView(
        // ✅ 스크롤 가능하게 감싸기 (내용이 많을 경우 대비)
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(course.imageUrl),
            ),
            const SizedBox(height: 16),
            Text("중심위치: ${course.location}"),
            Text("거리: ${course.distance}, 시간: ${course.duration}"),
            Text("보상: ${course.eumPoint} point"),
            Text("도전 성공자 수: ${course.challengers}명"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                course.description,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
