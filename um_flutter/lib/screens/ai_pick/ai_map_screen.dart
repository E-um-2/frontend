import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AiMapScreen extends StatefulWidget {
  final List<String> places;
  const AiMapScreen({super.key, required this.places});

  @override
  State<AiMapScreen> createState() => _AiMapScreenState();
}

class _AiMapScreenState extends State<AiMapScreen> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoordinates();
  }

  // 권역별 fallback 좌표 리턴 함수
  LatLng getFallbackCoordinate(String placeName) {
    final lower = placeName.toLowerCase();

    if (lower.contains('송도')) {
      return LatLng(37.3881, 126.6325); // 송도 권역 중심 좌표 예시
    } else if (lower.contains('월미')) {
      return LatLng(37.4741, 126.6167); // 월미 권역 중심 좌표 예시
    } else if (lower.contains('계양')) {
      return LatLng(37.5483, 126.7344); // 계양 권역 중심 좌표 예시
    } else if (lower.contains('소래')) {
      return LatLng(37.3947, 126.7380); // 소래 권역 중심 좌표 예시
    }
    // 기본 인천시청 좌표
    return LatLng(37.4563, 126.7052);
  }

  Future<void> _loadCoordinates() async {
    List<LatLng> latLngList = [];

    for (final place in widget.places) {
      final coord = await _geocodePlace(place);
      if (coord != null) {
        latLngList.add(coord);
        _markers.add(Marker(
          markerId: MarkerId(place),
          position: coord,
          infoWindow: InfoWindow(title: place),
        ));
      }
    }

    if (_markers.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (latLngList.length >= 2) {
      _polylines.add(Polyline(
        polylineId: const PolylineId("course_path"),
        color: Colors.blue,
        width: 5,
        points: latLngList,
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

  String cleanPlaceName(String raw) {
    return raw
        .replaceAll(RegExp(r'(자전거\s*)?(코스|경로|길|도로)?'), '') // 자전거 관련 단어 모두 제거
        .replaceAll(RegExp(r'[^\w\s가-힣a-zA-Z0-9]'), '') // 특수문자 제거
        .replaceAll(RegExp(r'\s+'), ' ') // 중복 공백 제거
        .trim();
  }


  Future<LatLng?> _geocodePlace(String placeName) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null) {
      print('🚨 GOOGLE_MAPS_API_KEY is null!');
      return null; // 또는 적절한 fallback 처리
    }
    final cleaned = cleanPlaceName(placeName);

    // 1차 시도: 인천 포함
    String fullQuery = "$cleaned, 인천";

    LatLng? result = await _tryGeocode(fullQuery, apiKey);
    if (result != null) return result;

    // 2차 시도: 인천 제외
    fullQuery = cleaned;
    result = await _tryGeocode(fullQuery, apiKey);
    if (result != null) return result;

    // 3차 fallback
    return getFallbackCoordinate(placeName);
  }

  Future<LatLng?> _tryGeocode(String query, String apiKey) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$apiKey',
    );
    print('📦 요청: $query');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      if (results.isNotEmpty) {
        final location = results[0]['geometry']['location'];
        print("✅ 성공: $query → (${location['lat']}, ${location['lng']})");
        return LatLng(location['lat'], location['lng']);
      } else {
        print("❌ 실패: $query → 결과 없음");
        return null;
      }
    } else {
      print("🚨 API 오류 ($query): ${response.body}");
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("추천 지도")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _markers.isEmpty
              ? const Center(child: Text("📭 위치 정보를 불러올 수 없습니다."))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _markers.first.position,
                    zoom: 13,
                  ),
                  onMapCreated: (controller) => mapController = controller,
                  markers: _markers,
                  polylines: _polylines,
                ),
    );
  }
}
