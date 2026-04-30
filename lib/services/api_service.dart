import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_urls.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = AppUrls.baseUrl});

  // GET request
  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _mergeHeaders(headers),
    );
    return _handleResponse(response);
  }

  // POST request
  Future<http.Response> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _mergeHeaders(headers),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  // PUT request
  Future<http.Response> put(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _mergeHeaders(headers),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  // DELETE request
  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _mergeHeaders(headers),
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

  // Default headers
  Map<String, String> _defaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Handle Response
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      // You can throw a custom exception here
      throw Exception('Failed to load data: ${response.statusCode} ${response.body}');
    }
  }
}
