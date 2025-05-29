import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/course_card.dart';
import '../../shared/screens/empty_course_screen.dart';
import '../../models/course_model.dart';
import '../../shared/data/mock_course_data.dart';
import 'drawn_course_detail_screen.dart'; // ← 추가!

class DrawnCourseTab extends StatelessWidget {
  final int filter;
  const DrawnCourseTab({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final List<DrawnCourseModel> allCourses = mockDrawnCourses;

    final filteredCourses = allCourses.where((course) {
      if (filter == 0) return true;
      if (filter == 1) return course.isCompleted;
      return !course.isCompleted;
    }).toList();

    if (filteredCourses.isEmpty) {
      return EmptyState(
        imagePath: 'assets/images/empty_draw.png',
        description: '아직 제작된 코스가 없어요!',
        subDescription: '원하는 코스를 그려봐요',
        buttonLabel: '새로운 코스 그리기',
        onPressed: () {
          context.go('/home');
        },
        buttonColor: const Color(0xFF00A2FF),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: filteredCourses.map((course) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DrawnCourseDetailScreen(course: course),
              ),
            );
          },
          child: CourseCard(course: course),
        );
      }).toList(),
    );
  }
}
