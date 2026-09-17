import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppBadgeVariant {
  mustard,
  warning,
  success,
  danger,
  info,
  neutral,
}

enum AppBadgeSize {
  sm,
  md,
  lg,
}

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final AppBadgeSize size;
  final bool showDot;
  final Widget? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.size = AppBadgeSize.md,
    this.showDot = false,
    this.icon,
  });

  Color get _backgroundColor {
    switch (variant) {
      case AppBadgeVariant.mustard:
        return AppColors.mustardLight;
      case AppBadgeVariant.warning:
        return AppColors.warningLight;
      case AppBadgeVariant.success:
        return AppColors.successLight;
      case AppBadgeVariant.danger:
        return AppColors.dangerLight;
      case AppBadgeVariant.info:
        return AppColors.infoLight;
      case AppBadgeVariant.neutral:
        return AppColors.neutralLight;
    }
  }

  Color get _textColor {
    switch (variant) {
      case AppBadgeVariant.mustard:
        return AppColors.charcoalDark;
      case AppBadgeVariant.warning:
        return AppColors.warningText;
      case AppBadgeVariant.success:
        return AppColors.successText;
      case AppBadgeVariant.danger:
        return AppColors.dangerText;
      case AppBadgeVariant.info:
        return AppColors.infoText;
      case AppBadgeVariant.neutral:
        return AppColors.charcoal;
    }
  }

  Color get _dotColor {
    switch (variant) {
      case AppBadgeVariant.mustard:
        return AppColors.mustard;
      case AppBadgeVariant.warning:
        return AppColors.warning;
      case AppBadgeVariant.success:
        return AppColors.success;
      case AppBadgeVariant.danger:
        return AppColors.danger;
      case AppBadgeVariant.info:
        return AppColors.info;
      case AppBadgeVariant.neutral:
        return AppColors.charcoalMuted;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppBadgeSize.sm:
        return 11.0;
      case AppBadgeSize.md:
        return 12.0;
      case AppBadgeSize.lg:
        return 13.0;
    }
  }

  EdgeInsetsGeometry get _padding {
    switch (size) {
      case AppBadgeSize.sm:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case AppBadgeSize.md:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 3);
      case AppBadgeSize.lg:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _dotColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: _textColor,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
