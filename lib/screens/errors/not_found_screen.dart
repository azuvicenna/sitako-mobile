import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/app_button.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentYear = DateTime.now().year;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.mustard,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 20,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: AppColors.mustardLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.mustard.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              size: 34,
                              color: AppColors.mustardHover,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.neutralLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Galat 404',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Halaman Tidak Ditemukan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoalDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Maaf, rute halaman yang Anda tuju tidak dapat ditemukan atau telah dipindahkan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.charcoalMuted,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            text: authProvider.isAuthenticated
                                ? 'Kembali ke Beranda'
                                : 'Kembali ke Login',
                            variant: AppButtonVariant.primary,
                            isFullWidth: true,
                            icon: const Icon(Icons.home, size: 16),
                            onPressed: () {
                              final targetRoute = authProvider.isAuthenticated
                                  ? AppRoutes.main
                                  : AppRoutes.login;
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                targetRoute,
                                (route) => false,
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          AppButton(
                            text: 'Halaman Sebelumnya',
                            variant: AppButtonVariant.secondary,
                            isFullWidth: true,
                            icon: const Icon(Icons.arrow_back, size: 16),
                            onPressed: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                final targetRoute = authProvider.isAuthenticated
                                    ? AppRoutes.main
                                    : AppRoutes.login;
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  targetRoute,
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '© $currentYear ${AppConstants.appName} • ${AppConstants.appDescription}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.charcoalMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
