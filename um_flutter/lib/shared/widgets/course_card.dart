import 'package:flutter/material.dart';
import '../../models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel? course;
  final ChallengeCourseModel? challengeCourse;

  const CourseCard({super.key, this.course, this.challengeCourse})
    : assert(course != null || challengeCourse != null);

  Color _getCompletedColor(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '';
    if (route.contains('explore')) {
      return const Color(0xFF38CCBE); // 둘러보기
    } else if (route.contains('course')) {
      return const Color(0xFF00A2FF); // 내 코스
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final isChallenge = challengeCourse != null;
    final isUserCourse = course is UserDevelopedCourseModel;

    final imageUrl = isChallenge ? challengeCourse!.imageUrl : course!.imageUrl;
    final title = isChallenge
        ? 'Level ${challengeCourse!.id.replaceAll(RegExp(r'[^0-9]'), '')}. ${challengeCourse!.title}'
        : course!.title;
    final location = isChallenge ? challengeCourse!.location : course!.location;
    final distance = isChallenge ? challengeCourse!.distance : course!.distance;
    final duration = isChallenge ? challengeCourse!.duration : course!.duration;
    final isCompleted = isChallenge
        ? challengeCourse!.isCompleted
        : course!.isCompleted;
    final completedColor =
        course?.completedColor ?? _getCompletedColor(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      location,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      "$distance | $duration",
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isCompleted ? completedColor : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCompleted ? "주행완료" : "주행미완료",
                          style: TextStyle(
                            fontSize: 13,
                            color: isCompleted ? completedColor : Colors.grey,
                          ),
                        ),

                        // 🔹 사용자 개발 코스일 경우 추천/스크랩 표시
                        if (!isChallenge && isUserCourse) ...[
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.thumb_up_off_alt,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${(course as UserDevelopedCourseModel).likes}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.bookmark_outline,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${(course as UserDevelopedCourseModel).scraps}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(thickness: 1, height: 1, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}
