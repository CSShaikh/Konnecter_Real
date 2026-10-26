import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.session});

  final PhoneOtpSession session;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  late PhoneOtpSession _session;
  StreamSubscription<User?>? _authSubscription;

  bool _isLoading = false;
  bool _isResending = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;

    if (_session.autoVerified || AuthService.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
    }

    _authSubscription = AuthService.authStateChanges.listen((user) {
      if (user != null) _finish();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _finish() {
    if (!mounted || _finished) return;
    _finished = true;

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _verifyCode() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.verifyPhoneOtp(
        session: _session,
        smsCode: _codeController.text.trim(),
      );

      _finish();
    } catch (error) {
      _showMessage(AuthService.getErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    if (_isLoading || _isResending) return;

    setState(() => _isResending = true);

    try {
      final updatedSession = await AuthService.sendPhoneOtp(
        _session.phoneNumber,
        forceResendingToken: _session.resendToken,
      );

      if (!mounted) return;

      if (updatedSession.autoVerified) {
        _finish();
        return;
      }

      setState(() {
        _session = updatedSession;
        _codeController.clear();
      });

      _showMessage('A new verification code has been requested.');
    } catch (error) {
      _showMessage(AuthService.getErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify your number')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.mark_chat_unread_outlined,
                      size: 64,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Enter verification code',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter the six-digit code sent to ${_session.phoneNumber}.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(letterSpacing: 10),
                      decoration: const InputDecoration(
                        labelText: 'Verification code',
                        hintText: '••••••',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final code = value?.trim() ?? '';

                        if (code.isEmpty) {
                          return 'Please enter the verification code.';
                        }

                        if (!RegExp(r'^\d{6}$').hasMatch(code)) {
                          return 'Enter the complete six-digit code.';
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) => _verifyCode(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isLoading ? null : _verifyCode,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Verify and continue'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: (_isLoading || _isResending)
                          ? null
                          : _resendCode,
                      child: _isResending
                          ? const Text('Requesting new code...')
                          : const Text('Resend verification code'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: (_isLoading || _isResending)
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Change phone number'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
