import 'package:flutter/material.dart';
import 'package:um_test/shared/widgets/nav_header.dart';

class DrivingScreen extends StatelessWidget {
  const DrivingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavHeader(title: ''), // 상단바는 빈 타이틀로
      body: const Center(
        child: Text('주행하기 화면'), // 콘텐츠는 여기서
      ),
    );
  }
}
