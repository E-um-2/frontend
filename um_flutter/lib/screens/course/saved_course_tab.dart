import 'package:flutter/material.dart';
import '../../shared/widgets/course_card.dart';

class SavedCourseTab extends StatelessWidget {
  final int filter;
  const SavedCourseTab({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final allCourses = const [
      CourseCard(
        title: '사람 옆모습',
        location: '인천 청라 부근',
        distance: '15km',
        duration: '1시간 40분',
        imageUrl: 'assets/images/course1.png',
        isCompleted: true,
      ),
      CourseCard(
        title: '네잎 클로버',
        location: '인천 문학산 부근',
        distance: '25km',
        duration: '2시간 30분',
        imageUrl: 'assets/images/course2.png',
        isCompleted: false,
      ),
      CourseCard(
        title: '나비 모양',
        location: '인천 서구',
        distance: '18km',
        duration: '1시간 50분',
        imageUrl: 'assets/images/course3.png',
        isCompleted: true,
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
