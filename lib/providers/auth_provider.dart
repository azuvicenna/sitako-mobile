import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/api_client.dart';
import '../utils/constants.dart';
import '../utils/error_utils.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  User? _user;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance {
    _apiClient.onUnauthorized = _handleUnauthorized;
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _handleUnauthorized() {
    clearUserSession();
  }

  Future<void> initialize() async {
    try {
      await _apiClient.loadSavedToken();

      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(AppConstants.keyUserData);

      if (userJsonString != null && userJsonString.isNotEmpty) {
        try {
          final decoded = jsonDecode(userJsonString);
          if (decoded is Map<String, dynamic>) {
            _user = User.fromJson(decoded);
          }
        } catch (_) {}
      }

      if (_user != null && _apiClient.authToken != null) {
        await refreshProfile();
      }
    } catch (_) {
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
    String? captcha,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = <String, dynamic>{
        'identifier': identifier.trim(),
        'password': password,
      };

      if (captcha != null && captcha.trim().isNotEmpty) {
        payload['captcha'] = captcha.trim();
      }

      final response = await _apiClient.post('/auth/login', body: payload);

      Map<String, dynamic>? userData;
      String? token;

      if (response is Map<String, dynamic>) {
        if (response['data'] is Map<String, dynamic>) {
          final data = response['data'] as Map<String, dynamic>;
          userData = (data['user'] is Map<String, dynamic>)
              ? data['user'] as Map<String, dynamic>
              : data;
          token = data['token']?.toString();
        } else if (response['user'] is Map<String, dynamic>) {
          userData = response['user'] as Map<String, dynamic>;
          token = response['token']?.toString();
        }
      }

      if (userData == null) {
        throw const ApiException('Format respons server tidak sesuai');
      }

      final loggedInUser = User.fromJson(userData);

      if (token != null && token.isNotEmpty) {
        await _apiClient.setAuthToken(token);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.keyUserData,
        jsonEncode(loggedInUser.toJson()),
      );

      _user = loggedInUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorUtils.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final response = await _apiClient.get('/profile/me');
      if (response is Map<String, dynamic>) {
        final userData = (response['data'] is Map<String, dynamic>)
            ? response['data'] as Map<String, dynamic>
            : response;

        final updatedUser = User.fromJson(userData);
        _user = updatedUser;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.keyUserData,
          jsonEncode(updatedUser.toJson()),
        );

        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> updateProfile({
    String? nama,
    String? email,
    String? telepon,
    String? password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = <String, dynamic>{};
      if (nama != null) payload['nama'] = nama;
      if (email != null) payload['email'] = email;
      if (telepon != null) payload['telepon'] = telepon;
      if (password != null && password.isNotEmpty) payload['password'] = password;

      final response = await _apiClient.put('/profile/me', body: payload);

      Map<String, dynamic>? userData;
      if (response is Map<String, dynamic>) {
        userData = (response['data'] is Map<String, dynamic>)
            ? response['data'] as Map<String, dynamic>
            : response;
      }

      if (userData != null) {
        final updatedUser = User.fromJson(userData);
        _user = updatedUser;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          AppConstants.keyUserData,
          jsonEncode(updatedUser.toJson()),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = ErrorUtils.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (_) {}
    await clearUserSession();
  }

  Future<void> clearUserSession() async {
    await _apiClient.clearAuthToken();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserData);
    } catch (_) {}

    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> fetchCaptcha() async {
    try {
      final response = await _apiClient.get('/auth/captcha');
      return response?.toString();
    } catch (e) {
      _errorMessage = ErrorUtils.getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }
}
