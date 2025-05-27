// 주행하기 시연용 전체 코드 (마커 표시 포함)
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DrivingScreen extends StatefulWidget {
  const DrivingScreen({super.key});

  @override
  State<DrivingScreen> createState() => _DrivingScreenState();
}

class _DrivingScreenState extends State<DrivingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _mapController;

  final List<LatLng> _routePolyline = [
    LatLng(37.376146, 126.637759),
    LatLng(37.379403, 126.632448),
    LatLng(37.373981, 126.626708),
    LatLng(37.370536, 126.632598),
    LatLng(37.375942, 126.637564),
  ];

  final List<LatLng> _userPath = [];
  LatLng? _currentPosition;

  StreamSubscription<LocationData>? _locationSubscription;
  final Location _location = Location();
  bool _isRiding = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  bool _showBikeStations = true;
  bool _showLandmarks = false;
  bool _isCameraLocked = true;

  Set<Marker> _bikeMarkers = {};
  Set<Marker> _landmarkMarkers = {};
  Set<Marker> _visibleMarkers = {};

  Set<Polyline> get _polylines {
    final lines = <Polyline>{};
    if (_isRiding || (!_isRiding && _userPath.isNotEmpty)) {
      lines.add(
        Polyline(
          polylineId: const PolylineId('userPath'),
          points: _userPath,
          color: Colors.deepPurple,
          width: 5,
        ),
      );
    }
    if (_isRiding) {
      lines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _routePolyline,
          color: Colors.lightBlue,
          width: 3,
        ),
      );
    }
    return lines;
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadBikeStations();
    _loadLandmarkMarkers();
  }

  Future<void> _initLocation() async {
    final current = await _location.getLocation();
    setState(() {
      _currentPosition = LatLng(current.latitude!, current.longitude!);
    });
  }

  void _startRide() async {
    setState(() {
      _isRiding = true;
      _userPath.clear();
      _elapsedSeconds = 0;
      _isCameraLocked = true;
    });

    _locationSubscription = _location.onLocationChanged.listen((loc) {
      final point = LatLng(loc.latitude!, loc.longitude!);
      setState(() {
        _userPath.add(point);
        _currentPosition = point;
      });
      if (_isCameraLocked) {
        _mapController.animateCamera(CameraUpdate.newLatLng(point));
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _endRide() async {
    await _locationSubscription?.cancel();
    _timer?.cancel();

    setState(() {
      _isRiding = false;
    });
  }

  String _formattedTime() {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _toggleBikeMarkers() {
    setState(() {
      _showBikeStations = !_showBikeStations;
      _updateVisibleMarkers();
    });
  }

  void _toggleLandmarkMarkers() {
    setState(() {
      _showLandmarks = !_showLandmarks;
      _updateVisibleMarkers();
    });
  }

  void _updateVisibleMarkers() {
    setState(() {
      _visibleMarkers.clear();
      if (_showBikeStations) _visibleMarkers.addAll(_bikeMarkers);
      if (_showLandmarks) _visibleMarkers.addAll(_landmarkMarkers);
    });
  }

  Future<void> _loadBikeStations() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/bike_stations.json');
      final List<dynamic> data = json.decode(jsonString);
      Set<Marker> loadedMarkers = {};

      for (var item in data) {
        final String? name = item['name'];
        final double? lat = item['latitude'] is double ? item['latitude'] : double.tryParse(item['latitude'].toString());
        final double? lng = item['longitude'] is double ? item['longitude'] : double.tryParse(item['longitude'].toString());

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

      _bikeMarkers = loadedMarkers;
      _updateVisibleMarkers();
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
        final double? lat = item['latitude'] is double ? item['latitude'] : double.tryParse(item['latitude'].toString());
        final double? lng = item['longitude'] is double ? item['longitude'] : double.tryParse(item['longitude'].toString());

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
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          );
        }
      }

      _landmarkMarkers = landmarks;
      _updateVisibleMarkers();
    } catch (e) {
      debugPrint('랜드마크 로딩 중 오류: $e');
    }
  }

  Future<void> _goToCurrentLocation() async {
    final location = await _location.getLocation();
    if (location.latitude != null && location.longitude != null) {
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(location.latitude!, location.longitude!),
        ),
      );
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
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
              zoom: 16,
            ),
            onMapCreated: (controller) {
              _controller.complete(controller);
              _mapController = controller;
            },
            onCameraMoveStarted: () {
              _isCameraLocked = false;
            },
            polylines: _polylines,
            markers: _visibleMarkers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            bottom: 130,
            left: 20,
            right: 20,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('주행시간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_formattedTime(), style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 8),
                    const Text(
                      '특정 체크인 이탈되면 코스 탈락이 될 수도 있어요',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _isRiding ? _endRide : _startRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(260, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  _isRiding ? '주행 종료' : '주행하기',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 240,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'toggleBike',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _toggleBikeMarkers,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.pedal_bike, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'toggleLandmark',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _toggleLandmarkMarkers,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.account_balance, color: Colors.green),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'locationButton',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _goToCurrentLocation,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
