import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../constants/api_constants.dart';
import '../../controllers/storage_controller.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  // Get auth token from storage
  Future<String?> _getToken() async {
    return StorageController.instance.getString(ApiConstants.tokenKey);
  }

  // Get common headers
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {
      'Content-Type': ApiConstants.contentTypeJson,
      'Accept': ApiConstants.acceptJson,
    };

    if (requiresAuth) {
      final token = await _getToken();
      print('🔑 Full Auth Token: $token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print('✅ Authorization header added');
      } else {
        print('❌ No token available - request will be unauthorized');
      }
    }

    return headers;
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return json.decode(response.body);
    } else {
      // Handle errors
      String errorMessage = 'An error occurred';

      try {
        final errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorBody['error'] ?? errorMessage;
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : 'Server error';
      }

      // Handle specific status codes
      if (statusCode == 401) {
        // Unauthorized - clear token and redirect to login
        StorageController.instance.remove(ApiConstants.tokenKey);
        StorageController.instance.remove(ApiConstants.userKey);
        StorageController.instance.setBool(ApiConstants.isLoggedInKey, false);
        Get.offAllNamed('/login'); // You'll need to set up named routes
        throw ApiException('Session expired. Please login again.');
      } else if (statusCode == 422) {
        // Validation error
        throw ApiException(errorMessage, validationErrors: _extractValidationErrors(response.body));
      } else if (statusCode == 404) {
        throw ApiException('Resource not found');
      } else if (statusCode == 500) {
        throw ApiException('Server error. Please try again later.');
      }

      throw ApiException(errorMessage, statusCode: statusCode);
    }
  }

  // Extract validation errors
  Map<String, dynamic>? _extractValidationErrors(String responseBody) {
    try {
      final body = json.decode(responseBody);
      return body['errors'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // GET request
  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final response = await _client.get(url, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Server error');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final response = await _client.post(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Server error');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final response = await _client.put(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Server error');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final response = await _client.delete(url, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Server error');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Multipart request (for file uploads)
  Future<dynamic> multipart(
    String endpoint,
    String method, {
    Map<String, String>? fields,
    Map<String, String>? files,
    bool requiresAuth = true,
  }) async {
    try {
      final token = requiresAuth ? await _getToken() : null;
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final request = http.MultipartRequest(method, url);

      // Add headers
      request.headers['Accept'] = ApiConstants.acceptJson;
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          if (entry.value.isNotEmpty) {
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, entry.value),
            );
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Server error');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }
}

// Custom exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? validationErrors;

  ApiException(this.message, {this.statusCode, this.validationErrors});

  @override
  String toString() => message;
}
