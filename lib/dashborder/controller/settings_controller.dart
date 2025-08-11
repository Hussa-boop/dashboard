import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:dashboard/data/models/setting_model/settings_model.dart';
import 'package:http/http.dart' as http; // تأكد من استيراد http
class SettingsController extends ChangeNotifier {
  late Box<SettingsModel> _settingsBox;
  SettingsModel _settings = SettingsModel(
    notificationsEnabled: true,
    darkModeEnabled: false,
    selectedLanguage: 'العربية',
    primaryColor: 0xFF2196F3, // اللون الافتراضي
    selectedFont: 'Roboto', // الخط الافتراضي
  );

  SettingsController() {
    _init();
  }


  Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(Uri.parse('http://localhost')).timeout(
        const Duration(seconds: 5),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _init() async {
    _settingsBox = await Hive.openBox<SettingsModel>('settings');
    _loadSettings();
  }

  void _loadSettings() {
    if (_settingsBox.isNotEmpty) {
      _settings = _settingsBox.getAt(0)!;
    } else {
      _settingsBox.add(_settings); // حفظ الإعدادات الافتراضية
    }
    notifyListeners();
  }

  // استرجاع الإعدادات
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get darkModeEnabled => _settings.darkModeEnabled;
  String get selectedLanguage => _settings.selectedLanguage;
  Color get primaryColor => Color(_settings.primaryColor);
  String get selectedFont => _settings.selectedFont;

  // تغيير الإعدادات
  void toggleNotifications(bool value) {
    _settings.notificationsEnabled = value;
    _saveSettings();
  }

  void toggleDarkMode(bool value) {
    _settings.darkModeEnabled = value;
    _saveSettings();
  }

  void changeLanguage(String value) {
    _settings.selectedLanguage = value;
    _saveSettings();
  }

  void updateCustomization(Color color, String font) {
    _settings.primaryColor = color.value;
    _settings.selectedFont = font;
    _saveSettings();
  }

  void _saveSettings() {
    _settingsBox.putAt(0, _settings);
    notifyListeners();
  }
}
