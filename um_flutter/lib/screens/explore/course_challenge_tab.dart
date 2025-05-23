// lib/screens/explore/course_challenge_tab.dart
import 'package:flutter/material.dart';
import '../../widgets/course_card.dart';

class CourseChallengeTab extends StatelessWidget {
  const CourseChallengeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: const [
        CourseCard(
          title: 'Level 01. 사람 옆모습',
          location: '인천 청라 부근',
          distance: '20km',
          duration: '2시간 10분',
          imageUrl: 'lib/app/assets/images/course1.png',
          isCompleted: true,
        ),
        CourseCard(
          title: 'Level 02. 정사각형',
          location: '인천 청라 부근',
          distance: '20km',
          duration: '2시간 10분',
          imageUrl: 'lib/app/assets/images/course2.png',
          isCompleted: true,
        ),
        CourseCard(
          title: 'Level 03. 사람 옆모습',
          location: '인천 청라 부근',
          distance: '20km',
          duration: '2시간 10분',
          imageUrl: 'lib/app/assets/images/course3.png',
          isCompleted: false,
        ),
        CourseCard(
          title: 'Level 04. 사람 옆모습',
          location: '인천 청라 부근',
          distance: '20km',
          duration: '2시간 10분',
          imageUrl: 'lib/app/assets/images/course4.png',
          isCompleted: false,
        ),
      ],
    );
  }
}
