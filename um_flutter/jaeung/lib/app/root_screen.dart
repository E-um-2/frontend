import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/ai_pick_screen.dart';
import '../screens/course_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/my_page_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 2;

  final List<Widget> _screens = const [
    CourseScreen(),
    AIPickScreen(),
    HomeScreen(),
    ExploreScreen(),
    MyPageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// 탭 아이템별로 색상 다르게 설정
  Color _getSelectedColor(int index) {
    if (index == 0 || index == 2 || index == 4) {
      return const Color(0xFF00A2FF); // 내 코스, 홈, 마이
    } else {
      return const Color(0xFF00C2A0); // AI 추천, 둘러보기
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ 기본 배경 흰색으로 설정
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _getSelectedColor(_selectedIndex),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '내 코스'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI 추천'),
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
  }
}
