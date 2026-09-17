import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../utils/image_utils.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_modal.dart';
import 'components/edit_profile_sheet.dart';

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AppModal.showConfirmDialog(
      context,
      title: 'Konfirmasi Keluar',
      message: 'Apakah Anda yakin ingin keluar dari akun perpustakaan?',
      confirmText: 'Keluar',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    final userName = user?.nama ?? 'Anggota Perpustakaan';
    final nis = user?.identifier ?? user?.nis ?? '-';
    final email = user?.email ?? '-';
    final telepon = user?.telepon ?? '-';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: ImageUtils.getAvatarColor(userName).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ImageUtils.getAvatarColor(userName).withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ImageUtils.getInitials(userName),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ImageUtils.getAvatarColor(userName),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIS: $nis',
                      style: const TextStyle(fontSize: 13, color: AppColors.charcoalMuted),
                    ),
                    const SizedBox(height: 8),
                    const AppBadge(
                      label: 'Anggota Siswa',
                      variant: AppBadgeVariant.mustard,
                      size: AppBadgeSize.md,
                      showDot: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Data Diri',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Nomor Induk Siswa (NIS)',
                      value: nis,
                    ),
                    const Divider(color: AppColors.border, height: 20),
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'Nama Lengkap',
                      value: userName,
                    ),
                    const Divider(color: AppColors.border, height: 20),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Alamat Email',
                      value: email,
                    ),
                    const Divider(color: AppColors.border, height: 20),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Nomor Telepon / WhatsApp',
                      value: telepon,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'Edit Informasi Profil',
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () {
                  if (user != null) {
                    EditProfileSheet.show(context, user: user);
                  }
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Keluar dari Akun',
                variant: AppButtonVariant.danger,
                isFullWidth: true,
                icon: const Icon(Icons.logout, size: 18),
                onPressed: () => _handleLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.charcoalMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.charcoalMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoalDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
