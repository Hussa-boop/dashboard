import 'package:dashboard/dashborder/controller/auth_controller.dart';
import 'package:dashboard/dashborder/controller/settings_controller.dart';
import 'package:dashboard/dashborder/controller/user_controller.dart';
import 'package:dashboard/data/models/user_model/user_hive.dart';
import 'package:dashboard/mobil/modules/screen_home/screen_login/profiled_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Mock classes
class MockUserController extends Mock implements UserController {
  @override
  UserHive? getUserById(String userId) {
    return UserHive(
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
}

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
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  User? get currentUser => MockUser();
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';
}

void main() {
  late MockUserController mockUserController;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockSettingsController mockSettingsController;

  setUp(() {
    mockUserController = MockUserController();
    mockFirebaseAuth = MockFirebaseAuth();
    mockSettingsController = MockSettingsController();
  });

  testWidgets('ProfileScreen displays user information correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<UserController>.value(value: mockUserController),
            ChangeNotifierProvider<SettingsController>.value(value: mockSettingsController),
          ],
          child: const ProfileScreen(),
        ),
      ),
    );

    // Verify that user information is displayed
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('123456789'), findsOneWidget);
    expect(find.text('مستخدم'), findsAtLeastNWidgets(1));
    expect(find.text('نشط'), findsAtLeastNWidgets(1));
    expect(find.text('Test Address'), findsOneWidget);

    // Verify that edit button is present
    expect(find.byIcon(Icons.edit), findsOneWidget);
    
    // Verify that settings button is present
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // Verify that logout button is present
    expect(find.byIcon(Icons.logout), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget);
  });

  // Additional tests can be added here
}
