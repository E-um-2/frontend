import 'package:flutter/material.dart';
import '../../shared/data/mock_course_data.dart';
import '../../shared/widgets/course_card.dart';
import '../../models/course_model.dart';

class UserDevelopedTab extends StatelessWidget {
  final int filter;
  const UserDevelopedTab({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final List<CourseModel> allCourses = mockUserDevelopedCourses;

    final filteredCourses = allCourses.where((course) {
      if (filter == 0) return true;
      if (filter == 1) return course.isCompleted;
      return !course.isCompleted;
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: filteredCourses
          .map((course) => CourseCard(course: course)) // ✅ 단일 파라미터 전달
          .toList(),
    );
  }
}
