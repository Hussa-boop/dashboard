import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/language/app_localizations_context.dart';
import 'package:dashboard/language/language_provider.dart';
import 'package:dashboard/language/language_settings_screen.dart';

class LocalizationExampleWidget extends StatelessWidget {
  const LocalizationExampleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('app_name')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('welcome'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              context.translate('current_language') + ': ' + 
              (languageProvider.isArabic() 
                ? context.translate('arabic') 
                : context.translate('english')),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 40),
            _buildExampleSection(context, 'login_section', [
              'login',
              'email',
              'password',
              'forgot_password',
              'register',
            ]),
            const SizedBox(height: 20),
            _buildExampleSection(context, 'shipment_section', [
              'shipments',
              'tracking',
              'tracking_number',
              'status',
              'shipping_history',
            ]),
            const SizedBox(height: 20),
            _buildExampleSection(context, 'settings_section', [
              'settings',
              'dark_mode',
              'language',
              'notifications',
              'profile',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleSection(
    BuildContext context, 
    String sectionTitle, 
    List<String> translationKeys,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.translate(sectionTitle),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        ...translationKeys.map((key) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                '$key: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(context.translate(key)),
            ],
          ),
        )),
      ],
    );
  }
}