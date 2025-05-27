import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:um_test/screens/home/write_course_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;

  Set<Marker> _bikeMarkers = {};
  Set<Marker> _landmarkMarkers = {};
  Set<Marker> _visibleMarkers = {};

  bool _showLandmarks = false;
  bool _showBikeStations = true;

  @override
  void initState() {
    super.initState();

     if (Platform.isAndroid || Platform.isIOS) {
        _initLocation(); // ✅ 모바일에서만 위치 초기화
      }
      _loadBikeStations();
      _loadLandmarkMarkers();

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
      setState(() {
        _currentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });
    } catch (e) {
      // ✅ Windows 등에서 예외 발생 시 무시
      print('🚫 위치 권한 초기화 실패: $e');


    }
  }


  Future<void> _loadBikeStations() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/bike_stations.json');
      final List<dynamic> data = json.decode(jsonString);

      Set<Marker> loadedMarkers = {};

      for (var item in data) {
        final String? name = item['name'];
        final double? lat = item['latitude'] is double
            ? item['latitude']
            : double.tryParse(item['latitude'].toString());
        final double? lng = item['longitude'] is double
            ? item['longitude']
            : double.tryParse(item['longitude'].toString());

        if (lat != null && lng != null && name != null) {
          loadedMarkers.add(
            Marker(
              markerId: MarkerId("bike_${name}_${lat}_$lng"),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
            ),
          );
        }
      }

      setState(() {
        _bikeMarkers = loadedMarkers;
        _updateVisibleMarkers();
      });
    } catch (e) {
      debugPrint('자전거 거치소 로딩 중 오류: $e');
    }
  }

  Future<void> _loadLandmarkMarkers() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/landmarks.json');
      final List<dynamic> data = json.decode(jsonString);

      Set<Marker> landmarks = {};

      for (var item in data) {
        final String? name = item['name'];
        final String? description = item['description'];
        final double? lat = item['latitude'] is double
            ? item['latitude']
            : double.tryParse(item['latitude'].toString());
        final double? lng = item['longitude'] is double
            ? item['longitude']
            : double.tryParse(item['longitude'].toString());

        if (lat != null && lng != null) {
          final snippetText = (description != null && description.isNotEmpty)
              ? (description.length > 20 ? '${description.substring(0, 30)}...' : description)
              : '';

          landmarks.add(
            Marker(
              markerId: MarkerId("landmark_${lat}_$lng"),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: name,
                snippet: snippetText,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name ?? '이름 없음',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              description ?? '설명 없음',
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                ),
                                child: const Text('닫기'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          );
        }
      }

      setState(() {
        _landmarkMarkers = landmarks;
        _updateVisibleMarkers();
      });
    } catch (e) {
      debugPrint('랜드마크 로딩 중 오류: $e');
    }
  }

  void _updateVisibleMarkers() {
    setState(() {
      _visibleMarkers.clear();
      if (_showBikeStations) _visibleMarkers.addAll(_bikeMarkers);
      if (_showLandmarks) _visibleMarkers.addAll(_landmarkMarkers);
    });
  }

  void _toggleLandmarkMarkers() {
    _showLandmarks = !_showLandmarks;
    _updateVisibleMarkers();
  }

  void _toggleBikeMarkers() {
    _showBikeStations = !_showBikeStations;
    _updateVisibleMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _visibleMarkers,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),
          Positioned(
            right: 16,
            bottom: 140,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: _showBikeStations
                        ? Border.all(color: Colors.blue, width: 2)
                        : null,
                  ),
                  child: FloatingActionButton(
                    heroTag: 'toggleBike',
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _toggleBikeMarkers,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.pedal_bike,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: _showLandmarks
                        ? Border.all(color: Colors.green, width: 2)
                        : null,
                  ),
                  child: FloatingActionButton(
                    heroTag: 'toggleLandmark',
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _toggleLandmarkMarkers,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'locationButton',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    try {
                      final location = await Location().getLocation();
                      if (location.latitude != null && location.longitude != null) {
                        final controller = await _controller.future;
                        controller.animateCamera(
                          CameraUpdate.newLatLng(
                            LatLng(location.latitude!, location.longitude!),
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('위치 이동 실패: $e');
                    }
                  },
                  shape: const CircleBorder(),
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 코스 그리기 화면 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WriteCourseScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(260, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "코스 그리기",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
