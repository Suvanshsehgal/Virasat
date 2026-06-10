import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;
  final String baseUrl;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConfig.baseUrl;

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final detail = body['detail'] ?? 'Unknown error';
    throw ApiException(
      response.statusCode,
      detail is String ? detail : jsonEncode(detail),
    );
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl${ApiConfig.health}'),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      final response = await _client.get(Uri.parse('$baseUrl/'));
      return _handleResponse(response);
    }
  }

  Future<Map<String, dynamic>> predictImage({
    required File imageFile,
    bool includeInfo = true,
    bool includeSimilar = true,
    String contextHint = '',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl${ApiConfig.predict}'),
    );
    request.fields['include_info'] = includeInfo.toString();
    request.fields['include_similar'] = includeSimilar.toString();
    if (contextHint.isNotEmpty) {
      request.fields['context_hint'] = contextHint;
    }
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> identifySpecific({
    required String broadCategory,
    String contextHint = '',
    List<String> top5Categories = const [],
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl${ApiConfig.identifySpecific}'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'broad_category': broadCategory,
        if (contextHint.isNotEmpty) 'context_hint': contextHint,
        'top5_categories': top5Categories,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> processYoutube({
    required String youtubeUrl,
    int fps = 1,
    int maxFrames = 90,
    double confidenceThreshold = 0.15,
    String videoTitle = '',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl${ApiConfig.processYoutube}'),
    );
    request.fields['youtube_url'] = youtubeUrl;
    request.fields['fps'] = fps.toString();
    request.fields['max_frames'] = maxFrames.toString();
    request.fields['confidence_threshold'] = confidenceThreshold.toString();
    if (videoTitle.isNotEmpty) {
      request.fields['video_title'] = videoTitle;
    }
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> listMonuments() async {
    final response = await _client.get(
      Uri.parse('$baseUrl${ApiConfig.monuments}'),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> monumentDetail(String monumentName) async {
    final response = await _client.get(
      Uri.parse('$baseUrl${ApiConfig.monumentDetail}/$monumentName'),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> nearbyMonuments({
    required String monumentName,
    String location = '',
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl${ApiConfig.nearbyMonuments}'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'monument_name': monumentName,
        if (location.isNotEmpty) 'location': location,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> compareMonuments({
    required String monument1,
    required String monument2,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl${ApiConfig.compareMonuments}'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'monument1': monument1,
        'monument2': monument2,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> searchMonument(String query) async {
    final response = await _client.post(
      Uri.parse('$baseUrl${ApiConfig.searchMonument}'),
      headers: _jsonHeaders,
      body: jsonEncode({'query': query}),
    );
    return _handleResponse(response);
  }

  String _chatBody(String message, String? monumentContext, List<Map<String, String>> history) {
    return jsonEncode({
      'message': message,
      if (monumentContext != null) 'monument_context': monumentContext,
      'history': history,
    });
  }

  String chatUrl() => '$baseUrl${ApiConfig.chat}';

  String chatRequestBody(String message, String? monumentContext, List<Map<String, String>> history) {
    return _chatBody(message, monumentContext, history);
  }

  Future<Map<String, dynamic>> heritageQuiz({
    required String monumentName,
    String difficulty = 'medium',
    int numQuestions = 5,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl${ApiConfig.heritageQuiz}'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'monument_name': monumentName,
        'difficulty': difficulty,
        'num_questions': numQuestions,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> monumentStory({
    required String monumentName,
    String style = 'narrative',
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl${ApiConfig.monumentStory}'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'monument_name': monumentName,
        'style': style,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> travelItinerary({
    required String monumentName,
    String location = '',
    int days = 3,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl${ApiConfig.travelItinerary}'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'monument_name': monumentName,
        if (location.isNotEmpty) 'location': location,
        'days': days,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> heritageTimeline(String monumentName) async {
    final response = await _client.post(
      Uri.parse('$baseUrl${ApiConfig.heritageTimeline}'),
      headers: _jsonHeaders,
      body: jsonEncode({'monument_name': monumentName}),
    );
    return _handleResponse(response);
  }

  void dispose() {
    _client.close();
  }
}
