import 'package:flutter/material.dart';
import 'edit_mypage_screen.dart';
import 'reward_screen.dart';
import 'riding_history_screen.dart';
import 'uploaded_course_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경 흰색
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60), // safe area 대체
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '마이페이지',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // 사용자 정보
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.lightBlue,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  '이음이',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.lightBlue,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditMypageScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text(
                    '수정하기',
                    style: TextStyle(fontSize: 13, color: Colors.lightBlue),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.lightBlue,
                    side: const BorderSide(color: Colors.lightBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 완료한 코스 진행도
          Container(
            width: double.infinity,
            color: const Color(0xFFE0F4FF),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '완주한 코스',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Container(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '6',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: ' /10',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 메뉴 리스트
          Expanded(
            child: Container(
              color: Colors.white, // 리스트 배경도 흰색
              child: ListView(
                children: [
                  _buildTile(context, '✨ 주행 기록', const RidingHistoryScreen()),
                  _buildTile(context, '✨ 목표 보상', const RewardScreen()),
                  _buildTile(
                    context,
                    '✨ 업로드한 코스',
                    const UploadedCourseScreen(),
                  ),
                  _buildTile(context, '✨ 설정', const Placeholder()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, Widget destination) {
    return Column(
      children: [
        ListTile(
          tileColor: Colors.white, // 개별 항목 배경도 흰색
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
