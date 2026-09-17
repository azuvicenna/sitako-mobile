import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant {
  primary,
  dark,
  secondary,
  danger,
  outline,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 44.0,
  });

  Color get _backgroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.mustard;
      case AppButtonVariant.dark:
        return AppColors.charcoalDark;
      case AppButtonVariant.secondary:
        return AppColors.neutralLight;
      case AppButtonVariant.danger:
        return AppColors.danger;
      case AppButtonVariant.outline:
        return Colors.transparent;
    }
  }

  Color get _foregroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.charcoalDark;
      case AppButtonVariant.dark:
        return Colors.white;
      case AppButtonVariant.secondary:
        return AppColors.charcoalDark;
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.outline:
        return AppColors.charcoalDark;
    }
  }

  BorderSide get _borderSide {
    switch (variant) {
      case AppButtonVariant.secondary:
      case AppButtonVariant.outline:
        return const BorderSide(color: AppColors.border);
      default:
        return BorderSide.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDisabled = onPressed == null || isLoading;

    final buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: _foregroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            trailingIcon!,
          ],
        ],
      ],
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: effectiveDisabled ? _backgroundColor.withValues(alpha: 0.5) : _backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: _borderSide,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: effectiveDisabled ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}
