import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:bonded_app/services/shared_prefs_service.dart';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:bonded_app/core/routes/app_routes.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = AppUrls.baseUrl});
  
  static bool isNavigatingToLogin = false;

  // GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _performRequest(
      () => http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _mergeHeaders(headers),
      ),
      endpoint,
      'GET',
      null,
      headers,
    );
  }

  // POST request
  Future<http.Response> post(
    String endpoint,
    Map<dynamic, dynamic> map, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final payload = body ?? map;
    final encodedBody = payload != null ? jsonEncode(payload) : null;
    return _performRequest(
      () => http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _mergeHeaders(headers),
        body: encodedBody,
      ),
      endpoint,
      'POST',
      encodedBody,
      headers,
    );
  }

  // PUT request
  Future<http.Response> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _performRequest(
      () => http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _mergeHeaders(headers),
        body: encodedBody,
      ),
      endpoint,
      'PUT',
      encodedBody,
      headers,
    );
  }

  // PATCH request
  Future<http.Response> patch(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _performRequest(
      () => http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: _mergeHeaders(headers),
        body: encodedBody,
      ),
      endpoint,
      'PATCH',
      encodedBody,
      headers,
    );
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _performRequest(
      () => http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _mergeHeaders(headers),
      ),
      endpoint,
      'DELETE',
      null,
      headers,
    );
  }

  // Internal helper to perform request and handle retries
  Future<http.Response> _performRequest(
    Future<http.Response> Function() requestFn,
    String endpoint,
    String method,
    String? body,
    Map<String, String>? originalHeaders,
  ) async {
    final url = '$baseUrl$endpoint';
    _logRequest(method, url, _mergeHeaders(originalHeaders), body);

    var response = await requestFn();
    _logResponse(response);

    if (response.statusCode == 401 &&
        endpoint != AppUrls.refreshAccessToken &&
        endpoint != AppUrls.changePassword &&
        endpoint != AppUrls.login) {
      final success = await _refreshAccessToken();
      if (success) {
        // Retry with new headers
        _logRequest(
          '$method (Retry)',
          url,
          _mergeHeaders(originalHeaders),
          body,
        );
        response = await requestFn();
        _logResponse(response);
        
        // If still 401 after retry, something is wrong, force login
        if (response.statusCode == 401) {
          _navigateToLogin();
        }
      } else {
        // Refresh failed, navigate to login
        _navigateToLogin();
      }
    }

    return _handleResponse(response);
  }

  // Helper to clear tokens and navigate to login
  void _navigateToLogin() {
    if (isNavigatingToLogin || Get.currentRoute == AppRoutes.LOGIN) return;
    
    isNavigatingToLogin = true;
    SharedPrefsService.delete('accessToken');
    SharedPrefsService.delete('refreshToken');
    
    Get.offAllNamed(AppRoutes.LOGIN);
    
    // Reset flag after a delay to allow for fresh logins
    Future.delayed(const Duration(seconds: 2), () {
      isNavigatingToLogin = false;
    });
  }

  // Refresh Access Token logic
  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = SharedPrefsService.getString('refreshToken');
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl${AppUrls.refreshAccessToken}'),
        headers: _defaultHeaders(),
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final newAccessToken = data['data']['accessToken'];
          await SharedPrefsService.saveString('accessToken', newAccessToken);
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
    }
    return false;
  }

  // Merge default headers with provided headers
  Map<String, String> _mergeHeaders(Map<String, String>? extraHeaders) {
    final headers = _defaultHeaders();
    final token = SharedPrefsService.getString('accessToken');
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  // Default headers
  Map<String, String> _defaultHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  // Handle Response
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      String message = 'Failed to load data: ${response.statusCode}';
      try {
        final data = jsonDecode(response.body);
        if (data != null) {
          if (data['message'] != null) {
            message = data['message'];
          } else if (data['errorSources'] != null &&
              data['errorSources'] is List &&
              data['errorSources'].isNotEmpty) {
            message = data['errorSources'][0]['message'] ?? message;
          }
        }
      } catch (_) {}
      throw ApiException(message, statusCode: response.statusCode);
    }
  }

  void _logRequest(
    String method,
    String url,
    Map<String, String> headers,
    String? body,
  ) {
    debugPrint('--> $method $url');
    debugPrint('Headers: $headers');
    if (body != null) {
      try {
        final decoded = jsonDecode(body);
        final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
        debugPrint('Body: $pretty');
      } catch (_) {
        debugPrint('Body: $body');
      }
    }
    debugPrint('--> END $method');
  }

  void _logResponse(http.Response response) {
    debugPrint('<-- ${response.statusCode} ${response.request?.url}');
    try {
      final decoded = jsonDecode(response.body);
      final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
      debugPrint('Response: $pretty');
    } catch (_) {
      debugPrint('Response: ${response.body}');
    }
    debugPrint('<-- END HTTP');
  }

  // Multipart request (e.g., for file uploads)
  Future<http.Response> multipartRequest(
    String method,
    String endpoint, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    Map<String, String>? headers,
  }) async {
    final url = '$baseUrl$endpoint';
    final mergedHeaders = _mergeHeaders(headers);
    mergedHeaders.remove('Content-Type');

    _logRequest('$method (Multipart)', url, mergedHeaders, fields.toString());

    final request = http.MultipartRequest(method, Uri.parse(url));
    request.headers.addAll(mergedHeaders);

    if (fields != null) request.fields.addAll(fields);
    if (files != null) request.files.addAll(files);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 401 && endpoint != AppUrls.login) {
      _navigateToLogin();
    }

    return _handleResponse(response);
  }
}
