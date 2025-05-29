import 'dart:io';
import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ dotenv import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 반드시 있어야 함

  await dotenv.load(); // fileName 생략: assets에서 자동 탐지

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
    );
  }
}
