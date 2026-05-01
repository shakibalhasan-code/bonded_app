import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = AppUrls.baseUrl});

  // GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = '$baseUrl$endpoint';
    final mergedHeaders = _mergeHeaders(headers);
    _logRequest('GET', url, mergedHeaders, null);
    
    final response = await http.get(
      Uri.parse(url),
      headers: mergedHeaders,
    );
    return _handleResponse(response);
  }

  // POST request
  Future<http.Response> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final url = '$baseUrl$endpoint';
    final mergedHeaders = _mergeHeaders(headers);
    final encodedBody = body != null ? jsonEncode(body) : null;
    _logRequest('POST', url, mergedHeaders, encodedBody);

    final response = await http.post(
      Uri.parse(url),
      headers: mergedHeaders,
      body: encodedBody,
    );
    return _handleResponse(response);
  }

  // PUT request
  Future<http.Response> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final url = '$baseUrl$endpoint';
    final mergedHeaders = _mergeHeaders(headers);
    final encodedBody = body != null ? jsonEncode(body) : null;
    _logRequest('PUT', url, mergedHeaders, encodedBody);

    final response = await http.put(
      Uri.parse(url),
      headers: mergedHeaders,
      body: encodedBody,
    );
    return _handleResponse(response);
  }

  // PATCH request
  Future<http.Response> patch(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final url = '$baseUrl$endpoint';
    final mergedHeaders = _mergeHeaders(headers);
    final encodedBody = body != null ? jsonEncode(body) : null;
    _logRequest('PATCH', url, mergedHeaders, encodedBody);

    final response = await http.patch(
      Uri.parse(url),
      headers: mergedHeaders,
      body: encodedBody,
    );
    return _handleResponse(response);
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = '$baseUrl$endpoint';
    final mergedHeaders = _mergeHeaders(headers);
    _logRequest('DELETE', url, mergedHeaders, null);

    final response = await http.delete(
      Uri.parse(url),
      headers: mergedHeaders,
    );
    return _handleResponse(response);
  }

  // Merge default headers with provided headers
  Map<String, String> _mergeHeaders(Map<String, String>? extraHeaders) {
    final headers = _defaultHeaders();
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
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
    mergedHeaders.remove('Content-Type'); // Let http package set the boundary
    
    _logRequest('$method (Multipart)', url, mergedHeaders, fields.toString());

    final request = http.MultipartRequest(method, Uri.parse(url));
    request.headers.addAll(mergedHeaders);
    
    if (fields != null) {
      request.fields.addAll(fields);
    }
    
    if (files != null) {
      request.files.addAll(files);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    return _handleResponse(response);
  }

  // Default headers
  Map<String, String> _defaultHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  // Handle Response
  http.Response _handleResponse(http.Response response) {
    _logResponse(response);
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
      } catch (_) {
        if (response.body.isNotEmpty) {
          message = response.body;
        }
      }
      throw ApiException(message);
    }
  }

  void _logRequest(String method, String url, Map<String, String> headers, String? body) {
    debugPrint('--> $method $url');
    debugPrint('Headers: $headers');
    if (body != null) {
      debugPrint('Body: $body');
    }
    debugPrint('--> END $method');
  }

  void _logResponse(http.Response response) {
    debugPrint('<-- ${response.statusCode} ${response.request?.url}');
    debugPrint('Response: ${response.body}');
    debugPrint('<-- END HTTP');
  }
}
