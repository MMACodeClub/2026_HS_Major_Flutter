import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/app_exception.dart';

/// Owns its injected HTTP client. Tests pass a MockClient here.
class ChatApiClient {
  ChatApiClient({
    required http.Client client,
    required this.baseUrl,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client;

  final http.Client _client;
  final Uri baseUrl;
  final Duration timeout;

  Uri _uri(List<String> path) => baseUrl.replace(
    pathSegments: [
      ...baseUrl.pathSegments.where((segment) => segment.isNotEmpty),
      ...path,
    ],
  );

  Future<List<Map<String, dynamic>>> getList(List<String> path) async {
    final response = await _request('GET', path, success: {200});
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! List) throw const FormatException();
      return data.map((item) {
        if (item is! Map<String, dynamic>) throw const FormatException();
        return item;
      }).toList();
    } on FormatException {
      throw const AppException(
        'Die Antwort des Servers hat ein unerwartetes Format.',
      );
    }
  }

  Future<void> write(
    String method,
    List<String> path, {
    Map<String, String>? body,
  }) async {
    await _request(
      method,
      path,
      body: body,
      success: method == 'POST' ? {200, 201} : {200, 204},
    );
  }

  Future<http.Response> _request(
    String method,
    List<String> path, {
    Map<String, String>? body,
    required Set<int> success,
  }) async {
    final request = http.Request(method, _uri(path))
      ..headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }
    try {
      // The deadline covers both receiving headers and consuming the body.
      final response = await (() async {
        final stream = await _client.send(request);
        return http.Response.fromStream(stream);
      })().timeout(timeout);
      if (!success.contains(response.statusCode)) {
        throw AppException(switch (response.statusCode) {
          401 || 403 => 'Der Server erlaubt diese Aktion nicht.',
          404 => 'Dieser Raum oder diese Nachricht existiert nicht mehr.',
          429 => 'Zu viele Anfragen. Bitte kurz warten und erneut versuchen.',
          _ => 'Die Anfrage ist fehlgeschlagen (HTTP ${response.statusCode}).',
        });
      }
      return response;
    } on TimeoutException {
      throw const AppException(
        'Der Server antwortet nicht rechtzeitig. Bitte aktualisieren.',
      );
    } on http.ClientException {
      throw const AppException(
        'Keine Verbindung. Netzwerk und Serveradresse prüfen.',
      );
    }
  }

  void dispose() => _client.close();
}
