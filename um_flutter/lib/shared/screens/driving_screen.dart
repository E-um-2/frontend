import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DrivingScreen extends StatefulWidget {
  const DrivingScreen({super.key});

  @override
  State<DrivingScreen> createState() => _DrivingScreenState();
}

class _DrivingScreenState extends State<DrivingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _mapController;
  final GlobalKey _mapRepaintKey = GlobalKey();

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
  bool _isCameraLocked = true;
  bool _isCapturingImage = false;

  bool _showBikeStations = true;
  bool _showLandmarks = false;

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
          color: Colors.green,
          width: 6,
        ),
      );
    }
    if (_routePolyline.isNotEmpty) {
      lines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _routePolyline,
          color: Colors.blue,
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
    try {
      final current = await _location.getLocation();
      setState(() {
        _currentPosition = LatLng(current.latitude!, current.longitude!);
      });
    } catch (e) {
      Future.delayed(const Duration(seconds: 1), _initLocation);
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


  void _toggleBikeMarkers() {
    _showBikeStations = !_showBikeStations;
    _updateVisibleMarkers();
  }


  void _toggleLandmarkMarkers() {
    _showLandmarks = !_showLandmarks;
    _updateVisibleMarkers();
  }

  Future<void> _goToCurrentLocation() async {
    final loc = await _location.getLocation();
    if (loc.latitude != null && loc.longitude != null) {
      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLng(LatLng(loc.latitude!, loc.longitude!)));
    }
  }

  void _startRide() {
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

      // 여기가 핵심: 주행 중에는 자동으로 카메라가 위치를 따라감
      if (_isCameraLocked) {
        double bearing = 0;

        if (_userPath.length >= 2) {
          final prev = _userPath[_userPath.length - 2];
          final curr = _userPath.last;

          bearing = _calculateBearing(
            prev.latitude, prev.longitude,
            curr.latitude, curr.longitude,
          );
        }

        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: point,
              zoom: 16,
              bearing: bearing,
              tilt: 45,
            ),
          ),
        );
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

  Future<void> _showSaveDialog() async {
    setState(() => _isCapturingImage = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final imageBytes = await _captureRouteImageBytes();
    setState(() => _isCapturingImage = false);
    if (imageBytes == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('경로 이미지 저장 또는 공유'),
        content: Image.memory(imageBytes),
        actions: [
          TextButton(
            onPressed: () async {
              await _saveImageToGallery(imageBytes);
              Navigator.of(context).pop();
            },
            child: const Text('갤러리에 저장'),
          ),
          TextButton(
            onPressed: () async {
              final path = await _saveTempImage(imageBytes);
              await Share.shareXFiles([XFile(path)], text: '내 자전거 주행 경로');
              Navigator.of(context).pop();
            },
            child: const Text('공유하기'),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _captureRouteImageBytes() async {
    try {
      RenderRepaintBoundary boundary = _mapRepaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final originalBytes = byteData!.buffer.asUint8List();

      final codec = await ui.instantiateImageCodec(originalBytes);
      final frame = await codec.getNextFrame();
      final ui.Image originalImage = frame.image;

      // 상단 정보 바 높이
      const double barHeight = 160;

      // 로고 불러오기
      final ui.Image logo = await _loadImageFromAsset('assets/images/eum_logo.png');

      // 로고 비율 계산
      const double logoTargetHeight = 80;
      final double aspectRatio = logo.width / logo.height;
      final double logoTargetWidth = logoTargetHeight * aspectRatio;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint();
      final Size size = Size(originalImage.width.toDouble(), originalImage.height.toDouble());

      // 흰색 바 그리기
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, barHeight),
        Paint()..color = Colors.white.withOpacity(0.95),
      );

      // 텍스트 준비
      final date = DateTime.now();
      final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final duration = _formattedTime();
      final distance = _formattedDistance();
      final text = "$formattedDate   /  $duration   /  $distance km";

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 44,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.width - logoTargetWidth - 60);
      textPainter.paint(canvas, Offset(20, (barHeight - textPainter.height) / 2));

      // 로고 그리기 (오른쪽 정렬)
      canvas.drawImageRect(
        logo,
        Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
        Rect.fromLTWH(
          size.width - logoTargetWidth - 20,
          (barHeight - logoTargetHeight) / 2,
          logoTargetWidth,
          logoTargetHeight,
        ),
        paint,
      );

      // 지도 이미지 그리기
      canvas.drawImage(originalImage, Offset(0, barHeight), paint);

      final picture = recorder.endRecording();
      final ui.Image finalImage = await picture.toImage(originalImage.width, originalImage.height + barHeight.toInt());
      final finalByteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);

      return finalByteData?.buffer.asUint8List();
    } catch (e) {
      print("Decorated image capture failed: $e");
      return null;
    }
  }




  Future<ui.Image> _loadImageFromAsset(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }


  Future<void> _saveImageToGallery(Uint8List bytes) async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('권한이 필요합니다. 설정에서 권한을 허용해 주세요.')),
      );
      return;
    }

    final result = await ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: "route_${DateTime.now().millisecondsSinceEpoch}",
    );

    if (result['isSuccess'] == true || result['filePath'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('갤러리에 저장되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장에 실패했습니다.')),
      );
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+ (미디어 접근 권한)
        return await Permission.photos.request().isGranted;
      } else {
        // Android 12 이하 (저장소 접근 권한)
        return await Permission.storage.request().isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }
    return false;
  }


  Future<String> _saveTempImage(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/route_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file.path;
  }

  String _formattedDistance() {
    double total = 0.0;
    for (int i = 0; i < _userPath.length - 1; i++) {
      total += _calculateDistance(
          _userPath[i].latitude, _userPath[i].longitude,
          _userPath[i + 1].latitude, _userPath[i + 1].longitude
      );
    }
    return (total / 1000).toStringAsFixed(2); // km 단위
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Earth radius in meters
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat/2) * sin(dLat/2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon/2) * sin(dLon/2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final radLat1 = _degToRad(lat1);
    final radLat2 = _degToRad(lat2);
    final deltaLon = _degToRad(lon2 - lon1);

    final y = sin(deltaLon) * cos(radLat2);
    final x = cos(radLat1) * sin(radLat2) -
        sin(radLat1) * cos(radLat2) * cos(deltaLon);

    final theta = atan2(y, x);
    return (_radToDeg(theta) + 360) % 360;
  }


  double _radToDeg(double rad) => rad * (180 / pi);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : RepaintBoundary(
        key: _mapRepaintKey,
        child: Stack(
          children: [
            GoogleMap(
              zoomControlsEnabled: true, // 맵 + - 줌 비활성화
              mapToolbarEnabled: false, // 마커 눌렀을때 네비게이션 길찾기 등 하단에 뜨는것 비활성화
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 16,
              ),
              onMapCreated: (controller) {
                _controller.complete(controller);
                _mapController = controller;
              },
              onCameraMoveStarted: () {
                if (!_isRiding) {
                  _isCameraLocked = false;
                }
              },
              myLocationEnabled: !_isCapturingImage,
              myLocationButtonEnabled: false,
              markers: _isCapturingImage ? {} : _visibleMarkers,
              polylines: _polylines,
            ),
            if (!_isCapturingImage) ...[
              Positioned(
                bottom: 110,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
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
                      if (!_isRiding && _userPath.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _showSaveDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(48, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Icon(Icons.download, color: Colors.blue),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 250,
                child: Column(
                  children: [
                    // 카메라 잠금 버튼
                    FloatingActionButton(
                      heroTag: 'toggleCameraLock',
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          _isCameraLocked = !_isCameraLocked;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isCameraLocked ? '카메라 따라가기: ON' : '카메라 따라가기: OFF',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      shape: const CircleBorder(),
                      child: Icon(
                        _isCameraLocked ? Icons.lock : Icons.lock_open,
                        color: _isCameraLocked ? Colors.blue : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 자전거 거치소
                    FloatingActionButton(
                      heroTag: 'toggleBike',
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: _toggleBikeMarkers,
                      shape: const CircleBorder(),
                      child: Icon(Icons.pedal_bike, color: _showBikeStations ? Colors.blue : Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    // 랜드마크
                    FloatingActionButton(
                      heroTag: 'toggleLandmark',
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: _toggleLandmarkMarkers,
                      shape: const CircleBorder(),
                      child: Icon(Icons.account_balance, color: _showLandmarks ? Colors.green : Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    // 현재 위치 이동
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
            ]
          ],
        ),
      ),
    );
  }
}
