import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/api_client.dart';
import '../utils/constants.dart';
import '../utils/error_utils.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final AuthService _authService;

  User? _user;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({ApiClient? apiClient, AuthService? authService})
      : _apiClient = apiClient ?? ApiClient.instance,
        _authService = authService ??
            AuthService(apiClient: apiClient ?? ApiClient.instance) {
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
      final result = await _authService.login(
        identifier: identifier,
        password: password,
        captcha: captcha,
      );

      final loggedInUser = result['user'] as User;
      final token = result['token']?.toString();

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
      final updatedUser = await _authService.getProfile();
      _user = updatedUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.keyUserData,
        jsonEncode(updatedUser.toJson()),
      );

      notifyListeners();
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
      final updatedUser = await _authService.updateProfile(
        nama: nama,
        email: email,
        telepon: telepon,
        password: password,
      );

      _user = updatedUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.keyUserData,
        jsonEncode(updatedUser.toJson()),
      );

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
    await _authService.logout();
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
      final captcha = await _authService.fetchCaptcha();
      return captcha;
    } catch (e) {
      _errorMessage = ErrorUtils.getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    if (_apiClient.onUnauthorized == _handleUnauthorized) {
      _apiClient.onUnauthorized = null;
    }
    super.dispose();
  }
}
