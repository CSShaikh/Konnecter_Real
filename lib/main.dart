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
      final savedLanguage = await LanguageStorage.load();

      if (!mounted) return;

      setState(() {
        _language = savedLanguage;
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

    setState(() {
      _language = language;
    });
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const AuthScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          return const AuthScreen();
        }

        if (user.emailVerified) {
          return CustomerHomeScreen(user: user);
        }

        // Unverified email accounts ko home screen access nahi milega.
        return const AuthScreen();
      },
    );
  }
}
