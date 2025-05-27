import 'package:flutter/material.dart';
import '../../shared/widgets/toggle_header.dart';
import 'course_challenge_tab.dart';
import 'user_developed_tab.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedIndex = 0;
  int _selectedFilterIndex = 0; // 0: 전체, 1: 주행완료, 2: 주행미완료

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomToggleHeader(
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFilterRadio('전체', 0),
                  const SizedBox(width: 4),
                  _buildFilterRadio('주행완료', 1),
                  const SizedBox(width: 4),
                  _buildFilterRadio('주행미완료', 2),
                ],
              ),
            ),
            Expanded(
              child: _selectedIndex == 0
                  ? CourseChallengeTab(filter: _selectedFilterIndex)
                  : UserDevelopedTab(filter: _selectedFilterIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRadio(String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Radio(
          value: value,
          groupValue: _selectedFilterIndex,
          activeColor: const Color(0xFF38CCBE), // 선택됐을 때 색
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF38CCBE); // 선택됨
            }
            return const Color(0xFF999999); // 비선택 상태
          }),
          visualDensity: const VisualDensity(horizontal: -2, vertical: 1),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (int? newValue) {
            setState(() {
              _selectedFilterIndex = newValue!;
            });
          },
        ),
        const SizedBox(width: 1),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
        ),
      ],
    );
  }
}
