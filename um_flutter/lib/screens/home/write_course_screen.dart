import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../course/course_info_input_screen.dart';

class WriteCourseScreen extends StatefulWidget {
  final LatLng? initialPosition; // 선택된 장소 좌표 (옵셔널)

  const WriteCourseScreen({super.key, this.initialPosition});

  @override
  State<WriteCourseScreen> createState() => _WriteCourseScreenState();
}

class _WriteCourseScreenState extends State<WriteCourseScreen> {
  final List<LatLng> _tappedPoints = [];
  GoogleMapController? _mapController;

  BitmapDescriptor? _customMarker; // ✅ 커스텀 마커 변수 추가


  late LatLng _initialPosition;

  @override
  void initState() {
    super.initState();

    // 경로그리기 마커 변화
    _loadCustomMarker(); // ✅ 이 줄 추가


    // 선택된 위치가 있으면 그걸로, 없으면 기존 기본 위치로 설정
    _initialPosition = widget.initialPosition ?? LatLng(37.37431713137547, 126.63386945666375);
  }

  void _loadCustomMarker() async {
    final descriptor = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/blue_ring_marker.png', // ✅ 경로는 pubspec.yaml에 등록된 대로
    );
    setState(() {
      _customMarker = descriptor;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (LatLng latLng) {
              setState(() {
                _tappedPoints.add(latLng);
              });
            },
            markers: _tappedPoints.map((point) {
              return Marker(
                markerId: MarkerId(point.toString()),
                position: point,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // 파란색 마커
              );
            }).toSet(),
            polylines: {
              Polyline(
                polylineId: const PolylineId('user_path'),
                points: _tappedPoints,
                color: Colors.blue,
                width: 4,
              )
            },
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _tappedPoints.length < 2
                    ? null
                    : () {
                        _showCourseInfoBottomSheet(context, _tappedPoints);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("다음으로", style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
            child: const Text("내 코스로 이동"),
          ),
        ],
      ),
    ),
  );
}
