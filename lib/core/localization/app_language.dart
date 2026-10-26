import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, hindi, marathi }

extension AppLanguageDetails on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.hindi:
        return 'hi';
      case AppLanguage.marathi:
        return 'mr';
    }
  }

  String get nativeName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.hindi:
        return 'हिन्दी';
      case AppLanguage.marathi:
        return 'मराठी';
    }
  }

  String get subtitle {
    switch (this) {
      case AppLanguage.english:
        return 'Continue in English';
      case AppLanguage.hindi:
        return 'हिन्दी में जारी रखें';
      case AppLanguage.marathi:
        return 'मराठीत पुढे जा';
    }
  }

  Locale get locale => Locale(code);
}

class LanguageStorage {
  static const String _key = 'selected_language';

  static Future<AppLanguage?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);

    for (final language in AppLanguage.values) {
      if (language.code == code) return language;
    }

    return null;
  }

  static Future<void> save(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language.code);
  }
}
