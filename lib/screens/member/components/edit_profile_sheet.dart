import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../validations/profile_validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class EditProfileSheet extends StatefulWidget {
  final User user;

  const EditProfileSheet({super.key, required this.user});

  static Future<void> show(BuildContext context, {required User user}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditProfileSheet(user: user),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    final newPassword = _passwordController.text.trim();

    final success = await authProvider.updateProfile(
      nama: _nameController.text.trim(),
      email: _emailController.text.trim(),
      telepon: _phoneController.text.trim(),
      password: newPassword.isNotEmpty ? newPassword : null,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'Gagal memperbarui profil';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                'Edit Informasi Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 12, color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              AppTextField(
                labelText: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                validator: ProfileValidators.validateNama,
              ),
              const SizedBox(height: 14),

              AppTextField(
                labelText: 'Alamat Email',
                hintText: 'contoh@domain.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                validator: ProfileValidators.validateEmail,
              ),
              const SizedBox(height: 14),

              AppTextField(
                labelText: 'Nomor Telepon / WhatsApp',
                hintText: '08123456789',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                validator: ProfileValidators.validateTelepon,
              ),
              const SizedBox(height: 14),

              AppTextField(
                labelText: 'Kata Sandi Baru (Opsional)',
                hintText: 'Kosongkan jika tidak ingin mengubah',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                validator: ProfileValidators.validateNewPassword,
              ),
              const SizedBox(height: 24),

              AppButton(
                text: 'Simpan Perubahan',
                isLoading: _isSubmitting,
                isFullWidth: true,
                icon: const Icon(Icons.save_outlined, size: 18),
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
