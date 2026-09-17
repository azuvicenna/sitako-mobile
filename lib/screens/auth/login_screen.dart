import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../validations/auth_validators.dart';
import '../../widgets/app_alert.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nisController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoadingCaptcha = false;
  String? _captchaSvg;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoadCaptcha();
    });
  }

  @override
  void dispose() {
    _nisController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndLoadCaptcha() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
      return;
    }
    await _fetchCaptcha();
  }

  Future<void> _fetchCaptcha({bool clearError = true}) async {
    setState(() {
      _isLoadingCaptcha = true;
      if (clearError) {
        _generalError = null;
      }
    });

    final authProvider = context.read<AuthProvider>();
    final svg = await authProvider.fetchCaptcha();

    if (mounted) {
      setState(() {
        _captchaSvg = svg;
        _isLoadingCaptcha = false;
        if (svg == null && authProvider.errorMessage != null && clearError) {
          _generalError = authProvider.errorMessage;
        }
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _generalError = null;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      identifier: _nisController.text.trim(),
      password: _passwordController.text,
      captcha: _captchaController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    } else {
      setState(() {
        _generalError = authProvider.errorMessage ?? 'Gagal masuk ke sistem';
        _captchaController.clear();
      });
      await _fetchCaptcha(clearError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentYear = DateTime.now().year;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Masuk ke Akun',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoalDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Gunakan NIS untuk Siswa/Anggota perpustakaan.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.charcoalMuted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_generalError != null) ...[
                            AppAlert(
                              variant: AppAlertVariant.danger,
                              title: _generalError,
                            ),
                            const SizedBox(height: 16),
                          ],
                          AppTextField(
                            controller: _nisController,
                            labelText: 'NIS',
                            hintText: 'Masukkan NIS Anda',
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                            validator: AuthValidators.validateNis,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passwordController,
                            labelText: 'Kata Sandi',
                            hintText: 'Masukkan kata sandi akun',
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: AppColors.charcoalMuted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: AuthValidators.validatePassword,
                          ),
                          const SizedBox(height: 16),
                          _buildCaptchaSection(),
                          const SizedBox(height: 24),
                          AppButton(
                            text: 'Masuk ke Sistem',
                            isFullWidth: true,
                            isLoading: authProvider.isLoading,
                            icon: const Icon(Icons.login, size: 18),
                            onPressed: authProvider.isLoading ? null : _handleLogin,
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 16),
                          _buildInformationNotice(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '© $currentYear ${AppConstants.appName} • Sistem Informasi Perpustakaan',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.charcoalMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.mustard,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.mustard.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            size: 26,
            color: AppColors.charcoalDark,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.charcoalDark,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Perpustakaan Digital Sekolah',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.charcoalMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCaptchaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kode Verifikasi (CAPTCHA)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoalDark,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.neutralLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: _isLoadingCaptcha
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : (_captchaSvg != null && _captchaSvg!.isNotEmpty)
                        ? SvgPicture.string(
                            _captchaSvg!,
                            fit: BoxFit.contain,
                            height: 38,
                          )
                        : const Text(
                            'CAPTCHA Kosong',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.charcoalMuted,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              width: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: AppColors.border),
                ),
                onPressed: _isLoadingCaptcha ? null : _fetchCaptcha,
                child: _isLoadingCaptcha
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.refresh,
                        size: 20,
                        color: AppColors.charcoal,
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: _captchaController,
          hintText: 'Ketik kode CAPTCHA di atas',
          textInputAction: TextInputAction.done,
          prefixIcon: const Icon(Icons.security, size: 20),
          validator: AuthValidators.validateCaptcha,
          onSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }

  Widget _buildInformationNotice() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: 16,
          color: AppColors.mustardHover,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Belum memiliki akun atau lupa kata sandi? Silakan hubungi petugas perpustakaan sekolah untuk aktivasi dan pengelolaan akun.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.charcoalMuted,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
