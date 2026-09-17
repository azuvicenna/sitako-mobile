import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final border = Border.all(
      color: borderColor ?? AppColors.border,
      width: 1,
    );

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: border.top,
    );

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: content,
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: cardShape,
        child: content,
      ),
    );
  }
}

class AppAccentCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final double accentHeight;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const AppAccentCard({
    super.key,
    required this.child,
    this.accentColor = AppColors.mustard,
    this.accentHeight = 4.0,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: accentHeight,
                width: double.infinity,
                color: accentColor,
              ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
