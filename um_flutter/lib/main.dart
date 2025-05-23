import 'package:flutter/material.dart';
import 'home_screen.dart'; // 경로는 파일명에 맞게 조정

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(), // 홈 화면 연결
    );
  }
}
