import 'dart:convert';
import 'dart:io';

import '../models/quest.dart';
import '../models/task_activity_day.dart';
import '../models/task_report.dart';

class TaskApi {
  const TaskApi({String? baseUrl, String? authToken})
    : _baseUrl = baseUrl,
      _authToken = authToken;

  final String? _baseUrl;
  final String? _authToken;

  String get baseUrl {
    const configured = String.fromEnvironment('TASK_API_BASE_URL');
    if (_baseUrl != null && _baseUrl.isNotEmpty) {
      return _baseUrl;
    }
    if (configured.isNotEmpty) {
      return configured;
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:4000/api/tasks';
    }

    return 'http://localhost:4000/api/tasks';
  }

  Future<List<Quest>> fetchToday() => fetchTasksForDate(DateTime.now());

  Future<List<Quest>> fetchTasksForDate(DateTime date) async {
    final response = await _request(
      'GET',
      Uri.parse('$baseUrl?date=${_isoDate(date)}'),
    );
    final body = jsonDecode(response) as Map<String, dynamic>;
    final tasks = body['tasks'] as List<dynamic>? ?? [];

    return tasks
        .map((task) => Quest.fromJson(task as Map<String, dynamic>))
        .toList();
  }

  Future<Quest> addTodayTask({
    required String title,
    required String reward,
    required String rank,
    String description = '',
    String category = 'General',
    String difficulty = 'Normal',
    int estimatedMinutes = 30,
    String targetMetric = '',
    String successCriteria = '',
    String notes = '',
    DateTime? dueDate,
  }) async {
    final response = await _request(
      'POST',
      Uri.parse(baseUrl),
      body: {
        'title': title,
        'description': description,
        'category': category,
        'difficulty': difficulty,
        'estimated_minutes': estimatedMinutes,
        'target_metric': targetMetric,
        'success_criteria': successCriteria,
        'notes': notes,
        'reward': reward,
        'rank': rank,
        'due_date': _isoDate(dueDate ?? DateTime.now()),
      },
    );
    final decoded = jsonDecode(response) as Map<String, dynamic>;

    return Quest.fromJson(decoded['task'] as Map<String, dynamic>);
  }

  Future<Quest> updateTaskCompletion(String id, bool isComplete) async {
    final response = await _request(
      'PATCH',
      Uri.parse('$baseUrl/$id/complete'),
      body: {'is_complete': isComplete},
    );
    final decoded = jsonDecode(response) as Map<String, dynamic>;

    return Quest.fromJson(decoded['task'] as Map<String, dynamic>);
  }

  Future<List<Quest>> fetchHistory({
    required DateTime start,
    required DateTime end,
  }) async {
    final response = await _request(
      'GET',
      Uri.parse(
        '$baseUrl/history?start=${_isoDate(start)}&end=${_isoDate(end)}',
      ),
    );
    final body = jsonDecode(response) as Map<String, dynamic>;
    final tasks = body['tasks'] as List<dynamic>? ?? [];

    return tasks
        .map((task) => Quest.fromJson(task as Map<String, dynamic>))
        .toList();
  }

  Future<TaskReport> fetchReport({
    required String period,
    required DateTime anchor,
  }) async {
    final response = await _request(
      'GET',
      Uri.parse('$baseUrl/reports?period=$period&anchor=${_isoDate(anchor)}'),
    );

    return TaskReport.fromJson(jsonDecode(response) as Map<String, dynamic>);
  }

  Future<List<TaskActivityDay>> fetchActivity({int days = 366}) async {
    final response = await _request(
      'GET',
      Uri.parse('$baseUrl/activity/summary?days=$days'),
    );
    final body = jsonDecode(response) as Map<String, dynamic>;
    final activity = body['activity'] as List<dynamic>? ?? [];

    return activity
        .map((day) => TaskActivityDay.fromJson(day as Map<String, dynamic>))
        .toList();
  }

  Future<String> _request(
    String method,
    Uri uri, {
    Map<String, Object?>? body,
  }) async {
    final client = HttpClient();

    try {
      final request = await client.openUrl(method, uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (_authToken != null && _authToken.isNotEmpty) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $_authToken',
        );
      }

      if (body != null) {
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        request.write(jsonEncode(body));
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw TaskApiException(_readError(responseBody, response.statusCode));
      }

      return responseBody;
    } on SocketException catch (error) {
      throw TaskApiException(
        'Could not reach the task server at $baseUrl. ${error.message}',
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

  String _isoDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}

class TaskApiException implements Exception {
  const TaskApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
