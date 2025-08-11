import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/dashborder/controller/premission_controller/data_helper_permissions.dart';
import 'package:dashboard/dashborder/server/server_login_user.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:dashboard/data/models/premission_model/permissions_hive.dart';
import '../auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart'as http;
class PermissionsController with ChangeNotifier {
  final DatabaseHelperPrmissions _databaseHelper;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // قائمة الصلاحيات المتاحة
   List<String> availablePermissions = [
    'إضافة مستخدم',
    'حذف مستخدم',
    'تعديل مستخدم',
    'عرض الإحصائيات',
    'إضافة شحنة',
    'تعديل شحنة',
    'حذف شحنة',
    'تتبع الشحنة',
    'إضافة طلب',
    'تعديل طلب',
    'حذف طلب',
  ];

  late Box<PermissionsHive> _permissionsBox;
  List<PermissionsHive> _rolesPermissions = [];

  List<PermissionsHive> get rolesPermissions => _rolesPermissions;

  PermissionsController(this._databaseHelper) {
    _init();
  }

  Future<void> _init() async {
    await _openHiveBox();
    await _loadPermissionsFromHive();
    await _initializeDefaultRoles();
  }

  Future<void> _openHiveBox() async {
    _permissionsBox = await Hive.openBox<PermissionsHive>('permissionsBox');
  }

  Future<void> _loadPermissionsFromHive() async {
    try {


      _rolesPermissions = _permissionsBox.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading permissions: $e');
      await _permissionsBox.clear();
      _rolesPermissions = [];
    }
  }

  Future<void> _initializeDefaultRoles() async {
    if (_rolesPermissions.isEmpty) {
      final defaultRoles = [
        PermissionsHive(
          role: 'مدير',
          permissions: {for (var p in availablePermissions) p: true},
        ),
        PermissionsHive(
          role: 'مشرف',
          permissions: {
            'إضافة مستخدم': true,
            'تعديل مستخدم': true,
            'عرض الإحصائيات': true,
            'إضافة شحنة': true,
            'تعديل شحنة': true,
            'تتبع الشحنة': true,
            'إضافة طلب': true,
            'تعديل طلب': true,
          },
        ),
        PermissionsHive(
          role: 'مستخدم',
          permissions: {'تتبع الشحنة': true},
        ),
      ];

      await _permissionsBox.addAll(defaultRoles);
      _rolesPermissions = defaultRoles;
      notifyListeners();
    }
  }

  Future<void> savePermissionsToHive() async {
    try {
      await _permissionsBox.clear();
      for (var role in _rolesPermissions) {
        await _permissionsBox.put(role.role, role);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving permissions: $e');
    }
  }





  Map<String, bool>? getPermissionsForRole(String role) {
    try {
      return _rolesPermissions.firstWhere(
            (r) => r.role == role,
        orElse: () => PermissionsHive(role: '', permissions: {}),
      ).permissions;
    } catch (e) {
      debugPrint('Error getting permissions for role: $e');
      return {};
    }
  }

  Future<void> syncWithServer() async {
    try {
      final serverData = await _databaseHelper.fetchPermissions();
      _rolesPermissions = serverData;
      await savePermissionsToHive();
      notifyListeners();
    } catch (e) {
      debugPrint('فشل المزامنة مع الخادم: $e');
      rethrow;
    }
  }


  Future<void> uploadToServer(context) async {
    try {
      await _databaseHelper.uploadPermissions(_rolesPermissions,context);
    } catch (e) {
      showDialog(
        context: context,
        barrierDismissible: false, // يمنع إغلاق النافذة بالنقر خارجها
        builder: (context) {
          return AlertDialog(
            title: const Text("فشل رفع بيانات الصلاحيات للخادم: "),
            content: const Text("فشل  . يرجى التحقق من ان الخادم قيد التشغيل والمحاولة مرة أخرى."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("موافق"),
              ),
            ],
          );
        },
      );
      debugPrint('فشل رفع البيانات للخادم: $e');
      rethrow;
    }
  }
  Future<void> updatePermission(
      String role,
      String permissionName,
      bool value,
      BuildContext context,
      ) async {
    final index = _rolesPermissions.indexWhere((r) => r.role == role);
    final authController = Provider.of<AuthController>(context, listen: false);
    final logService = Provider.of<LoginLogService>(context, listen: false);
    final ipAddress = await _getIpAddress();

    try {
      if (index >= 0) {
        _rolesPermissions[index] = _rolesPermissions[index].copyWith(
          permissions: {
            ..._rolesPermissions[index].permissions,
            permissionName: value
          },
        );

        await savePermissionsToHive();

        // تسجيل الحدث في Firebase
        await logService.logPermissionChange(
          userId: authController.currentUserId ?? 'مستخدم',
          role: role,
          permission: permissionName,
          newValue: value,
          ipAddress: ipAddress ?? 'Unknown IP',
        );

        notifyListeners();
      } else {
        throw Exception('الدور غير موجود');
      }
    } catch (e) {
      // تسجيل الخطأ في Firebase
      await logService.logError(
        userId: authController.currentUserId ?? 'system',
        action: 'update_permission',
        error: e.toString(),
        ipAddress: ipAddress ?? 'Unknown IP',
      );
      rethrow;
    }
  }

  Future<void> addNewRole(String roleName, BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final logService = Provider.of<LoginLogService>(context, listen: false);
    final ipAddress = await _getIpAddress();

    if (_rolesPermissions.any((r) => r.role == roleName)) {
      throw Exception('الدور موجود بالفعل');
    }

    try {
      final newRole = PermissionsHive(
        role: roleName,
        permissions: {for (var p in availablePermissions) p: false},
      );

      _rolesPermissions.add(newRole);
      await savePermissionsToHive();

      // تسجيل الحدث في Firebase
      await logService.logRoleChange(
        userId: authController.currentUserId ?? 'system',
        action: 'add_role',
        roleName: roleName,
        ipAddress: ipAddress ?? 'Unknown IP',
      );

      notifyListeners();
    } catch (e) {
      await logService.logError(
        userId: authController.currentUserId ?? 'system',
        action: 'add_role',
        error: e.toString(),
        ipAddress: ipAddress ?? 'Unknown IP',
      );
      rethrow;
    }
  }

  Future<void> deleteRole(String roleName, BuildContext context) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final logService = Provider.of<LoginLogService>(context, listen: false);
    final ipAddress = await _getIpAddress();

    if (roleName == 'مدير') {
      throw Exception('لا يمكن حذف دور المدير');
    }

    try {
      _rolesPermissions.removeWhere((r) => r.role == roleName);
      await savePermissionsToHive();

      // تسجيل الحدث في Firebase
      await logService.logRoleChange(
        userId: authController.currentUserId ?? 'system',
        action: 'delete_role',
        roleName: roleName,
        ipAddress: ipAddress ?? 'Unknown IP',
      );

      notifyListeners();
    } catch (e) {
      await logService.logError(
        userId: authController.currentUserId ?? 'system',
        action: 'delete_role',
        error: e.toString(),
        ipAddress: ipAddress ?? 'Unknown IP',
      );
      rethrow;
    }
  }

  Future<String?> _getIpAddress() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}