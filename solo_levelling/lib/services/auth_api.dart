import 'dart:convert';
import 'dart:io';

import '../models/auth_session.dart';

class AuthApi {
  const AuthApi({String? baseUrl}) : _baseUrl = baseUrl;

  final String? _baseUrl;

  String get baseUrl {
    const configured = String.fromEnvironment('AUTH_API_BASE_URL');
    if (_baseUrl != null && _baseUrl.isNotEmpty) {
      return _baseUrl;
    }
    if (configured.isNotEmpty) {
      return configured;
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:4000/api/auth';
    }

    return 'http://localhost:4000/api/auth';
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _request(
      'POST',
      Uri.parse('$baseUrl/login'),
      body: {'email': email, 'password': password},
    );

    return AuthSession.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<AuthSession> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _request(
      'POST',
      Uri.parse('$baseUrl/signup'),
      body: {'name': name, 'email': email, 'password': password},
    );

    return AuthSession.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<String> _request(
    String method,
    Uri uri, {
    required Map<String, Object?> body,
  }) async {
    final client = HttpClient();

    try {
      final request = await client.openUrl(method, uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode(body));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthApiException(_readError(responseBody, response.statusCode));
      }

      return responseBody;
    } on SocketException catch (error) {
      throw AuthApiException(
        'Could not reach the auth server at $baseUrl. ${error.message}',
      );
    } finally {
      client.close(force: true);
    }
  }

  String _readError(String responseBody, int statusCode) {
    try {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      return decoded['error'] as String? ?? 'Request failed with $statusCode.';
    } on FormatException {
      return 'Request failed with $statusCode.';
    }
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
