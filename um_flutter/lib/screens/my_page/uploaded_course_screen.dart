import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/nav_header.dart';
import '../../shared/screens/empty_course_screen.dart'; // ✅ 공용 EmptyState 컴포넌트 import

class UploadedCourseScreen extends StatelessWidget {
  const UploadedCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 사용자 업로드 코스 수 (0개인 상태)
    final int uploadedCount = 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const NavHeader(title: '업로드한 코스'),
      body: uploadedCount == 0
          ? EmptyState(
              imagePath: 'assets/images/empty_draw.png',
              description: '아직 업로드한 코스가 없어요!',
              subDescription: '코스를 그리고 달려보세요',
              buttonLabel: '코스 업로드하기',
              onPressed: () {
                context.go('/course'); // ✅ 코스 탭으로 이동
              },
              buttonColor: Colors.blue,
            )
          : const Center(child: Text('업로드된 코스 목록 표시 예정')),
    );
  }
}
