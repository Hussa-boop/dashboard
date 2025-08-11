import 'package:dashboard/dashborder/controller/user_controller.dart';
import 'package:dashboard/data/models/user_model/user_hive.dart';
import 'package:hive/hive.dart';



class DatabaseHelperUser {
  static final DatabaseHelperUser _instance = DatabaseHelperUser._internal();
  Box<UserHive>? _usersBox;

  factory DatabaseHelperUser() {
    return _instance ;
  }

  DatabaseHelperUser._internal();

  Future<void> init() async {
    _usersBox = await Hive.openBox<UserHive>('usersBox');
    await addDefaultUser();UserController(DatabaseHelperUser._instance).fetchUsersFromServer();
  }

  Box<UserHive> get userBox {
    if (_usersBox == null) {
      throw Exception('User box is not initialized');
    }
    return _usersBox!;
  }

  List<UserHive> getShipments() {
    return _usersBox?.values.toList() ?? [];
  }
  List<UserHive> usersList = [];
  /// ✅ **إضافة مستخدم افتراضي إذا لم يكن هناك مستخدمون**
  Future<void> addDefaultUser() async {
    if (_usersBox!.isEmpty) {
      final defaultUser = UserHive(
        id: '1',
        name: 'admin',
        email: 'admin.com',
        role: 'مدير',
        status: 'نشط',
        registrationDate: DateTime.now().toIso8601String(),
        phoneNumber: '123456789',
        address: 'المكتب الرئيسي',
        permissions: {
          'إضافة مستخدم': true,
          'حذف مستخدم': true,
          'تعديل مستخدم': true,
          'عرض الإحصائيات': true,
          'إضافة شحنة': true,
          'تعديل شحنة': true,
          'حذف شحنة': true,
          'تتبع الشحنة': true,
          'إضافة طلب': true,
          'تعديل طلب': true,
          'حذف طلب': true,
        },
        password: '12345',
      );

      await _usersBox!.put(defaultUser.id, defaultUser);
    }
  }


}