import 'common_validators.dart';

class AuthValidators {
  AuthValidators._();

  static String? validateNis(String? value) {
    return CommonValidators.requiredField(
      value,
      fieldName: 'NIS',
      customMessage: 'NIS wajib diisi',
    );
  }

  static String? validatePassword(String? value) {
    return CommonValidators.requiredField(
      value,
      fieldName: 'Kata sandi',
      customMessage: 'Kata sandi wajib diisi',
    );
  }

  static String? validateCaptcha(String? value) {
    return CommonValidators.requiredField(
      value,
      fieldName: 'Kode CAPTCHA',
      customMessage: 'Kode CAPTCHA wajib diisi',
    );
  }
}
