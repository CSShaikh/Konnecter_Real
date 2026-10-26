import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<User> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Account creation failed. Please try again.');
    }

    await user.updateDisplayName(name.trim());
    await user.reload();

    return _auth.currentUser ?? user;
  }

  static Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Sign-in failed. Please try again.');
    }

    // Email verification is temporarily not required.
    return user;
  }

  static Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<PhoneOtpSession> sendPhoneOtp(
    String phoneNumber, {
    int? forceResendingToken,
  }) async {
    if (kIsWeb) {
      final confirmation = await _auth.signInWithPhoneNumber(phoneNumber);

      return PhoneOtpSession(
        phoneNumber: phoneNumber,
        webConfirmationResult: confirmation,
      );
    }

    final completer = Completer<PhoneOtpSession>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResendingToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await _auth.signInWithCredential(credential);

          if (!completer.isCompleted) {
            completer.complete(
              PhoneOtpSession(phoneNumber: phoneNumber, autoVerified: true),
            );
          }
        } catch (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        }
      },
      verificationFailed: (FirebaseAuthException error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneOtpSession(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return completer.future;
  }

  static Future<UserCredential> verifyPhoneOtp({
    required PhoneOtpSession session,
    required String smsCode,
  }) async {
    if (kIsWeb) {
      final confirmation = session.webConfirmationResult;

      if (confirmation == null) {
        throw Exception(
          'Your verification session expired. Request a new code.',
        );
      }

      return confirmation.confirm(smsCode.trim());
    }

    final verificationId = session.verificationId;

    if (verificationId == null || verificationId.isEmpty) {
      throw Exception('Your verification session expired. Request a new code.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );

    return _auth.signInWithCredential(credential);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static String getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'An account with this email already exists. Please sign in.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
        case 'password-does-not-meet-requirements':
          return 'Your password does not meet the security requirements.';
        case 'invalid-credential':
        case 'invalid-login-credentials':
        case 'wrong-password':
        case 'user-not-found':
          return 'Invalid email address or password.';
        case 'invalid-phone-number':
          return 'Please enter a valid phone number with the country code.';
        case 'invalid-verification-code':
          return 'The verification code is incorrect. Please try again.';
        case 'invalid-verification-id':
          return 'The verification session expired. Request a new code.';
        case 'session-expired':
          return 'The verification code expired. Request a new code.';
        case 'quota-exceeded':
          return 'The SMS limit has been reached. Please try again later.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait before trying again.';
        case 'captcha-check-failed':
        case 'missing-client-identifier':
          return 'Human verification failed. Please retry the verification.';
        case 'web-context-cancelled':
          return 'Verification was cancelled. Please try again.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled in Firebase Console.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign-in method.';
        default:
          return 'Authentication failed. Please try again.';
      }
    }

    return error.toString().startsWith('Exception:')
        ? error.toString().replaceFirst('Exception: ', '')
        : 'Something went wrong. Please try again.';
  }
}

class PhoneOtpSession {
  const PhoneOtpSession({
    required this.phoneNumber,
    this.verificationId,
    this.resendToken,
    this.webConfirmationResult,
    this.autoVerified = false,
  });

  final String phoneNumber;
  final String? verificationId;
  final int? resendToken;
  final ConfirmationResult? webConfirmationResult;
  final bool autoVerified;
}
