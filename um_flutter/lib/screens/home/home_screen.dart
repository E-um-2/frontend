import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;

  Set<Marker> _bikeMarkers = {};
  Set<Marker> _foodMarkers = {};
  Set<Marker> _landmarkMarkers = {};
  Set<Marker> _visibleMarkers = {};

  bool _showFood = false;
  bool _showLandmarks = false;
  bool _isMenuVisible = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadBikeStations();
    _loadFoodMarkers();
    _loadLandmarkMarkers();
  }

  Future<void> _initLocation() async {
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
  }

  Future<void> _loadBikeStations() async {
    final String jsonString = await rootBundle.loadString('assets/bike_stations.json');
    final List<dynamic> data = json.decode(jsonString);

    Set<Marker> loadedMarkers = {};

    for (var item in data) {
      final String? name = item['name'];
      final double? lat = double.tryParse(item['latitude'].toString());
      final double? lng = double.tryParse(item['longitude'].toString());

      if (lat != null && lng != null) {
        loadedMarkers.add(
          Marker(
            markerId: MarkerId(name ?? 'Unknown'),
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
  }

  Future<void> _loadFoodMarkers() async {
    final String jsonString = await rootBundle.loadString('assets/food_places.json');
    final List<dynamic> data = json.decode(jsonString);

    Set<Marker> food = {};

    for (var item in data) {
      final String? name = item['name'];
      final double? lat = double.tryParse(item['latitude'].toString());
      final double? lng = double.tryParse(item['longitude'].toString());

      if (lat != null && lng != null) {
        food.add(
          Marker(
            markerId: MarkerId("food_$name"),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          ),
        );
      }
    }

    _foodMarkers = food;
  }

  Future<void> _loadLandmarkMarkers() async {
    final String jsonString = await rootBundle.loadString('assets/landmarks.json');
    final List<dynamic> data = json.decode(jsonString);

    Set<Marker> landmarks = {};

    for (var item in data) {
      final String? name = item['name'];
      final String? description = item['description'];
      final double? lat = double.tryParse(item['latitude'].toString());
      final double? lng = double.tryParse(item['longitude'].toString());

      if (lat != null && lng != null) {
        final snippetText = (description != null && description.isNotEmpty)
            ? (description.length > 30 ? '${description.substring(0, 30)}...' : description)
            : '';

        landmarks.add(
          Marker(
            markerId: MarkerId("landmark_$name"),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: name,
              snippet: snippetText,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(description ?? '설명 없음',
                        style: const TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      }
    }

    _landmarkMarkers = landmarks;
    _updateVisibleMarkers();
  }

  void _updateVisibleMarkers() {
    setState(() {
      _visibleMarkers = {
        ..._bikeMarkers,
        if (_showFood) ..._foodMarkers,
        if (_showLandmarks) ..._landmarkMarkers,
      };
    });
  }

  void _toggleFoodMarkers() {
    setState(() {
      _showFood = !_showFood;
      _updateVisibleMarkers();
    });
  }

  void _toggleLandmarkMarkers() {
    setState(() {
      _showLandmarks = !_showLandmarks;
      _updateVisibleMarkers();
    });
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
          ),
          if (_isMenuVisible)
            Positioned(
              top: 80,
              right: 16,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _toggleFoodMarkers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showFood ? Colors.orange : Colors.grey,
                    ),
                    child: const Text("맛집"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _toggleLandmarkMarkers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showLandmarks ? Colors.green : Colors.grey,
                    ),
                    child: const Text("관광지"),
                  ),
                ],
              ),
            ),
          Positioned(
            right: 16,
            bottom: 140,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'robot',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _isMenuVisible = !_isMenuVisible;
                    });
                  },
                  child: Image.asset('assets/images/robot_icon.png', width: 24),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'location',
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    final location = await Location().getLocation();
                    final GoogleMapController controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.newLatLng(
                      LatLng(location.latitude!, location.longitude!),
                    ));
                  },
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("코스 그리기", style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
