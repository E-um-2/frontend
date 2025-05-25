import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../course/course_info_input_screen.dart';

class WriteCourseScreen extends StatefulWidget {
  const WriteCourseScreen({super.key});

  @override
  State<WriteCourseScreen> createState() => _WriteCourseScreenState();
}

class _WriteCourseScreenState extends State<WriteCourseScreen> {
  // 사용자가 찍은 점들을 저장하는 리스트
  final List<LatLng> _tappedPoints = [];

  // 지도 컨트롤러
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 구글 지도 위젯
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              // 초기 지도 위치 (인천대학교 송도캠퍼스 설정)
              target: LatLng(37.37431713137547, 126.63386945666375),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              // 지도 생성 시 컨트롤러 저장
              _mapController = controller;
            },
            onTap: (LatLng latLng) {
              // 지도를 탭하면 해당 위치를 리스트에 추가
              setState(() {
                _tappedPoints.add(latLng);
              });
            },
            // 사용자가 찍은 점들을 마커로 표시
            markers: _tappedPoints.map((point) {
              return Marker(
                markerId: MarkerId(point.toString()),
                position: point,
              );
            }).toSet(),
            // 찍은 점들을 순서대로 선으로 연결 (Polyline)
            polylines: {
              Polyline(
                polylineId: const PolylineId('user_path'),
                points: _tappedPoints,
                color: Colors.blue,
                width: 4,
              )
            },
          ),

          // 하단의 '다음으로' 버튼
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                // 점이 2개 이상 있어야 버튼 활성화
                onPressed: _tappedPoints.length < 2 // 찍은 점 2개 미만이면, null (버튼 비활성화)
                    ? null
                    : () {
                  // TODO: 다음 화면으로 _tappedPoints 넘기기
                  // 예: Navigator.push(...)
                  _showCourseInfoBottomSheet(context, _tappedPoints); // 버튼 2개 이상 찍으면 버튼 활성화
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("다음으로", style: TextStyle(fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// 1. BottomSheet 함수 (코스 정보 입력하기 버튼 띄우기)
void _showCourseInfoBottomSheet(BuildContext context, List<LatLng> pathPoints) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("멋진 코스가 그려졌어요!", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // BottomSheet 닫기
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseInfoInputScreen(pathPoints: pathPoints),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("코스 정보 입력하기"),
          ),
        ],
      ),
    ),
  );
}
