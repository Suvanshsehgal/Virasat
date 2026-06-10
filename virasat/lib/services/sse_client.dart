import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SseEvent {
  final String? id;
  final String? event;
  final String data;

  const SseEvent({this.id, this.event, required this.data});
}

class SseClient {
  final String url;
  final Map<String, String> headers;
  final String? body;
  http.Client? _client;
  bool _canceled = false;

  SseClient({
    required this.url,
    this.headers = const {},
    this.body,
  });

  Stream<SseEvent> stream() {
    _canceled = false;
    final controller = StreamController<SseEvent>();

    _startListening(controller);

    return controller.stream;
  }

  Future<void> _startListening(StreamController<SseEvent> controller) async {
    try {
      _client = http.Client();
      final request = http.Request('POST', Uri.parse(url));
      request.headers.addAll({
        ...headers,
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
      });
      if (body != null) {
        request.body = body!;
      }

      final response = await _client!.send(request);

      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      String? currentId;
      String? currentEvent;

      await for (final line in stream) {
        if (_canceled) break;

        if (line.startsWith('id:')) {
          currentId = line.substring(3).trim();
        } else if (line.startsWith('event:')) {
          currentEvent = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          final data = line.substring(5).trim();
          if (data == '[DONE]') {
            break;
          }
          controller.add(SseEvent(
            id: currentId,
            event: currentEvent,
            data: data,
          ));
        } else if (line.isEmpty) {
          currentId = null;
          currentEvent = null;
        }
      }
    } catch (e) {
      if (!_canceled) {
        controller.addError(e);
      }
    } finally {
      if (!_canceled) {
        await controller.close();
      }
      _client?.close();
    }
  }

  void cancel() {
    _canceled = true;
    _client?.close();
  }
}
