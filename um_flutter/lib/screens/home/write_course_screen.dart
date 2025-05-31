import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../course/course_info_input_screen.dart';

import 'package:location/location.dart';

class WriteCourseScreen extends StatefulWidget {
  final LatLng? initialPosition; // 선택된 장소 좌표 (옵셔널)

  const WriteCourseScreen({super.key, this.initialPosition});

  @override
  State<WriteCourseScreen> createState() => _WriteCourseScreenState();
}

class _WriteCourseScreenState extends State<WriteCourseScreen> {
  final List<LatLng> _tappedPoints = [];
  GoogleMapController? _mapController;

  // 코스 그리기 누적 거리 관련
  double _totalDistanceKm = 0;


  BitmapDescriptor? _customMarker; // ✅ 커스텀 마커 변수 추가


  late LatLng _initialPosition;
  bool _isLocationReady = false; // 현재 위치 세팅 완료 여부

  @override
  void initState() {
    super.initState();

    // 경로그리기 마커 변화
    _loadCustomMarker(); // ✅ 이 줄 추가

    _initLocation();
  }


  // ✅ [추가] 현재 위치를 가져와서 _initialPosition에 설정
  Future<void> _initLocation() async {

    try {
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      final currentLocation = await location.getLocation();

      if (!mounted) return;
      setState(() {
        _initialPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        _isLocationReady = true;
      });
    } catch (e) {
      debugPrint('🚫 위치 초기화 실패: $e');
    }
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

  // 코스 그리기 중 누적 거리 표시 (km)
  double _calculateDistance(LatLng start, LatLng end) {
    const double R = 6371;
    double dLat = (end.latitude - start.latitude) * (3.141592653589793 / 180);
    double dLng = (end.longitude - start.longitude) * (3.141592653589793 / 180);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(start.latitude * (3.141592653589793 / 180)) *
                cos(end.latitude * (3.141592653589793 / 180)) *
                sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }



  @override
  Widget build(BuildContext context) {
    if (!_isLocationReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("코스 그리기"),
        leading: BackButton(), // ← 이건 생략해도 기본으로 뒤로가기 생김
      ),
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false, // 맵 + - 줌 비활성화
            mapToolbarEnabled: false, // 마커 눌렀을때 네비게이션 길찾기 등 하단에 뜨는것 비활성화
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (LatLng latLng) {
              setState(() {
                // 코스그리기 누적 거리 계산
                if (_tappedPoints.isNotEmpty) {
                  _totalDistanceKm += _calculateDistance(_tappedPoints.last, latLng);
                }

                _tappedPoints.add(latLng);
              });
            },
            markers: _tappedPoints.map((point) {
              return Marker(
                markerId: MarkerId(point.toString()),
                position: point,
                icon: _customMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // 파란색 마커
                anchor: Offset(0.5, 0.5),
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
                child: const Text("다음으로", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),

          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                "${_totalDistanceKm.toStringAsFixed(2)} km",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
            child: const Text("내 코스로 이동",style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    ),
  );
}
