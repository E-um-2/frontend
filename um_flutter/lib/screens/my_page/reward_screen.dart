import 'package:flutter/material.dart';
import '../../shared/widgets/nav_header.dart'; // ✅ 경로 확인해서 수정해줘

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  final int completedCourses = 6; // ✅ 현재까지 완주한 코스 수

  @override
  Widget build(BuildContext context) {
    final List<int> rewardGoals = [1, 3, 5, 7, 10, 15, 20, 25, 30];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const NavHeader(title: '목표 보상'), // ✅ 공용 헤더 사용
      body: Column(
        children: [
          const SizedBox(height: 12),

          // 상단 일러스트
          Image.asset('assets/images/reward_header.png', height: 120),

          const SizedBox(height: 8),
          const Text(
            '다양한 코스를 달리며 포인트를 모아봐요',
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 16),

          // 리워드 그리드
          Expanded(
            child: Container(
              color: const Color(0xFFE0F4FF),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: GridView.builder(
                itemCount: rewardGoals.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final goal = rewardGoals[index];
                  final isUnlocked = completedCourses >= goal;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Image.asset(
                            isUnlocked
                                ? 'assets/images/reward_unlocked.png'
                                : 'assets/images/reward_locked.png',
                            width: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('코스 $goal개'),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
