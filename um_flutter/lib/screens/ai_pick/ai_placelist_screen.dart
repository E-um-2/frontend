import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:um_test/screens/home/write_course_screen.dart';

class AiPlaceListScreen extends StatelessWidget {
  final List<String> places;

  const AiPlaceListScreen({super.key, required this.places});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추천 장소 선택'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          final parsed = parseTitleAndDescription(place);
          final title = parsed['title']!;
          final description = parsed['description']!;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.place, color: Color(0xFF40CDBC)),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                description,
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await geocodeAllPlacesAndNavigate(
                  context,
                  selectedPlace: title, // 제목만 검색에 활용
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> geocodeAllPlacesAndNavigate(BuildContext context, {required String selectedPlace}) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("API 키가 설정되지 않았습니다.")),
      );
      return;
    }

    final cleaned = cleanPlaceName(selectedPlace);
    List<String> queries = [
      "$cleaned, 인천",
      cleaned,
      selectedPlace.split(' ').first + " 인천",
    ];

    LatLng? coord;
    for (final query in queries) {
      coord = await tryGeocode(query, apiKey);
      if (coord != null) break;
    }

    if (!context.mounted) return;

    if (coord != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WriteCourseScreen(
            initialPosition: coord!,
            fromAi: true,
            aiPlaces: [coord!],
            aiPlaceNames: [selectedPlace],
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("위치 검색 실패"),
          content: Text("‘$selectedPlace’의 위치를 찾을 수 없습니다.\n지도로 직접 코스를 그리시겠어요?"),
          actions: [
            TextButton(
              child: const Text("직접 그리기"),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WriteCourseScreen(),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text("취소"),
              onPressed: () => Navigator.pop(dialogContext),
            )
          ],
        ),
      );
    }
  }

  Map<String, String> parseTitleAndDescription(String raw) {
    final lines = raw.trim().split('\n');
    if (lines.isEmpty) return {'title': raw, 'description': ''};

    final titleLine = lines.first.trim();
    final descriptionLines = lines.skip(1).join('\n').trim();

    return {
      'title': titleLine,
      'description': descriptionLines,
    };
  }


  String cleanPlaceName(String raw) {
    return raw
        .replaceAll(RegExp(r'^[0-9]+\.?\s*'), '') // 숫자 제거
        .replaceAll(RegExp(r'(자전거\s*)?(도로|코스|길|경로|여행지)?'), '')
        .replaceAll(RegExp(r'[^\w\s가-힣()]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<LatLng?> tryGeocode(String query, String apiKey) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(query)}&key=$apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          final location = results[0]['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
    } catch (e) {
      debugPrint('Geocode error for "$query": $e');
    }
    return null;
  }
}
