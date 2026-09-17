class CommonValidators {
  CommonValidators._();

  static String? requiredField(
    String? value, {
    String fieldName = 'Bidang ini',
    String? customMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ?? '$fieldName wajib diisi';
    }
    return null;
  }

  static String? minLength(
    String? value,
    int minLength, {
    String fieldName = 'Bidang ini',
    String? customMessage,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < minLength) {
      return customMessage ?? '$fieldName minimal $minLength karakter';
    }
    return null;
  }

  static String? maxLength(
    String? value,
    int maxLength, {
    String fieldName = 'Bidang ini',
    String? customMessage,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > maxLength) {
      return customMessage ?? '$fieldName maksimal $maxLength karakter';
    }
    return null;
  }

  static String? numericOnly(
    String? value, {
    String fieldName = 'Bidang ini',
    String? customMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final numericRegex = RegExp(r'^[0-9]+$');
    if (!numericRegex.hasMatch(value.trim())) {
      return customMessage ?? '$fieldName hanya boleh berupa angka';
    }
    return null;
  }

  static String? email(
    String? value, {
    String? customMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return customMessage ?? 'Format email tidak valid';
    }
    return null;
  }

  static String? phone(
    String? value, {
    String? customMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final phoneRegex = RegExp(r'^(08|\+628)[0-9]{8,12}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return customMessage ?? 'Nomor telepon tidak valid (contoh: 081234567890)';
    }
    return null;
  }
}
