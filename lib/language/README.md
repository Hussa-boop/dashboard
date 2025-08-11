# Flutter Localization Implementation

This directory contains the implementation of localization for the Flutter application, supporting both Arabic (ar) and English (en) languages.

## Directory Structure

- `app_ar.json` - Arabic translations
- `app_en.json` - English translations
- `app_localizations.dart` - Main localization class that loads and manages translations
- `app_localizations_context.dart` - Extension methods for easier access to translations
- `language_provider.dart` - ChangeNotifier class to manage language changes
- `language_settings_screen.dart` - UI for changing language settings
- `localization_example_widget.dart` - Example widget demonstrating localization usage

## How to Use

### 1. Access Translations in Widgets

You can access translations in your widgets using the context extension:

```dart
// Using the extension method
Text(context.translate('welcome'));

// Or using the AppLocalizations directly
Text(AppLocalizations.of(context).translate('welcome'));
```

### 2. Change Language

To change the language programmatically:

```dart
final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
languageProvider.changeLanguage('ar'); // Change to Arabic
languageProvider.changeLanguage('en'); // Change to English
```

### 3. Check Current Language

```dart
final languageProvider = Provider.of<LanguageProvider>(context);
bool isArabic = languageProvider.isArabic();

// Or using the context extension
bool isArabic = context.isArabic;
```

### 4. Navigate to Language Settings Screen

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LanguageSettingsScreen(),
  ),
);
```

## Adding New Translations

To add new translations:

1. Add the new key-value pair to both `app_ar.json` and `app_en.json` files
2. Make sure the key is identical in both files
3. Use the key in your widgets with `context.translate('your_key')`

## Testing

Run the localization tests to verify that translations are working correctly:

```bash
flutter test test/localization_test.dart
```