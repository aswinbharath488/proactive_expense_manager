import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;
  String? bearerToken;

  Uri _uri(String path) {
    final base = ApiConstants.baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }

  Map<String, String> _headers({bool jsonBody = true}) {
    final h = <String, String>{
      if (jsonBody) 'Content-Type': 'application/json',
      if (bearerToken != null && bearerToken!.isNotEmpty)
        'Authorization': 'Bearer $bearerToken',
    };
    return h;
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _http.post(
      _uri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final res = await _http.get(_uri(path), headers: _headers(jsonBody: false));
    return _decode(res);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final request = http.Request('DELETE', _uri(path))
      ..headers.addAll(_headers())
      ..body = jsonEncode(body);
    final streamed = await _http.send(request);
    final text = await streamed.stream.bytesToString();
    final map = jsonDecode(text.isEmpty ? '{}' : text);
    if (map is! Map<String, dynamic>) {
      throw ApiException('Unexpected response', streamed.statusCode);
    }
    if (streamed.statusCode >= 400) {
      throw ApiException(map['detail']?.toString() ?? 'Request failed',
          streamed.statusCode);
    }
    return map;
  }

  Map<String, dynamic> _decode(http.Response res) {
    final map = jsonDecode(res.body.isEmpty ? '{}' : res.body);
    if (map is! Map<String, dynamic>) {
      throw ApiException('Unexpected response', res.statusCode);
    }
    if (res.statusCode >= 400) {
      throw ApiException(
        map['detail']?.toString() ?? map['message']?.toString() ?? 'Request failed',
        res.statusCode,
      );
    }
    return map;
  }

  void dispose() => _http.close();
}

class ApiException implements Exception {
  ApiException(this.message, this.statusCode);
  final String message;
  final int statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
