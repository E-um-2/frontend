import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:um_test/screens/home/write_course_screen.dart';


class AiPlaceListScreen extends StatelessWidget {
  final List<String> places;

  const AiPlaceListScreen({super.key, required this.places});

  Future<LatLng?> geocodePlace(String placeName) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null) return null;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(placeName)},인천&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;
        if (results.isNotEmpty) {
          final location = results[0]['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        }
      }
    } catch (e) {
      debugPrint('Geocode error: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('추천 장소 선택')),
      body: ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return ListTile(
            title: Text(place),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final coord = await geocodePlace(place);
              if (coord != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WriteCourseScreen(initialPosition: coord),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('해당 장소의 위치를 찾을 수 없습니다.')),
                );
              }
            },
          );
        },
      ),
    );
  }
}
