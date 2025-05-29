import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/nav_header.dart';
import '../../shared/widgets/button.dart'; // 공통 버튼 컴포넌트
import '../../models/course_model.dart';
import '../../shared/data/mock_course_data.dart';

class DrawnCourseDetailScreen extends StatefulWidget {
  final DrawnCourseModel course;

  const DrawnCourseDetailScreen({super.key, required this.course}); // const 제거

  @override
  State<DrawnCourseDetailScreen> createState() =>
      _DrawnCourseDetailScreenState();
}

class _DrawnCourseDetailScreenState extends State<DrawnCourseDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course.title);
    _descriptionController = TextEditingController(
      text: widget.course.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleUpload() {
    final newCourse = UserDevelopedCourseModel(
      id: 'u${mockUserDevelopedCourses.length + 1}',
      title: _titleController.text,
      location: widget.course.location,
      distance: widget.course.distance,
      duration: widget.course.duration,
      imageUrl: widget.course.imageUrl,
      isCompleted: widget.course.isCompleted,
      description: _descriptionController.text,
      completedColor: widget.course.completedColor,
      likes: 0,
      scraps: 0,
      reports: 0,
      isUploadedByUser: true,
      authorName: '익명',
      createdAt: '05/28 14:00',
    );

    setState(() {
      mockUserDevelopedCourses.add(newCourse);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('사용자 개발 코스로 업로드됐습니다.')));
  }

  void _handleRideStart() {
    context.push('/riding_start');
  }

  void _handleSaveChanges() {
    setState(() {
      widget.course.title = _titleController.text;
      widget.course.description = _descriptionController.text;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('수정이 완료되었습니다.')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      appBar: NavHeader(
        title: '코스 정보',
        onBack: () => context.pop(),
        onDone: _handleSaveChanges,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                course.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),

                    Text(
                      '코스 거리: ${course.distance}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '주행 시간: ${course.duration}',
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      '코스 설명',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '코스에 대한 설명을 작성해주세요.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    CommonButton(
                      text: '주행하기',
                      color: const Color(0xFF00A2FF),
                      onPressed: _handleRideStart,
                    ),
                    const SizedBox(height: 12),
                    CommonButton(
                      text: '사용자 개발 코스로 올리기',
                      color: const Color(0xFF00A2FF),
                      onPressed: _handleUpload,
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
}
