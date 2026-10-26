class AuthValidators {
  AuthValidators._();

  static String? validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) return 'Please enter your full name.';
    if (name.length < 2) return 'Name must contain at least 2 characters.';
    if (name.length > 60) return 'Name cannot exceed 60 characters.';

    final pattern = RegExp(
      r"^[\p{L}\p{M}]+(?:[ '\u2019-][\p{L}\p{M}]+)*$",
      unicode: true,
    );

    if (!pattern.hasMatch(name)) {
      return 'Enter a valid name.';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Please enter your email address.';

    final pattern = RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
      r"(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
    );

    if (!pattern.hasMatch(email) || email.length > 254) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? validateIndianMobile(String? value) {
    final input = (value ?? '').trim();

    if (input.isEmpty) return 'Please enter your mobile number.';

    final cleaned = input.replaceAll(RegExp(r'[\s-]'), '');
    String number;

    if (RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      number = cleaned;
    } else if (RegExp(r'^\+91[6-9]\d{9}$').hasMatch(cleaned)) {
      number = cleaned.substring(3);
    } else if (RegExp(r'^91[6-9]\d{9}$').hasMatch(cleaned)) {
      number = cleaned.substring(2);
    } else {
      return 'Enter a valid 10-digit Indian mobile number.';
    }

    if (RegExp(r'^(\d)\1{9}$').hasMatch(number)) {
      return 'Enter a valid mobile number.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) return 'Please enter your password.';
    if (password.length < 8) {
      return 'Password must contain at least 8 characters.';
    }
    if (password.length > 128) {
      return 'Password cannot exceed 128 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Include at least one uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Include at least one lowercase letter.';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Include at least one number.';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != password) {
      return 'Passwords do not match.';
    }

    return null;
  }

  static String? validateOtp(String? value) {
    final otp = (value ?? '').trim();

    if (otp.isEmpty) return 'Please enter the OTP.';
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'OTP must contain exactly 6 digits.';
    }

    return null;
  }
}
