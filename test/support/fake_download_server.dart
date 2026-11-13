import 'dart:async';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// An in-process HTTP server for download tests, exposed as [client].
///
/// Serves [bodies] by URL path, honours `Range: bytes=N-` with a 206 (unless
/// [ignoreRange]), and counts simultaneous open responses. With [hold] set,
/// response bodies are not sent until the test writes to [held].
class FakeDownloadServer {
  FakeDownloadServer(this.bodies);

  /// URL path → full body.
  final Map<String, List<int>> bodies;

  /// URL path → status to answer instead of the body (e.g. 404).
  final Map<String, int> statusFor = {};

  /// Answer 200 with the full body even when a Range was requested.
  bool ignoreRange = false;

  /// Keep response bodies open; the test drives them through [held].
  bool hold = false;

  /// Throw this from the client instead of answering (e.g. offline).
  Object? connectError;

  /// URL paths whose requests never get an answer (no headers, ever).
  final Set<String> neverAnswer = {};

  /// Send a Content-Length header (and set `contentLength`).
  bool sendLength = true;

  /// Leave out the Content-Range header of 206 answers.
  bool omitContentRange = false;

  final List<http.BaseRequest> requests = [];
  final Map<String, StreamController<List<int>>> held = {};
  int inFlight = 0;
  int maxInFlight = 0;

  late final http.Client client = MockClient.streaming(_handle);

  Future<http.StreamedResponse> _handle(
    http.BaseRequest req,
    http.ByteStream _,
  ) async {
    requests.add(req);
    final error = connectError;
    if (error != null) throw error;
    final path = req.url.path;
    if (neverAnswer.contains(path)) {
      return Completer<http.StreamedResponse>().future;
    }

    final status = statusFor[path];
    if (status != null) {
      return http.StreamedResponse(
        const Stream.empty(),
        status,
        reasonPhrase: status == 404 ? 'Not Found' : 'Error',
      );
    }
    final full = bodies[path] ?? (throw StateError('No body for $path'));

    final range = RegExp(
      r'^bytes=(\d+)-$',
    ).firstMatch(req.headers['Range'] ?? req.headers['range'] ?? '');
    var start = 0;
    var code = 200;
    final headers = <String, String>{};
    if (range != null && !ignoreRange) {
      start = int.parse(range.group(1)!);
      code = 206;
      if (!omitContentRange) {
        headers['content-range'] =
            'bytes $start-${full.length - 1}/${full.length}';
      }
    }
    final slice = full.sublist(start);
    if (sendLength) headers['content-length'] = '${slice.length}';

    inFlight++;
    maxInFlight = math.max(maxInFlight, inFlight);
    var finished = false;
    void finish() {
      if (finished) return;
      finished = true;
      inFlight--;
    }

    final body = StreamController<List<int>>(onCancel: finish);
    body.done.then((_) => finish());
    if (hold) {
      held[path] = body;
    } else {
      for (var i = 0; i < slice.length; i += 3) {
        body.add(slice.sublist(i, math.min(i + 3, slice.length)));
      }
      unawaited(body.close());
    }
    return http.StreamedResponse(
      body.stream,
      code,
      contentLength: sendLength ? slice.length : null,
      headers: headers,
    );
  }

  /// The `Range` header of the last request to [path], or null.
  String? rangeOf(String path) {
    final r = requests.lastWhere((r) => r.url.path == path);
    return r.headers['Range'] ?? r.headers['range'];
  }
}
