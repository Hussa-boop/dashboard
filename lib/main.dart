import 'package:dashboard/dashborder/controller/auth_controller.dart';
import 'package:dashboard/dashborder/controller/delegate_controller/data_helper.dart';
import 'package:dashboard/dashborder/controller/delegate_controller/delegate_controller.dart';
import 'package:dashboard/dashborder/controller/premission_controller/data_helper_permissions.dart';
import 'package:dashboard/dashborder/controller/data_heper_user.dart';
import 'package:dashboard/dashborder/controller/settings_controller.dart';
import 'package:dashboard/dashborder/controller/shipment_controller/data_init_shipment.dart';
import 'package:dashboard/dashborder/controller/shipment_controller/shipments_controller.dart';
import 'package:dashboard/dashborder/mangment/employee/screen.dart';
import 'package:dashboard/data/models/shipment_model/hive_shipment.dart';
import 'package:dashboard/data/models/user_model/user_hive.dart';
import 'package:dashboard/dashborder/server/server_login_user.dart';
import 'package:dashboard/data/models/delegate_model/hive_delegate.dart';
import 'package:dashboard/data/models/login_trak_model/trak_login_user.dart';
import 'package:dashboard/data/models/premission_model/permissions_hive.dart';
import 'package:dashboard/firebase_options.dart';
import 'package:dashboard/mobil/modules/screen_home/home_screen.dart';
import 'package:dashboard/mobil/modules/screen_home/screen_login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/dashborder/controller/parcel_controller/data_haper_shipment.dart';
import 'dashborder/controller/filter_controller.dart';
import 'dashborder/controller/menu_controller.dart';
import 'dashborder/controller/premission_controller/permissions_controller.dart';
import 'dashborder/controller/search_controller.dart';
import 'dashborder/controller/parcel_controller/parcel_controller.dart';
import 'dashborder/controller/user_controller.dart';
import 'dashborder/home_screen.dart';
import 'data/models/prcel_model/hive_parcel.dart';
import 'package:dashboard/data/models/setting_model/settings_model.dart';
import 'dashborder/modules/theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mobil/modules/view_data_shipments/show_massege/class_messag_user.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // تسجيل المحولات
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ParcelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(SettingsModelAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(PermissionsHiveAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(UserHiveAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(LoginLogAdapter());
  }
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(ShipmentAdapter());
  }  if (!Hive.isAdapterRegistered(8)) {
    Hive.registerAdapter(DelegateAdapter());
  }

  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تهيئة المساعدين
  final databaseHelperUser = DatabaseHelperUser();
  final databaseHelperPermissions = DatabaseHelperPrmissions();
  final databaseHelperShipment = DatabaseHelperShipment();
  final databaseHelperParcel = DatabaseHelperParcel();
  final databaseHelperDelegate = DatabaseHelperDelegate();

  // تهيئة المتحكمات
  final authController = AuthController();
  final userController = UserController(databaseHelperUser);
  final permissionsController =
      PermissionsController(databaseHelperPermissions);
  final parcelController = ParcelController(databaseHelperParcel);
  final shipmentController = ShipmentController(databaseHelperShipment);

  // ربط المتحكمات
  userController.setAuthController(authController);

  // تهيئة المتحكمات
  await authController.init();
  await userController.init();
  await databaseHelperPermissions.init();
  await databaseHelperParcel.init();
  await databaseHelperShipment.init();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authController),
        ChangeNotifierProvider(create: (_) => userController),
        ChangeNotifierProvider(create: (_) => permissionsController),
        ChangeNotifierProvider(create: (_) => parcelController),
        ChangeNotifierProvider(create: (_) => shipmentController),
        ChangeNotifierProvider(
            create: (_) => ThemeProvider()..setInitialTheme(isDarkMode)),
        ChangeNotifierProvider(create: (_) => MenusController()),
        ChangeNotifierProvider(create: (_) => Search_Controller()),
        ChangeNotifierProvider(create: (_) => FilterController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => LoginLogService()),
        ChangeNotifierProvider(create: (_) => DelegateController(databaseHelperDelegate)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final userController = Provider.of<UserController>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    // ✅ جلب بيانات المستخدم الحالي
    final currentUser = authController.currentUserId != null
        ? userController.getUserById(authController.currentUserId!)
        : null;
    return MaterialApp(

      navigatorKey: AppAlerts.navigatorKey,
      theme: themeProvider.currentTheme,
      debugShowCheckedModeBanner: false,
      home:
      authController.currentUserId == null
          ? LoginScreen()
          : currentUser?.role == 'مستخدم'
              ? HomeLayoutUser():
        const HomePagesDashBoard(),
    );
  }
}
