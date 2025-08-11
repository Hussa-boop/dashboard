import 'package:dashboard/dashborder/controller/settings_controller.dart';
import 'package:dashboard/dashborder/controller/user_controller.dart';
import 'package:dashboard/data/models/user_model/user_hive.dart';
import 'package:dashboard/mobil/modules/screen_home/screen_login/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Mock classes
class MockSettingsController extends Mock implements SettingsController {
  @override
  bool get notificationsEnabled => true;

  @override
  bool get darkModeEnabled => false;

  @override
  String get selectedLanguage => 'العربية';

  @override
  Color get primaryColor => Colors.blue.shade800;

  @override
  String get selectedFont => 'Roboto';

  @override
  void toggleNotifications(bool value) {}

  @override
  void toggleDarkMode(bool value) {}

  @override
  void changeLanguage(String value) {}

  @override
  void updateCustomization(Color color, String font) {}

  @override
  Future<bool> checkServerConnection() async => true;
}

class MockUserController extends Mock implements UserController {
  @override
  UserHive? get currentUser => UserHive(
        id: 'test-user-id',
        name: 'Test User',
        email: 'test@example.com',
        role: 'مستخدم',
        status: 'نشط',
        registrationDate: DateTime.now().toIso8601String(),
        phoneNumber: '123456789',
        address: 'Test Address',
        permissions: {'view': true},
        password: 'password',
        profileImage: 'assets/DeliveryTruckLoading.png',
      );
}

void main() {
  late MockSettingsController mockSettingsController;
  late MockUserController mockUserController;

  setUp(() {
    mockSettingsController = MockSettingsController();
    mockUserController = MockUserController();
  });

  testWidgets('SettingsScreen displays all settings options correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsController>.value(value: mockSettingsController),
            ChangeNotifierProvider<UserController>.value(value: mockUserController),
          ],
          child: const SettingsScreen(),
        ),
      ),
    );

    // Verify that the settings screen title is displayed
    expect(find.text('إعدادات المستخدم'), findsOneWidget);

    // Verify that theme settings are displayed
    expect(find.text('المظهر والسمات'), findsOneWidget);
    expect(find.text('الوضع الداكن'), findsOneWidget);
    expect(find.text('اللون الرئيسي'), findsOneWidget);
    expect(find.text('نوع الخط'), findsOneWidget);

    // Verify that language and notification settings are displayed
    expect(find.text('اللغة والإشعارات'), findsOneWidget);
    expect(find.text('الإشعارات'), findsOneWidget);
    expect(find.text('اللغة'), findsOneWidget);

    // Verify that app info is displayed
    expect(find.text('معلومات التطبيق'), findsOneWidget);
    expect(find.text('إصدار التطبيق'), findsOneWidget);
    expect(find.text('آخر تحديث'), findsOneWidget);
    expect(find.text('التحقق من التحديثات'), findsOneWidget);

    // Verify that save button is displayed
    expect(find.text('حفظ الإعدادات'), findsOneWidget);

    // Verify that switches are displayed
    expect(find.byType(Switch), findsAtLeast(2));

    // Verify that dropdowns are displayed
    expect(find.byType(DropdownButtonFormField<String>), findsAtLeast(2));
  });

  // Additional tests can be added here
}