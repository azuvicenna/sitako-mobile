import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sitako_mobile/models/user.dart';
import 'package:sitako_mobile/providers/auth_provider.dart';
import 'package:sitako_mobile/utils/api_client.dart';
import 'package:sitako_mobile/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthProvider', () {
    test('initializes with default unauthenticated state', () {
      final auth = AuthProvider();
      expect(auth.user, isNull);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.isLoading, isFalse);
    });

    test('initialize restores saved user and token from storage', () async {
      const savedUser = User(
        id: 'usr-1',
        nama: 'Ahmad Fauzi',
        nis: '12345',
        email: 'ahmad@example.com',
        telepon: '08123',
      );

      SharedPreferences.setMockInitialValues({
        AppConstants.keyAuthToken: 'saved-token',
        AppConstants.keyUserData: jsonEncode(savedUser.toJson()),
      });

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/profile/me') {
          return http.Response(
            jsonEncode({'success': true, 'data': savedUser.toJson()}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final auth = AuthProvider(apiClient: apiClient);

      await auth.initialize();

      expect(auth.isInitialized, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?.nama, equals('Ahmad Fauzi'));
      expect(apiClient.authToken, equals('saved-token'));
    });

    test('login succeeds and updates user state', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/auth/login') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'token': 'jwt-token-xyz',
                'user': {
                  'id': 'usr-10',
                  'nama': 'Budi Santoso',
                  'nis': '54321',
                  'email': 'budi@example.com',
                  'telepon': '08999',
                  'status_aktif': true,
                  'role': 'Anggota',
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final auth = AuthProvider(apiClient: apiClient);

      final success = await auth.login(identifier: '54321', password: 'secretpassword');

      expect(success, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?.nama, equals('Budi Santoso'));
      expect(auth.user?.nis, equals('54321'));
      expect(apiClient.authToken, equals('jwt-token-xyz'));
    });

    test('login handles failure and sets error message', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Kredensial tidak valid',
          }),
          401,
        );
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final auth = AuthProvider(apiClient: apiClient);

      final success = await auth.login(identifier: 'wrong', password: 'wrong');

      expect(success, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.errorMessage, equals('Kredensial tidak valid'));
    });

    test('logout clears user state and token', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final auth = AuthProvider(apiClient: apiClient);

      await apiClient.setAuthToken('token-to-clear', persist: false);
      expect(apiClient.authToken, isNotNull);

      await auth.logout();

      expect(auth.isAuthenticated, isFalse);
      expect(auth.user, isNull);
      expect(apiClient.authToken, isNull);
    });

    test('handles 401 unauthorized by clearing user session', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'message': 'Unauthorized'}), 401);
      });

      final apiClient = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final auth = AuthProvider(apiClient: apiClient);

      try {
        await apiClient.get('/api/protected');
      } catch (_) {}

      expect(auth.isAuthenticated, isFalse);
      expect(auth.user, isNull);
    });
  });
}
