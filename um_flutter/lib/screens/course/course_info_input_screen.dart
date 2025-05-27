// 새롭게 추가한 file - 자전거 경로를 입력받아서, 해당 코스 이름/설명 입력 UI 화면

/*
mport 'package:flutter/material.dart';
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

 */


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart'; // 고유 ID 생성용 (pubspec.yaml에 의존성 추가함)

class CourseInfoInputScreen extends StatefulWidget {
  final List<LatLng> pathPoints;

  const CourseInfoInputScreen({super.key, required this.pathPoints});

  @override
  State<CourseInfoInputScreen> createState() => _CourseInfoInputScreenState();
}

class _CourseInfoInputScreenState extends State<CourseInfoInputScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("코스 정보 입력")),
      body: Column(
        children: [
          // 📌 지도에 경로 다시 그리기
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.pathPoints.first,
                zoom: 15,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId("drawn_course"),
                  points: widget.pathPoints,
                  color: Colors.blue,
                  width: 4,
                )
              },
              markers: widget.pathPoints
                  .map((e) => Marker(markerId: MarkerId(e.toString()), position: e))
                  .toSet(),
            ),
          ),

          // 📌 입력창 (스크롤 가능한 영역)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "코스 이름"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: "예상 소요 시간 (예: 1시간)"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "코스 설명",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 저장 버튼
                  ElevatedButton(
                    onPressed: () {
                      final courseId = const Uuid().v4(); // 🔑 고유 ID 생성
                      final courseData = {
                        'id': courseId,
                        'name': nameController.text,
                        'time': timeController.text,
                        'description': descController.text,
                        'points': widget.pathPoints.map((e) => {'lat': e.latitude, 'lng': e.longitude}).toList(),
                        'createdAt': DateTime.now().toIso8601String(),
                      };

                      // TODO: 여기에 Firebase 저장 로직 들어갈 예정
                      print("저장할 코스 데이터: $courseData");

                      // 저장 완료 BottomSheet (다음 단계에서 구현)
                      _showSavedSheet(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("저장하기"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 저장 완료 메시지
  void _showSavedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("저장이 완료되었어요!", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst); // 홈으로 복귀
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("내 코스로 이동"),
            ),
          ],
        ),
      ),
    );
  }
}
