import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/language/app_localizations_context.dart';
import 'package:dashboard/language/language_provider.dart';
import 'package:dashboard/language/language_settings_screen.dart';

/// This file demonstrates how to integrate localization into an existing screen
/// 
/// Steps to integrate localization into an existing screen:
/// 1. Import the necessary files
/// 2. Replace hardcoded strings with context.translate('key')
/// 3. Add a language selector if needed

class LocalizationIntegrationExample extends StatelessWidget {
  const LocalizationIntegrationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example of how to access the language provider
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      // Use translation for app bar title
      appBar: AppBar(
        title: Text(context.translate('settings')),
        // Add language selector in the app bar
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
            tooltip: context.translate('language'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Example of a settings section with translations
          _buildSettingsSection(
            context,
            title: context.translate('account_settings'),
            icon: Icons.person,
            onTap: () {
              // Handle tap
            },
          ),
          
          _buildSettingsSection(
            context,
            title: context.translate('notification_settings'),
            icon: Icons.notifications,
            onTap: () {
              // Handle tap
            },
          ),
          
          _buildSettingsSection(
            context,
            title: context.translate('security'),
            icon: Icons.security,
            onTap: () {
              // Handle tap
            },
          ),
          
          // Example of a switch with translation
          SwitchListTile(
            title: Text(context.translate('dark_mode')),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              // Handle theme change
            },
          ),
          
          // Example of a language selector
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.translate('language')),
            subtitle: Text(
              languageProvider.isArabic() 
                  ? context.translate('arabic') 
                  : context.translate('english')
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSettingsScreen(),
                ),
              );
            },
          ),
          
          // Example of a button with translation
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Show a dialog with translated content
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(context.translate('confirm_logout')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.translate('cancel')),
                      ),
                      TextButton(
                        onPressed: () {
                          // Handle logout
                          Navigator.pop(context);
                        },
                        child: Text(context.translate('logout')),
                      ),
                    ],
                  ),
                );
              },
              child: Text(context.translate('logout')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}