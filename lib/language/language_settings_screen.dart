import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/language/app_localizations.dart';
import 'package:dashboard/language/app_localizations_context.dart';
import 'package:dashboard/language/language_provider.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('language')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('select_language'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildLanguageOption(
              context,
              title: context.translate('english'),
              languageCode: 'en',
              isSelected: languageProvider.currentLocale.languageCode == 'en',
              onTap: () => _changeLanguage(context, 'en'),
            ),
            const SizedBox(height: 10),
            _buildLanguageOption(
              context,
              title: context.translate('arabic'),
              languageCode: 'ar',
              isSelected: languageProvider.currentLocale.languageCode == 'ar',
              onTap: () => _changeLanguage(context, 'ar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String languageCode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.changeLanguage(languageCode);
    
    // Show a snackbar to confirm the language change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          languageCode == 'ar' 
              ? 'تم تغيير اللغة إلى العربية'
              : 'Language changed to English',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}