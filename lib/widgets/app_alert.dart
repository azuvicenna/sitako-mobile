import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppAlertVariant {
  mustard,
  danger,
  success,
  info,
}

class AppAlert extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? icon;
  final AppAlertVariant variant;
  final Widget? action;
  final Widget? child;

  const AppAlert({
    super.key,
    this.title,
    this.description,
    this.icon,
    this.variant = AppAlertVariant.mustard,
    this.action,
    this.child,
  });

  Color get _containerColor {
    switch (variant) {
      case AppAlertVariant.danger:
        return AppColors.dangerLight;
      case AppAlertVariant.success:
        return AppColors.successLight;
      case AppAlertVariant.info:
        return AppColors.infoLight;
      case AppAlertVariant.mustard:
        return AppColors.mustardLight;
    }
  }

  Color get _borderColor {
    switch (variant) {
      case AppAlertVariant.danger:
        return AppColors.danger.withValues(alpha: 0.3);
      case AppAlertVariant.success:
        return AppColors.success.withValues(alpha: 0.3);
      case AppAlertVariant.info:
        return AppColors.info.withValues(alpha: 0.3);
      case AppAlertVariant.mustard:
        return AppColors.mustard.withValues(alpha: 0.3);
    }
  }

  Color get _textColor {
    switch (variant) {
      case AppAlertVariant.danger:
        return AppColors.dangerText;
      case AppAlertVariant.success:
        return AppColors.successText;
      case AppAlertVariant.info:
        return AppColors.infoText;
      case AppAlertVariant.mustard:
        return AppColors.charcoalDark;
    }
  }

  Color get _iconColor {
    switch (variant) {
      case AppAlertVariant.danger:
        return AppColors.danger;
      case AppAlertVariant.success:
        return AppColors.success;
      case AppAlertVariant.info:
        return AppColors.info;
      case AppAlertVariant.mustard:
        return AppColors.mustardHover;
    }
  }

  IconData get _defaultIconData {
    switch (variant) {
      case AppAlertVariant.danger:
        return Icons.error_outline;
      case AppAlertVariant.success:
        return Icons.check_circle_outline;
      case AppAlertVariant.info:
        return Icons.info_outline;
      case AppAlertVariant.mustard:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _containerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon ??
              Icon(
                _defaultIconData,
                color: _iconColor,
                size: 20,
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _textColor,
                    ),
                  ),
                if (description != null) ...[
                  if (title != null) const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: _textColor.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                if (child != null) ...[
                  if (title != null || description != null)
                    const SizedBox(height: 8),
                  child!,
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            action!,
          ],
        ],
      ),
    );
  }
}
