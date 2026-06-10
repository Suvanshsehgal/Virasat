import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/heritage_place.dart';
import 'api_service.dart';

class NearbyHeritageResult {
  final List<HeritagePlace> places;
  final double? closestDistanceKm;
  final String? source;

  const NearbyHeritageResult({
    required this.places,
    this.closestDistanceKm,
    this.source,
  });
}

class HeritageApiService {
  final http.Client _client;
  final String baseUrl;

  HeritageApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConfig.baseUrl;

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
      };

  Future<NearbyHeritageResult> fetchNearbyHeritage({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl${ApiConfig.nearbyHeritage}'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'radius': (radius * 1000).toInt(),
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body is Map<String, dynamic>
          ? (body['places'] as List<dynamic>? ?? [])
          : (body as List<dynamic>);
      final places = data
          .map((e) => HeritagePlace.fromJson(e as Map<String, dynamic>))
          .toList();

      double? closestDistanceKm;
      if (body is Map<String, dynamic> && places.isEmpty) {
        final closest = body['closest_distance_km'];
        if (closest != null) {
          closestDistanceKm = (closest as num).toDouble();
        }
      }

      final source = body is Map<String, dynamic>
          ? body['source'] as String?
          : null;

      return NearbyHeritageResult(
        places: places,
        closestDistanceKm: closestDistanceKm,
        source: source,
      );
    }

    final detail = _extractDetail(response.body);
    throw ApiException(response.statusCode, detail);
  }

  String _extractDetail(String body) {
    try {
      final json = jsonDecode(body);
      return json['detail'] as String? ?? 'Unknown error';
    } catch (_) {
      return 'Unknown error';
    }
  }

  void dispose() {
    _client.close();
  }
}
