import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:um_test/screens/explore/challenge_course_detail_screen.dart';
import 'package:um_test/screens/explore/user_developred_course_detail_screen.dart';
import 'package:um_test/shared/data/mock_course_data.dart';
import 'package:um_test/shared/screens/driving_screen.dart';

import '../screens/home/home_screen.dart';
import '../screens/course/course_screen.dart';
import '../screens/ai_pick/ai_pick_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/my_page/my_page_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        final location = state.uri.path;

        return Scaffold(
          body: SafeArea(child: child),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _calculateIndex(location),
            onTap: (index) => _onTap(context, index),
            selectedItemColor: _getColor(_calculateIndex(location)),
            unselectedItemColor: Colors.grey,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.map), label: '내 코스'),
              BottomNavigationBarItem(
                icon: Icon(Icons.smart_toy),
                label: 'AI 추천',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_bike),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                label: '둘러보기',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: '마이',
              ),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/course',
          builder: (context, state) => const CourseScreen(),
        ),
        GoRoute(path: '/ai', builder: (context, state) => const AIPickScreen()),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/explore',
          builder: (context, state) => const ExploreScreen(),
        ),
        GoRoute(
          path: '/mypage',
          builder: (context, state) => const MyPageScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/driving',
      builder: (context, state) => const DrivingScreen(),
    ),
    GoRoute(
      path: '/challenge/:id', // 🔹 :id 는 동적 파라미터
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ChallengeCourseDetailScreen(courseId: id);
      },
    ),
    GoRoute(
      path: '/user-course/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return UserCourseDetailScreen(courseId: id); // 이제 오류 안 남
      },
    ),
  ],
);

int _calculateIndex(String location) {
  switch (location) {
    case '/course':
      return 0;
    case '/ai':
      return 1;
    case '/home':
      return 2;
    case '/explore':
      return 3;
    case '/mypage':
      return 4;
    default:
      return 2;
  }
}

void _onTap(BuildContext context, int index) {
  const paths = ['/course', '/ai', '/home', '/explore', '/mypage'];
  context.go(paths[index]);
}

Color _getColor(int index) {
  return (index == 0 || index == 2 || index == 4)
      ? const Color(0xFF00A2FF)
      : const Color(0xFF00C2A0);
}
