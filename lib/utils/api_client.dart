import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'error_utils.dart';

typedef UnauthorizedCallback = void Function();

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  static ApiClient get instance => _instance;

  factory ApiClient({
    http.Client? client,
    String? baseUrl,
    UnauthorizedCallback? onUnauthorized,
  }) {
    if (client != null || baseUrl != null || onUnauthorized != null) {
      return ApiClient._custom(
        client: client,
        baseUrl: baseUrl,
        onUnauthorized: onUnauthorized,
      );
    }
    return _instance;
  }

  ApiClient._internal()
      : _client = http.Client(),
        baseUrl = AppConstants.defaultBaseUrl;

  ApiClient._custom({
    http.Client? client,
    String? baseUrl,
    this.onUnauthorized,
  })  : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConstants.defaultBaseUrl;

  static http.Client? _mockClient;

  static void setMockClient(http.Client? mockClient) {
    _mockClient = mockClient;
  }

  final http.Client _client;
  http.Client get client => _mockClient ?? _client;

  String baseUrl;
  String? _authToken;
  UnauthorizedCallback? onUnauthorized;

  String? get authToken => _authToken;

  Future<void> setAuthToken(String? token, {bool persist = true}) async {
    _authToken = token;
    if (persist) {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (token != null && token.isNotEmpty) {
          await prefs.setString(AppConstants.keyAuthToken, token);
        } else {
          await prefs.remove(AppConstants.keyAuthToken);
        }
      } catch (_) {}
    }
  }

  Future<void> loadSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(AppConstants.keyAuthToken);
    } catch (_) {}
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyAuthToken);
    } catch (_) {}
  }

  Map<String, String> _buildHeaders([Map<String, String>? customHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };

    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
      headers['Cookie'] = 'token=$_authToken';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  static String? extractTokenFromResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        if (decoded['token'] != null) return decoded['token'].toString();
        if (decoded['data'] is Map && decoded['data']['token'] != null) {
          return decoded['data']['token'].toString();
        }
      }
    } catch (_) {}

    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      final match = RegExp(r'token=([^;]+)').firstMatch(setCookie);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final baseUri = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');
    final resolvedUri = baseUri.resolve(cleanPath);

    if (queryParams != null && queryParams.isNotEmpty) {
      final normalizedQuery = <String, String>{};
      queryParams.forEach((key, value) {
        if (value != null) {
          normalizedQuery[key] = value.toString();
        }
      });
      return resolvedUri.replace(queryParameters: normalizedQuery);
    }

    return resolvedUri;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      onUnauthorized?.call();
    }

    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = ErrorUtils.getErrorMessage(response);
    throw ApiException(
      message,
      statusCode: response.statusCode,
      data: body,
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Duration timeout = AppConstants.requestTimeout,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final response = await client
          .get(uri, headers: _buildHeaders(headers))
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ErrorUtils.getErrorMessage(e));
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Duration timeout = AppConstants.requestTimeout,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await client
          .post(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ErrorUtils.getErrorMessage(e));
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Duration timeout = AppConstants.requestTimeout,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await client
          .put(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ErrorUtils.getErrorMessage(e));
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Duration timeout = AppConstants.requestTimeout,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await client
          .delete(uri, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(timeout);
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ErrorUtils.getErrorMessage(e));
    }
  }

  void close() {
    _client.close();
  }
}
