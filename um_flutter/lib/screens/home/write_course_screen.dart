/*
import 'package:flutter/material.dart';

class WriteCourseScreen extends StatelessWidget {
  const WriteCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('코스 글 작성 화면')));
  }
}
*/


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
              // 초기 지도 위치 (Googleplex 근처)
              target: LatLng(37.42796133580664, -122.085749655962),
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
                onPressed: _tappedPoints.length < 2
                    ? null
                    : () {
                  // TODO: 다음 화면으로 _tappedPoints 넘기기
                  // 예: Navigator.push(...)
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
