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
  Set<Marker> _landmarkMarkers = {};
  Set<Marker> _visibleMarkers = {};

  bool _showLandmarks = false;
  bool _showBikeStations = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadBikeStations();
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
            markerId: MarkerId('bike_${name ?? 'Unknown'}'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          ),
        );
      }
    }

    setState(() {
      _bikeMarkers = loadedMarkers;
    });

    _updateVisibleMarkers(); // 반드시 밖에서 호출!
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

    setState(() {
      _landmarkMarkers = landmarks;
      _updateVisibleMarkers();
    });
  }


  void _updateVisibleMarkers() {
    _visibleMarkers.clear();
    if (_showBikeStations) _visibleMarkers.addAll(_bikeMarkers);
    if (_showLandmarks) _visibleMarkers.addAll(_landmarkMarkers);
    setState(() {});
  }



  void _toggleLandmarkMarkers() {
    setState(() {
      _showLandmarks = !_showLandmarks;
      _updateVisibleMarkers();
    });
  }

  void _toggleBikeMarkers() {
    if (_showBikeStations) {
      setState(() {
        _showBikeStations = false;
      });
      _updateVisibleMarkers(); // 반드시 상태 바뀐 후 호출
    } else {
      setState(() {
        _showBikeStations = true;
      });
      _loadBikeStations(); // load 시 내부에서 updateVisibleMarkers 호출됨
    }
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
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          Positioned(
            right: 16,
            bottom: 140,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'toggleBike',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _toggleBikeMarkers,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.directions_bike, color: Colors.blue),
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
                  onPressed: () async {
                    final location = await Location().getLocation();
                    final controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.newLatLng(
                      LatLng(location.latitude!, location.longitude!),
                    ));
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(260, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("코스 그리기", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
