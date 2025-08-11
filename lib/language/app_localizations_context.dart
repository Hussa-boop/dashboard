import 'package:flutter/material.dart';
import 'app_localizations.dart';

// Extension on BuildContext to easily access translations
extension LocalizationExtension on BuildContext {
  AppLocalizations get tr => AppLocalizations.of(this);
  
  // Helper method to translate a key
  String translate(String key) {
    return AppLocalizations.of(this).translate(key);
  }
  
  // Helper method to check if the current locale is Arabic
  bool get isArabic => AppLocalizations.of(this).locale.languageCode == 'ar';
  
  // Helper method to get the current locale
  Locale get currentLocale => AppLocalizations.of(this).locale;
}