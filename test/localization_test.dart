import 'package:dashboard/language/app_localizations.dart';
import 'package:dashboard/language/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('Localization test - English', (WidgetTester tester) async {
    // Build our app with English locale
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: Builder(
          builder: (context) {
            return MaterialApp(
              locale: const Locale('en'),
              supportedLocales: const [
                Locale('en', ''),
                Locale('ar', ''),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Column(
                      children: [
                        Text(AppLocalizations.of(context).translate('login')),
                        Text(AppLocalizations.of(context).translate('welcome')),
                        Text(AppLocalizations.of(context).translate('settings')),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    // Wait for the localization to load
    await tester.pumpAndSettle();

    // Verify that English translations are displayed
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Localization test - Arabic', (WidgetTester tester) async {
    // Build our app with Arabic locale
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: Builder(
          builder: (context) {
            return MaterialApp(
              locale: const Locale('ar'),
              supportedLocales: const [
                Locale('en', ''),
                Locale('ar', ''),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Column(
                      children: [
                        Text(AppLocalizations.of(context).translate('login')),
                        Text(AppLocalizations.of(context).translate('welcome')),
                        Text(AppLocalizations.of(context).translate('settings')),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    // Wait for the localization to load
    await tester.pumpAndSettle();

    // Verify that Arabic translations are displayed
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('مرحباً بك'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
  });

  testWidgets('Language switching test', (WidgetTester tester) async {
    final languageProvider = LanguageProvider();
    
    // Build our app with English locale initially
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: languageProvider,
        child: Builder(
          builder: (context) {
            return MaterialApp(
              locale: languageProvider.currentLocale,
              supportedLocales: const [
                Locale('en', ''),
                Locale('ar', ''),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Column(
                      children: [
                        Text(AppLocalizations.of(context).translate('login')),
                        ElevatedButton(
                          onPressed: () {
                            languageProvider.changeLanguage('ar');
                          },
                          child: const Text('Switch to Arabic'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    // Wait for the localization to load
    await tester.pumpAndSettle();

    // Verify that English translation is displayed
    expect(find.text('Login'), findsOneWidget);

    // Switch to Arabic
    await tester.tap(find.text('Switch to Arabic'));
    await tester.pumpAndSettle();

    // Verify that Arabic translation is displayed
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });
}