import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ go() 사용 시 필요
import '../../shared/data/course_challenge_data.dart';
import '../../shared/widgets/course_card.dart';
import '../../models/course_model.dart';

class CourseChallengeTab extends StatelessWidget {
  final int filter;
  const CourseChallengeTab({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final List<ChallengeCourseModel> allCourses = challengeCourseList;

    final filteredCourses = allCourses.where((course) {
      if (filter == 0) return true;
      if (filter == 1) return course.isCompleted;
      return !course.isCompleted;
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: filteredCourses
          .map(
            (challengeCourse) => GestureDetector(
              onTap: () {
                // ✅ 디테일 페이지로 이동
                context.push('/challenge/${challengeCourse.id}');
              },
              child: CourseCard(challengeCourse: challengeCourse),
            ),
          )
          .toList(),
    );
  }
}
