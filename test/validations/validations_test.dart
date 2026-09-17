import 'package:flutter_test/flutter_test.dart';
import 'package:sitako_mobile/validations/index.dart';

void main() {
  group('CommonValidators', () {
    test('requiredField returns error message when value is null or empty', () {
      expect(CommonValidators.requiredField(null), equals('Bidang ini wajib diisi'));
      expect(CommonValidators.requiredField(''), equals('Bidang ini wajib diisi'));
      expect(CommonValidators.requiredField('   '), equals('Bidang ini wajib diisi'));
      expect(CommonValidators.requiredField(null, fieldName: 'Email'), equals('Email wajib diisi'));
      expect(CommonValidators.requiredField(null, customMessage: 'Custom error'), equals('Custom error'));
      expect(CommonValidators.requiredField('Valid text'), isNull);
    });

    test('minLength validates string length', () {
      expect(CommonValidators.minLength(null, 5), isNull);
      expect(CommonValidators.minLength('abc', 5), equals('Bidang ini minimal 5 karakter'));
      expect(CommonValidators.minLength('abcde', 5), isNull);
      expect(CommonValidators.minLength('abcdef', 5), isNull);
    });

    test('maxLength validates string max length', () {
      expect(CommonValidators.maxLength(null, 5), isNull);
      expect(CommonValidators.maxLength('abcdef', 5), equals('Bidang ini maksimal 5 karakter'));
      expect(CommonValidators.maxLength('abcde', 5), isNull);
      expect(CommonValidators.maxLength('abc', 5), isNull);
    });

    test('numericOnly validates digit characters', () {
      expect(CommonValidators.numericOnly(null), isNull);
      expect(CommonValidators.numericOnly('12345'), isNull);
      expect(CommonValidators.numericOnly('123a5'), equals('Bidang ini hanya boleh berupa angka'));
      expect(CommonValidators.numericOnly('abc'), equals('Bidang ini hanya boleh berupa angka'));
    });

    test('email validates email structure', () {
      expect(CommonValidators.email(null), isNull);
      expect(CommonValidators.email(''), isNull);
      expect(CommonValidators.email('siswa@sitako.sch.id'), isNull);
      expect(CommonValidators.email('invalid-email'), equals('Format email tidak valid'));
      expect(CommonValidators.email('invalid@'), equals('Format email tidak valid'));
    });

    test('phone validates Indonesian phone numbers', () {
      expect(CommonValidators.phone(null), isNull);
      expect(CommonValidators.phone(''), isNull);
      expect(CommonValidators.phone('081234567890'), isNull);
      expect(CommonValidators.phone('+6281234567890'), isNull);
      expect(CommonValidators.phone('12345'), contains('tidak valid'));
      expect(CommonValidators.phone('021123456'), contains('tidak valid'));
    });
  });

  group('AuthValidators', () {
    test('validateNis validates required', () {
      expect(AuthValidators.validateNis(null), equals('NIS wajib diisi'));
      expect(AuthValidators.validateNis(''), equals('NIS wajib diisi'));
      expect(AuthValidators.validateNis('   '), equals('NIS wajib diisi'));
      expect(AuthValidators.validateNis('2024001'), isNull);
    });

    test('validatePassword validates required', () {
      expect(AuthValidators.validatePassword(null), equals('Kata sandi wajib diisi'));
      expect(AuthValidators.validatePassword(''), equals('Kata sandi wajib diisi'));
      expect(AuthValidators.validatePassword('123'), isNull);
      expect(AuthValidators.validatePassword('rahasia123'), isNull);
    });

    test('validateCaptcha validates required', () {
      expect(AuthValidators.validateCaptcha(null), equals('Kode CAPTCHA wajib diisi'));
      expect(AuthValidators.validateCaptcha(''), equals('Kode CAPTCHA wajib diisi'));
      expect(AuthValidators.validateCaptcha('   '), equals('Kode CAPTCHA wajib diisi'));
      expect(AuthValidators.validateCaptcha('ABCD'), isNull);
    });
  });

  group('ProfileValidators', () {
    test('validateNama validates required and min length', () {
      expect(ProfileValidators.validateNama(null), equals('Nama lengkap wajib diisi'));
      expect(ProfileValidators.validateNama(''), equals('Nama lengkap wajib diisi'));
      expect(ProfileValidators.validateNama('A'), equals('Nama minimal 2 karakter'));
      expect(ProfileValidators.validateNama('Ahmad Fauzi'), isNull);
    });

    test('validateEmail validates required and format', () {
      expect(ProfileValidators.validateEmail(null), equals('Email wajib diisi'));
      expect(ProfileValidators.validateEmail('invalid'), equals('Format email tidak valid'));
      expect(ProfileValidators.validateEmail('ahmad@example.com'), isNull);
    });

    test('validateTelepon validates required and format', () {
      expect(ProfileValidators.validateTelepon(null), equals('Nomor telepon wajib diisi'));
      expect(ProfileValidators.validateTelepon('123'), contains('tidak valid'));
      expect(ProfileValidators.validateTelepon('081234567890'), isNull);
    });

    test('validateNewPassword validates optional min length', () {
      expect(ProfileValidators.validateNewPassword(null), isNull);
      expect(ProfileValidators.validateNewPassword(''), isNull);
      expect(ProfileValidators.validateNewPassword('123'), equals('Kata sandi baru minimal 4 karakter'));
      expect(ProfileValidators.validateNewPassword('123456'), isNull);
    });
  });
}
