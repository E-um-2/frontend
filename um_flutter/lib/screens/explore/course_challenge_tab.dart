import 'package:flutter/material.dart';
import '../../shared/widgets/course_card.dart';

class CourseChallengeTab extends StatelessWidget {
  final int filter;
  const CourseChallengeTab({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final allCourses = const [
      CourseCard(
        title: '사람 옆모습',
        location: '인천 청라 부근',
        distance: '20km',
        duration: '2시간 10분',
        imageUrl: 'assets/images/course1.png',
        isCompleted: true,
      ),
      CourseCard(
        title: '사람 옆모습',
        location: '인천 청라 부근',
        distance: '20km',
        duration: '2시간 10분',
        imageUrl: 'assets/images/course2.png',
        isCompleted: false,
      ),
      CourseCard(
        title: '사람 옆모습',
        location: '인천 청라 부근',
        distance: '20km',
        duration: '2시간 10분',
        imageUrl: 'assets/images/course3.png',
        isCompleted: true,
      ),
      CourseCard(
        title: '사람 옆모습',
        location: '인천 청라 부근',
        distance: '20km',
        duration: '2시간 10분',
        imageUrl: 'assets/images/course4.png',
        isCompleted: false,
      ),
    ];

    final filteredCourses = allCourses.where((course) {
      if (filter == 0) return true;
      if (filter == 1) return course.isCompleted;
      return !course.isCompleted;
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: filteredCourses,
    );
  }
}
