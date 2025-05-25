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

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadBikeStations();
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
            markers: _bikeMarkers,
          ),
          Positioned(
            right: 16,
            bottom: 120, // 로봇 버튼 (위쪽)
            child: FloatingActionButton(
              heroTag: 'robot',
              backgroundColor: Colors.white,
              onPressed: () {
                // TODO: 로봇 기능
              },
              child: Image.asset('assets/images/robot_icon.png', width: 24),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 50, // 내 위치 버튼 (아래쪽)
            child: FloatingActionButton(
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
          ),
          Positioned(
            bottom: 20,
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
