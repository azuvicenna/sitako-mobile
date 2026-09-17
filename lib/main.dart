import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'routes/app_routes.dart';
import 'screens/auth/login_screen.dart';
import 'screens/member/member_main_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SitakoApp());
}

class SitakoApp extends StatelessWidget {
  const SitakoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
      ],
      child: MaterialApp(
        title: 'SITAKO',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
        routes: AppRoutes.routes,
        onUnknownRoute: AppRoutes.onUnknownRoute,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.mustard),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const MemberMainScreen();
    }

    return const LoginScreen();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SitakoApp();
  }
}
