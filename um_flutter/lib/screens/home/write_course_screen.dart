import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../course/course_info_input_screen.dart';

class WriteCourseScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final bool fromAi;
  final List<LatLng>? aiPlaces;
  final List<String>? aiPlaceNames;

  const WriteCourseScreen({
    super.key,
    this.initialPosition,
    this.fromAi = false,
    this.aiPlaces,
    this.aiPlaceNames,
  });

  @override
  State<WriteCourseScreen> createState() => _WriteCourseScreenState();
}

class _WriteCourseScreenState extends State<WriteCourseScreen> {
  final List<LatLng> _tappedPoints = [];
  GoogleMapController? _mapController;

  BitmapDescriptor? _customMarker;
  BitmapDescriptor? _aiMarker;
  Set<Marker> _aiMarkers = {};

  late LatLng _initialPosition;
  bool _isLocationReady = false;
  bool _aiMarkersReady = false;

  double _totalDistanceKm = 0;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkerAndAiMarkers();
    _initLocation();
  }

  Future<BitmapDescriptor> getResizedMarker(String assetPath, int width) async {
    final ByteData byteData = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: width,
    );
    final frame = await codec.getNextFrame();
    final resized = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(resized!.buffer.asUint8List());
  }

  void _loadCustomMarkerAndAiMarkers() async {
    try {
      final descriptor = await getResizedMarker('assets/images/blue_ring_marker.png', 80);
      final aiIcon = await getResizedMarker('assets/images/red_pin_marker.png', 150);

      if (!mounted) return;

      setState(() {
        _customMarker = descriptor;
        _aiMarker = aiIcon;
        _aiMarkersReady = true;

        if (widget.fromAi && widget.aiPlaces != null) {
          _aiMarkers = widget.aiPlaces!.asMap().entries.map((entry) {
            final index = entry.key;
            final latLng = entry.value;
            final title = (widget.aiPlaceNames != null && widget.aiPlaceNames!.length > index)
                ? widget.aiPlaceNames![index]
                : "추천 장소";
            return Marker(
              markerId: MarkerId("ai_\${latLng.latitude}_\${latLng.longitude}"),
              position: latLng,
              icon: _aiMarker!,
              infoWindow: InfoWindow(title: title),
            );
          }).toSet();
        }
      });
    } catch (e) {
      debugPrint("❌ 마커 이미지 로딩 실패: \$e");
    }
  }

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
        _initialPosition = widget.initialPosition ?? LatLng(currentLocation.latitude!, currentLocation.longitude!);
        _isLocationReady = true;
      });
    } catch (e) {
      debugPrint('🚫 위치 초기화 실패: \$e');
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double R = 6371;
    double dLat = (end.latitude - start.latitude) * (pi / 180);
    double dLng = (end.longitude - start.longitude) * (pi / 180);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(start.latitude * (pi / 180)) *
                cos(end.latitude * (pi / 180)) *
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

    final Set<Marker> userMarkers = _tappedPoints.map((point) {
      return Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        icon: _customMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 0.5),
      );
    }).toSet();

    final Set<Marker> allMarkers = {..._aiMarkers, ...userMarkers};

    return Scaffold(
      appBar: AppBar(
        title: const Text("코스 그리기"),
        leading: const BackButton(),
      ),
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 16,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (LatLng latLng) {
              setState(() {
                if (_tappedPoints.isNotEmpty) {
                  _totalDistanceKm += _calculateDistance(_tappedPoints.last, latLng);
                }
                _tappedPoints.add(latLng);
              });
            },
            markers: allMarkers,
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
                "\${_totalDistanceKm.toStringAsFixed(2)} km",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
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
              Navigator.pop(context);
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
            child: const Text("내 코스로 이동", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
