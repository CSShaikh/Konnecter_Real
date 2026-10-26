import 'package:flutter_test/flutter_test.dart';
import 'package:konnecter_customer/core/validators/auth_validators.dart';

void main() {
  group('Name validation', () {
    test('rejects empty name', () {
      expect(AuthValidators.validateName(''), isNotNull);
    });

    test('accepts a valid English name', () {
      expect(AuthValidators.validateName('Rahul Sharma'), isNull);
    });

    test('accepts a Hindi name', () {
      expect(AuthValidators.validateName('राहुल शर्मा'), isNull);
    });
  });

  group('Indian mobile validation', () {
    test('accepts a valid 10-digit number', () {
      expect(AuthValidators.validateIndianMobile('9876543210'), isNull);
    });

    test('accepts number with country code', () {
      expect(AuthValidators.validateIndianMobile('+919876543210'), isNull);
    });

    test('rejects an invalid number', () {
      expect(AuthValidators.validateIndianMobile('12345'), isNotNull);
    });
  });

  group('OTP validation', () {
    test('accepts six digits', () {
      expect(AuthValidators.validateOtp('123456'), isNull);
    });

    test('rejects fewer than six digits', () {
      expect(AuthValidators.validateOtp('1234'), isNotNull);
    });
  });
}
