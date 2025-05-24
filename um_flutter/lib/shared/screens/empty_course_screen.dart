import 'package:flutter/material.dart';

class EmptyCourseScreen extends StatelessWidget {
  const EmptyCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('코스 없음 화면')));
  }
}
