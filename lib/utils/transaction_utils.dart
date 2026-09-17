import 'package:flutter/material.dart';

enum TransactionBadgeVariant {
  warning,
  success,
  danger,
  info,
  neutral;

  String get name {
    switch (this) {
      case TransactionBadgeVariant.warning:
        return 'warning';
      case TransactionBadgeVariant.success:
        return 'success';
      case TransactionBadgeVariant.danger:
        return 'danger';
      case TransactionBadgeVariant.info:
        return 'info';
      case TransactionBadgeVariant.neutral:
        return 'neutral';
    }
  }
}

class TransactionUtils {
  TransactionUtils._();

  static TransactionBadgeVariant getStatusBadgeVariant(String? status) {
    switch (status) {
      case 'Dipinjam':
        return TransactionBadgeVariant.warning;
      case 'Dikembalikan':
        return TransactionBadgeVariant.success;
      case 'Terlambat':
      case 'Tidak Mengembalikan':
        return TransactionBadgeVariant.danger;
      case 'Menunggu Persetujuan':
      case 'Menunggu Diambil':
        return TransactionBadgeVariant.info;
      case 'Dibatalkan':
      default:
        return TransactionBadgeVariant.neutral;
    }
  }

  static Color getStatusColor(String? status) {
    final variant = getStatusBadgeVariant(status);
    switch (variant) {
      case TransactionBadgeVariant.warning:
        return const Color(0xFFF59E0B);
      case TransactionBadgeVariant.success:
        return const Color(0xFF10B981);
      case TransactionBadgeVariant.danger:
        return const Color(0xFFEF4444);
      case TransactionBadgeVariant.info:
        return const Color(0xFF3B82F6);
      case TransactionBadgeVariant.neutral:
        return const Color(0xFF6B7280);
    }
  }

  static Color getStatusBackgroundColor(String? status) {
    final variant = getStatusBadgeVariant(status);
    switch (variant) {
      case TransactionBadgeVariant.warning:
        return const Color(0xFFFEF3C7);
      case TransactionBadgeVariant.success:
        return const Color(0xFFD1FAE5);
      case TransactionBadgeVariant.danger:
        return const Color(0xFFFEE2E2);
      case TransactionBadgeVariant.info:
        return const Color(0xFFDBEAFE);
      case TransactionBadgeVariant.neutral:
        return const Color(0xFFF3F4F6);
    }
  }

  static Color getStatusTextColor(String? status) {
    final variant = getStatusBadgeVariant(status);
    switch (variant) {
      case TransactionBadgeVariant.warning:
        return const Color(0xFFB45309);
      case TransactionBadgeVariant.success:
        return const Color(0xFF047857);
      case TransactionBadgeVariant.danger:
        return const Color(0xFFB91C1C);
      case TransactionBadgeVariant.info:
        return const Color(0xFF1D4ED8);
      case TransactionBadgeVariant.neutral:
        return const Color(0xFF374151);
    }
  }

  static String getStatusLabel(String? status) {
    if (status == null || status.trim().isEmpty) {
      return '-';
    }
    return status.trim();
  }
}

TransactionBadgeVariant getStatusBadgeVariant(String? status) =>
    TransactionUtils.getStatusBadgeVariant(status);

Color getStatusColor(String? status) => TransactionUtils.getStatusColor(status);

Color getStatusBackgroundColor(String? status) =>
    TransactionUtils.getStatusBackgroundColor(status);

Color getStatusTextColor(String? status) =>
    TransactionUtils.getStatusTextColor(status);
