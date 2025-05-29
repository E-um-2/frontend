// lib/screens/explore/explore_screen.dart
import 'package:flutter/material.dart';
import '../../shared/widgets/toggle_header.dart';
import 'package:go_router/go_router.dart';
import 'drawn_course_tab.dart';
import 'saved_course_tab.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  int _selectedIndex = 0;
  int _selectedFilterIndex = 0; // 0: 전체, 1: 주행완료, 2: 주행미완료

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            context.go('/home'); // 내가 그린 코스 → 홈으로 이동
          } else {
            context.go('/explore'); // 저장된 코스 → 사용자개발 코스 이동
          }
        },
        backgroundColor: const Color(0xFF00A2FF),
        shape: const CircleBorder(),
        child: Icon(
          _selectedIndex == 0 ? Icons.edit : Icons.add,
          size: 28,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    '내 코스',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomToggleHeader(
                leftLabel: '내가 그린 코스',
                rightLabel: '저장된 코스',
                selectedIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                activeColor: const Color(0xFF00A2FF),
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
                  ? DrawnCourseTab(filter: _selectedFilterIndex)
                  : SavedCourseTab(filter: _selectedFilterIndex),
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
          activeColor: const Color(0xFF00A2FF), // 선택됐을 때 색
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF00A2FF); // 선택됨
            }
            return const Color(0xFF999999); // 비선택 상태
          }),
          visualDensity: const VisualDensity(
            horizontal: -2,
            vertical: 1,
          ), // 👈 간격 줄이기!
          materialTapTargetSize:
              MaterialTapTargetSize.shrinkWrap, // 👈 터치영역 최소화
          onChanged: (int? newValue) {
            setState(() {
              _selectedFilterIndex = newValue!;
            });
          },
        ),

        const SizedBox(width: 1),
        Text(label, style: TextStyle(fontSize: 14, color: Color(0xFF999999))),
      ],
    );
  }
}
