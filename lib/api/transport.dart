// SPDX-License-Identifier: MIT
// How the generated client reaches spezado: HTTP with the token of this device, answers in JSON or bytes, and the
// Server-Sent Events that say when books changed.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// An answer that went wrong: its status and what spezado said.
class ApiException implements Exception {
  const ApiException(this.status, this.message);

  /// The HTTP status; 0 when spezado could not be reached.
  final int status;
  final String message;

  bool get unauthorised => status == 401;

  @override
  String toString() => message;
}

class Transport {
  Transport(this.base, {this.token, http.Client? client}) : _client = client ?? http.Client();

  /// Where spezado runs: `http://127.0.0.1:8048`.
  final Uri base;

  /// The token of this device, once paired.
  String? token;

  final http.Client _client;

  Uri _uri(String path, Map<String, Object?>? query) {
    final given = {
      for (final MapEntry(:key, :value) in (query ?? const <String, Object?>{}).entries)
        if (value != null) key: '$value',
    };
    return base.replace(path: path, queryParameters: given.isEmpty ? null : given);
  }

  Future<http.Response> _send(
    String method,
    String path,
    Map<String, Object?>? query,
    Object? json,
    Uint8List? bytes,
  ) async {
    final request = http.Request(method, _uri(path, query));
    if (token case final token?) request.headers['Authorization'] = 'Bearer $token';
    if (json != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(json);
    } else if (bytes != null) {
      request.headers['Content-Type'] = 'application/octet-stream';
      request.bodyBytes = bytes;
    }
    final http.Response response;
    try {
      response = await http.Response.fromStream(await _client.send(request));
    } on Exception catch (error) {
      throw ApiException(0, '$error');
    }
    if (response.statusCode >= 400) throw ApiException(response.statusCode, _problem(response));
    return response;
  }

  /// What went wrong: the answer's `error`, else its status.
  static String _problem(http.Response response) {
    try {
      if (jsonDecode(utf8.decode(response.bodyBytes)) case {'error': final String error}) return error;
    } on FormatException {
      // Not JSON: the status says it.
    }
    return '${response.statusCode} ${response.reasonPhrase ?? ''}'.trim();
  }

  /// Calls an operation that answers in JSON; returns it decoded.
  Future<Object?> json(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? json,
    Uint8List? bytes,
  }) async {
    final response = await _send(method, path, query, json, bytes);
    return response.bodyBytes.isEmpty ? null : jsonDecode(utf8.decode(response.bodyBytes));
  }

  /// Calls an operation that answers with a file; returns its bytes.
  Future<Uint8List> bytes(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? json,
    Uint8List? bytes,
  }) async => (await _send(method, path, query, json, bytes)).bodyBytes;

  /// Calls an operation that answers with nothing.
  Future<void> none(String method, String path, {Map<String, Object?>? query, Object? json, Uint8List? bytes}) =>
      _send(method, path, query, json, bytes);

  /// The books whenever something was written to them, from `/api/v1/events`; reconnects until cancelled.
  Stream<String> changes() {
    late final StreamController<String> controller;
    var running = true;
    Future<void> follow() async {
      while (running) {
        try {
          final request = http.Request('GET', _uri('/api/v1/events', null));
          request.headers['Accept'] = 'text/event-stream';
          if (token case final token?) request.headers['Authorization'] = 'Bearer $token';
          final response = await _client.send(request);
          if (response.statusCode != 200) throw ApiException(response.statusCode, 'events');
          String? event;
          await for (final line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
            if (!running) break;
            if (line.startsWith('event:')) {
              event = line.substring(6).trim();
            } else if (line.startsWith('data:') && event == 'changed') {
              if (jsonDecode(line.substring(5).trim()) case {'books': final String books}) controller.add(books);
            } else if (line.isEmpty) {
              event = null;
            }
          }
        } on Object {
          // spezado went away or restarted: try again shortly.
        }
        if (running) await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    controller = StreamController<String>(onListen: follow, onCancel: () => running = false);
    return controller.stream;
  }

  void close() => _client.close();
}
