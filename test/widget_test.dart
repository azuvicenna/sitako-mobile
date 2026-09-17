import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sitako_mobile/main.dart';
import 'package:sitako_mobile/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SitakoApp builds successfully and displays initial root route',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SitakoApp());
    await tester.pumpAndSettle();

    expect(find.text('SITAKO'), findsOneWidget);

    final authProvider =
        tester.element(find.text('SITAKO')).read<AuthProvider>();
    expect(authProvider, isNotNull);
    expect(authProvider.isAuthenticated, isFalse);
  });
}
