import 'common_validators.dart';

class ProfileValidators {
  ProfileValidators._();

  static String? validateNama(String? value) {
    final requiredError = CommonValidators.requiredField(
      value,
      fieldName: 'Nama lengkap',
      customMessage: 'Nama lengkap wajib diisi',
    );
    if (requiredError != null) return requiredError;

    return CommonValidators.minLength(
      value,
      2,
      fieldName: 'Nama lengkap',
      customMessage: 'Nama minimal 2 karakter',
    );
  }

  static String? validateEmail(String? value) {
    final requiredError = CommonValidators.requiredField(
      value,
      fieldName: 'Email',
      customMessage: 'Email wajib diisi',
    );
    if (requiredError != null) return requiredError;

    return CommonValidators.email(
      value,
      customMessage: 'Format email tidak valid',
    );
  }

  static String? validateTelepon(String? value) {
    final requiredError = CommonValidators.requiredField(
      value,
      fieldName: 'Nomor telepon',
      customMessage: 'Nomor telepon wajib diisi',
    );
    if (requiredError != null) return requiredError;

    return CommonValidators.phone(
      value,
      customMessage: 'Nomor telepon tidak valid (contoh: 081234567890)',
    );
  }

  static String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return CommonValidators.minLength(
      value,
      4,
      fieldName: 'Kata sandi baru',
      customMessage: 'Kata sandi baru minimal 4 karakter',
    );
  }
}
