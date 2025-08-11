import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 2)
class SettingsModel extends HiveObject {
  @HiveField(0)
  bool notificationsEnabled;

  @HiveField(1)
  bool darkModeEnabled;

  @HiveField(2)
  String selectedLanguage;

  @HiveField(3)
  int primaryColor; // لون النظام الأساسي (يتم تخزينه كقيمة عددية)

  @HiveField(4)
  String selectedFont; // نوع الخط المختار

  SettingsModel({
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.selectedLanguage,
    this.primaryColor = 0xFF2196F3, // اللون الافتراضي (أزرق)
    this.selectedFont = 'Roboto', // الخط الافتراضي
  });
}
