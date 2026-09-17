import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';

class AppModal {
  AppModal._();

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Ya, Lanjutkan',
    String cancelText = 'Batal',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalDark,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.charcoal,
          ),
        ),
        actions: [
          AppButton(
            text: cancelText,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          AppButton(
            text: confirmText,
            variant: isDestructive
                ? AppButtonVariant.danger
                : AppButtonVariant.primary,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
  }

  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.secondaryHover,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoalDark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
