import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:um_test/shared/screens/empty_course_screen.dart';
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

    if (filteredCourses.isEmpty) {
      return EmptyState(
        imagePath: 'assets/images/empty_draw2.png',
        description: '아직 올라온 코스가 없어요',
        subDescription: '새로운 코스를 올려봐요!',
        buttonLabel: '내가 만든 코스 올리기',
        onPressed: () {
          context.go('/course');
        },
        buttonColor: const Color(0xFF38CCBE),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: filteredCourses
          .map(
            (course) => GestureDetector(
              onTap: () {
                context.push('/user-course/${course.id}');
              },
              child: CourseCard(course: course),
            ),
          )
          .toList(),
    );
  }
}
