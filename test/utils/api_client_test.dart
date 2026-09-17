import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sitako_mobile/utils/api_client.dart';
import 'package:sitako_mobile/utils/error_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiClient', () {
    test('successfully executes GET request and parses JSON response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/api/books'));
        expect(request.headers['Accept'], equals('application/json'));
        expect(request.headers['X-Requested-With'], equals('XMLHttpRequest'));

        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {'id': '1', 'judul': 'Laskar Pelangi'}
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      final result = await api.get('/books');

      expect(result['success'], isTrue);
      expect(result['data'], isList);
      expect(result['data'][0]['judul'], equals('Laskar Pelangi'));
    });

    test('includes Bearer token header when authToken is set', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], equals('Bearer my-secret-token'));
        return http.Response(jsonEncode({'success': true}), 200);
      });

      final api = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      await api.setAuthToken('my-secret-token', persist: false);

      final result = await api.get('/profile');
      expect(result['success'], isTrue);
    });

    test('throws ApiException with server message when status code is 400 or above', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'NIP sudah terdaftar di database',
          }),
          400,
        );
      });

      final api = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');

      expect(
        () => api.post('/register', body: {'nip': '12345'}),
        throwsA(isA<ApiException>().having(
          (e) => e.message,
          'message',
          equals('NIP sudah terdaftar di database'),
        )),
      );
    });

    test('invokes onUnauthorized callback when server returns 401', () async {
      var unauthorizedCalled = false;

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Sesi telah kedaluwarsa'}),
          401,
        );
      });

      final api = ApiClient(
        client: mockClient,
        baseUrl: 'http://localhost:8080/api',
        onUnauthorized: () {
          unauthorizedCalled = true;
        },
      );

      try {
        await api.get('/protected-data');
      } catch (_) {}

      expect(unauthorizedCalled, isTrue);
    });

    test('clears authToken properly with clearAuthToken', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response(jsonEncode({'success': true}), 200);
      });

      final api = ApiClient(client: mockClient, baseUrl: 'http://localhost:8080/api');
      await api.setAuthToken('temp-token', persist: false);
      expect(api.authToken, equals('temp-token'));

      await api.clearAuthToken();
      expect(api.authToken, isNull);

      await api.get('/public');
    });
  });
}
