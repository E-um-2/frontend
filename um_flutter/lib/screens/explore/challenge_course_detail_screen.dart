import 'package:flutter/material.dart';
import '../../shared/data/course_challenge_data.dart';
import '../../shared/widgets/nav_header.dart';
import '../../shared/widgets/button.dart';
import 'package:go_router/go_router.dart';

class ChallengeCourseDetailScreen extends StatelessWidget {
  final String courseId;

  const ChallengeCourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final course = challengeCourseList.firstWhere((c) => c.id == courseId);
    final level = course.id.replaceAll(RegExp(r'[^0-9]'), '');

    return Scaffold(
      appBar: NavHeader(title: 'Level $level. ${course.title}'),
      body: SafeArea(
        child: SingleChildScrollView(
          // ✅ 전체 스크롤 가능
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                course.imageUrl,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("중심위치", course.location),
                    _buildInfoRow(
                      "소요시간/총거리",
                      "${course.duration} / ${course.distance}",
                    ),
                    _buildInfoRow(
                      "보상 e음 포인트",
                      "${course.eumPoint} point",
                      valueColor: const Color(0xFF00C2A0),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        course.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: "지금까지 "),
                            TextSpan(
                              text: "${course.challengers}명",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: "이 도전 성공했어요!"),
                          ],
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),

                    CommonButton(
                      text: "도전하기",
                      color: const Color(0xFF38CCBE),
                      onPressed: () {
                        context.push('/driving');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _labelStyle()),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: _valueStyle().copyWith(color: valueColor ?? Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _labelStyle() => const TextStyle(fontSize: 13, color: Colors.grey);
  TextStyle _valueStyle() =>
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
}
