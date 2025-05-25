// 새롭게 추가한 file - 자전거 경로를 입력받아서, 해당 코스 이름/설명 입력 UI 화면
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CourseInfoInputScreen extends StatelessWidget {
  final List<LatLng> pathPoints;

  const CourseInfoInputScreen({super.key, required this.pathPoints});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("코스 정보 입력")),
      body: Center(child: Text("경로 점 개수: ${pathPoints.length}")),
    );
  }
}
