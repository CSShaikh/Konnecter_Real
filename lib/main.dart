import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/localization/app_language.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/home/customer_home_screen.dart';
import 'features/language/language_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const KonnecterApp());
}

class KonnecterApp extends StatefulWidget {
  const KonnecterApp({super.key});

  @override
  State<KonnecterApp> createState() => _KonnecterAppState();
}

class _KonnecterAppState extends State<KonnecterApp> {
  AppLanguage? _language;
  bool _loadingLanguage = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final language = await LanguageStorage.load();

      if (!mounted) return;

      setState(() {
        _language = language;
        _loadingLanguage = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _language = null;
        _loadingLanguage = false;
      });
    }
  }

  Future<void> _selectLanguage(AppLanguage language) async {
    await LanguageStorage.save(language);

    if (!mounted) return;

    setState(() => _language = language);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Konnecter Real',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _loadingLanguage
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _language == null
          ? LanguageScreen(onContinue: _selectLanguage)
          : const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      initialData: auth.currentUser,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _AuthErrorScreen();
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data ?? auth.currentUser;

        if (user != null) {
          return CustomerHomeScreen(key: ValueKey(user.uid), user: user);
        }

        return const AuthScreen();
      },
    );
  }
}

class _AuthErrorScreen extends StatelessWidget {
  const _AuthErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Unable to check your sign-in status.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
                  );
                },
                child: const Text('Return to sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
