import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _controller;
  Location _location = Location();
  bool _tracking = false;
  List<LatLng> _route = [];
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
  }

  void _startTracking() {
    _route.clear();
    _polylines.clear();
    setState(() {
      _tracking = true;
    });

    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (_tracking) {
        setState(() {
          LatLng position = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
          _route.add(position);
          _polylines.add(
            Polyline(
              polylineId: PolylineId("route"),
              points: _route,
              color: Colors.blue,
              width: 5,
            ),
          );
          _controller?.animateCamera(CameraUpdate.newLatLng(position));
        });
      }
    });
  }

  void _stopTracking() {
    setState(() {
      _tracking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("맵 루트 표시 테스트"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(35.1691, 129.0874),
                zoom: 17,
              ),
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              polylines: _polylines,
            ),
          ),
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: _tracking ? _stopTracking : _startTracking,
                child: Text(_tracking ? '중지' : '시작'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
