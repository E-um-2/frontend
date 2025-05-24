// lib/screens/explore/explore_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_topbar.dart';
import '../../widgets/toggle_header.dart';
import 'course_challenge_tab.dart';
import 'user_developed_tab.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '둘러보기',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomToggleHeader(
          leftLabel: '코스 챌린지',
          rightLabel: '사용자 개발 코스',
          selectedIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          activeColor: const Color(0xFF38CCBE),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _selectedIndex == 0
              ? const CourseChallengeTab()
              : const UserDevelopedTab(),
        ),
      ],
    );
  }
}
