import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // أضف هذه الاستيرادة

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  Future<bool> load() async {
    try {
      String jsonString;
      final path = 'assets/langs/app_${locale.languageCode}.json';

      if (kIsWeb) {
        // حل خاص للويب
        final response = await http.get(Uri.base.resolve(path));
        if (response.statusCode == 200) {
          jsonString = response.body;
        } else {
          throw Exception('Failed to load: ${response.statusCode}');
        }
      } else {
        // حل للأجهزة المحمولة
        jsonString = await rootBundle.loadString(path);
      }

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      return true;
    } catch (e) {
      debugPrint('Error loading ${locale.languageCode} file: $e');
      // قيم افتراضية في حالة الخطأ
      _localizedStrings = locale.languageCode == 'ar'
          ? {'app_name': 'لوحة التحكم'}
          : {'app_name': 'Dashboard'};
      return false;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}