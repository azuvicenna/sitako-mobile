import '../models/user.dart';
import '../utils/api_client.dart';
import '../utils/error_utils.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    String? captcha,
  }) async {
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

    final user = User.fromJson(userData);
    return {
      'user': user,
      'token': token,
    };
  }

  Future<User> getProfile() async {
    final response = await _apiClient.get('/profile/me');
    if (response is Map<String, dynamic>) {
      final userData = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : response;
      return User.fromJson(userData);
    }
    throw const ApiException('Format profil tidak valid');
  }

  Future<User> updateProfile({
    String? nama,
    String? email,
    String? telepon,
    String? password,
  }) async {
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
      return User.fromJson(userData);
    }
    throw const ApiException('Gagal memperbarui profil pengguna');
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (_) {}
  }

  Future<String?> fetchCaptcha() async {
    final response = await _apiClient.get('/auth/captcha');
    return response?.toString();
  }
}
