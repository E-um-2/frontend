import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:um_test/shared/screens/empty_course_screen.dart';
import '../../models/course_model.dart';
import '../../shared/widgets/course_card.dart';
import '../../shared/data/mock_course_data.dart';

class SavedCourseTab extends StatelessWidget {
  final int filter;
  const SavedCourseTab({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final List<CourseModel> allCourses = mocksavedCourses;

    final filteredCourses = allCourses.where((course) {
      if (filter == 0) return true;
      if (filter == 1) return course.isCompleted;
      return !course.isCompleted;
    }).toList();

    if (filteredCourses.isEmpty) {
      return EmptyState(
        imagePath: 'assets/images/empty_draw.png',
        description: '저장된 코스가 없어요!',
        subDescription: '사용자 개발 코스에서 저장해보세요',
        buttonLabel: '코스 구경하러 가기',
        onPressed: () {
          context.go('/explore');
        },
        buttonColor: const Color(0xFF00A2FF),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: filteredCourses
          .map((course) => CourseCard(course: course))
          .toList(),
    );
  }
}
