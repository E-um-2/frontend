import 'package:flutter/material.dart';
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

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: filteredCourses
          .map((course) => CourseCard(course: course))
          .toList(),
    );
  }
}
