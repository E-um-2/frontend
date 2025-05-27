import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../shared/data/mock_course_data.dart';
import '../../shared/widgets/nav_header.dart';

class UserCourseDetailScreen extends StatefulWidget {
  final String courseId;

  const UserCourseDetailScreen({super.key, required this.courseId});

  @override
  State<UserCourseDetailScreen> createState() => _UserCourseDetailScreenState();
}

class _UserCourseDetailScreenState extends State<UserCourseDetailScreen> {
  late CourseModel course;
  bool isLiked = false;
  bool isScrapped = false;
  late int likes;
  late int scraps;

  @override
  void initState() {
    super.initState();
    course = mockUserDevelopedCourses.firstWhere(
      (c) => c.id == widget.courseId,
    );
    likes = course.likes ?? 0;
    scraps = course.scraps ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavHeader(title: ''),
      body: SafeArea(
        child: SingleChildScrollView(
          // ✅ 스크롤 가능하게 감싸기
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  course.imageUrl,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '○○님',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '05/20 13:22',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE0E0E0),
                ),
                const SizedBox(height: 18),

                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  course.location,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  '총 거리 : ${course.distance} | 소요 시간 : ${course.duration}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 20),
                Text(
                  course.description,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),

                const SizedBox(height: 20),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE0E0E0),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up_off_alt,
                        color: isLiked ? Colors.black : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isLiked = !isLiked;
                          likes += isLiked ? 1 : -1;
                        });
                      },
                    ),
                    Text('추천 $likes'),

                    const SizedBox(width: 24),

                    IconButton(
                      icon: Icon(
                        Icons.bookmark_border,
                        color: isScrapped ? Colors.black : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isScrapped = !isScrapped;
                          scraps += isScrapped ? 1 : -1;
                        });
                      },
                    ),
                    Text('스크랩 $scraps'),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
