import 'package:dashboard/dashborder/server/server_scurutiy.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/auth_controller.dart';
import '../controller/premission_controller/permissions_controller.dart';
import '../controller/user_controller.dart';
import 'package:dashboard/data/models/user_model/user_hive.dart';
import 'package:logger/logger.dart';

import '../screen/scurity_screen_admin/list_scurity_screen.dart';
class PermissionsManagement extends StatefulWidget {
  @override
  _PermissionsManagementState createState() => _PermissionsManagementState();
}

class _PermissionsManagementState extends State<PermissionsManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'الكل';
  final Logger _logger = Logger();
  DateTime? _lastUnauthorizedAttempt;
  int _unauthorizedAttempts = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // دالة للتحقق من صلاحية المدير
  bool isAdmin(UserController userController, AuthController authController) {
    if (authController.currentUserId == null) return false;

    final currentUser = userController.getUserById(
        authController.currentUserId!);
    return currentUser?.role == 'مدير';
  }

  // دالة لتسجيل محاولات الوصول غير المصرح بها
  void logUnauthorizedAccess(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final now = DateTime.now();

    _logger.w('Unauthorized access attempt by ${authController.currentUserId}');

    // التحقق من المحاولات المتكررة
    if (_lastUnauthorizedAttempt != null &&
        now.difference(_lastUnauthorizedAttempt!) < Duration(minutes: 5)) {
      _unauthorizedAttempts++;
    } else {
      _unauthorizedAttempts = 1;
    }

    _lastUnauthorizedAttempt = now;

    // إرسال تنبيه إذا تجاوزت المحاولات حد معين
    if (_unauthorizedAttempts >= 3) {
      sendAdminAlert(context);
      _unauthorizedAttempts = 0;
    }
  }

  // دالة لإرسال تنبيه للمسؤول
  void sendAdminAlert(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final userController = Provider.of<UserController>(context, listen: false);

    final user = userController.getUserById(authController.currentUserId ?? '');
    final message = 'محاولات وصول متكررة غير مصرح بها من المستخدم: ${user
        ?.name} (${user?.id})';

    _logger.e('ADMIN ALERT: $message ${user!.name}');

    // هنا يمكنك إضافة كود لإرسال إشعار حقيقي للمسؤول
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'تم إرسال تنبيه للمسؤول عن محاولات الوصول غير المصرح بها'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final authController = Provider.of<AuthController>(context);

    // التحقق من الصلاحيات قبل عرض الشاشة
    if (!isAdmin(userController, authController)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        logUnauthorizedAccess(context);
      });
      return buildUnauthorizedView(context);
    }

    return buildPermissionsManagementView(context);
  }

  // واجهة المستخدم غير المصرح لها
  Widget buildUnauthorizedView(BuildContext context) {
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الصلاحيات'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 60, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'غير مصرح لك بالوصول إلى هذه الصفحة',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'يجب أن تمتلك صلاحية "مدير" للوصول إلى هذه الوظيفة',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // واجهة إدارة الصلاحيات الرئيسية
  Widget buildPermissionsManagementView(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final permissionsController = Provider.of<PermissionsController>(context);

    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الصلاحيات'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade600],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.security),
              tooltip: 'سجل الأمان',
              onPressed: () =>
                  Navigator.push(
                    context,
                      // في ملف التنقل الخاص بك
                      MaterialPageRoute(
                        builder: (context) => MultiProvider(
                          providers: [
                            Provider(create: (_) => LogService()),
                          ],
                          child: const ActivityLogScreen(),
                        ),
                      )
                  ),
            ),
          ],
        ),
        body: Column(
          children: [
            buildAdminWarningBanner(),
            buildFilters(),
            Expanded(
              child: SingleChildScrollView(
                child: buildPermissionsTable(
                    context, userController, permissionsController),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => saveChanges(context),
          child: const Icon(Icons.save),
          backgroundColor: Colors.blue.shade600,
        ),
      ),
    );
  }

  // بانر تحذيري للمديرين
  Widget buildAdminWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.amber.withOpacity(0.2),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
                'أنت تتصفح شاشة الصلاحيات كمدير. أي تغييرات قد تؤثر على أمان النظام.',
                style: TextStyle(color: Colors.amber.shade800)),)
        ],
      ),
    );
  }

  // عرض سجل الأمان
  void showSecurityLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('سجل الأمان'),
            content: SingleChildScrollView(
              child: Text('هنا يمكن عرض سجل محاولات الوصول غير المصرح بها...'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إغلاق'),
              ),
            ],
          ),
    );
  }

  // تأكيد حفظ التغييرات
  Future<void> saveChanges(BuildContext context) async {
    final userController = Provider.of<UserController>(context, listen: false);
    final permissionController = Provider.of<PermissionsController>(
        context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('تأكيد الحفظ'),
            content: Text('هل أنت متأكد من رغبتك في حفظ جميع التغييرات؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('تأكيد'),
              ),
            ],
          ),
    ) ?? false;

    if (confirmed) {
      try {
        permissionController.savePermissionsToHive();
        permissionController.uploadToServer(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الحفظ بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        // تسجيل عملية الحفظ
        _logger.i('Permissions saved by admin');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في الحفظ: $e'),
            backgroundColor: Colors.red,
          ),
        );
        _logger.e('Failed to save permissions: $e');
      }
    }
  }

  /// **بناء عناصر التصفية (حقل البحث + قائمة الحالة)**
  Widget buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'البحث عن مستخدم',
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade800),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {}); // تحديث القائمة عند التغيير
              },
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: _selectedStatus,
            items: ['الكل', 'نشط', 'غير نشط', 'محظور']
                .map((status) =>
                DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  /// **بناء جدول الصلاحيات مع تحسين التنسيق**
  Widget buildPermissionsTable(BuildContext context,
      UserController userController,
      PermissionsController permissionsController) {
    final theme = Theme.of(context);
    final users = userController.usersList;
    final permissions = permissionsController.availablePermissions;

    /// **تصفية المستخدمين بناءً على البحث والحالة المحددة**
    final filteredUsers = users.where((user) {
      bool matchesSearch = user.name.contains(_searchController.text);
      bool matchesStatus = _selectedStatus == 'الكل' || user.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    /// **عرض رسالة في حال عدم وجود نتائج**
    if (filteredUsers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'لا يوجد مستخدمون يطابقون التصفية!',
            style: theme.textTheme.headline6?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    };

    return SizedBox(
      height: 500,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: InteractiveViewer(

          constrained: false,
          scaleEnabled: false,
          panEnabled: true,
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: MaterialStateColor.resolveWith(
                  (states) => theme.colorScheme.primary.withOpacity(0.1),
            ),
            headingTextStyle: theme.textTheme.subtitle1?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            dataRowColor: MaterialStateColor.resolveWith((states) {
              return states.contains(MaterialState.selected)
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : Colors.transparent;
            }),
            border: TableBorder.all(
              color: theme.dividerColor,
              width: 1,
              borderRadius: BorderRadius.circular(4),
            ),
            columns: buildTableColumns(permissions, theme),
            rows: filteredUsers.map((user) => buildUserRow(
              context,
              user,
              permissions,
              userController,
              permissionsController,
              theme,
            )).toList(),
          ),
        ),
      ),
    );
  }
  /// **إنشاء أعمدة الجدول**
  List<DataColumn> buildTableColumns(List<String> permissions,ThemeData theme) {
    return [
      DataColumn(
        label: Text(
          'المستخدم',
          style: theme.textTheme.subtitle1?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'الدور',
          style: theme.textTheme.subtitle1?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      ...permissions.map((p) => DataColumn(
        label: Text(
          p,
          style: theme.textTheme.subtitle1?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      )),
    ];
  }

  /// **إنشاء صف المستخدم في الجدول**
  DataRow buildUserRow(BuildContext context,
      UserHive user,
      List<String> permissions,
      UserController userController,
      PermissionsController permissionsController, ThemeData theme) {
    final roleColor = getRoleColor(user.role, theme);

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>((states) {
        return roleColor.withOpacity(0.1);
      }),
      cells: [
        DataCell(
          Text(
            user.name,
            style: theme.textTheme.bodyText1?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.role,
              style: theme.textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.bold,
                color: getRoleTextColor(user.role, theme),
              ),
            ),
          ),
        ),
        ...permissions.map((permission) => buildPermissionCell(
          context,
          user,
          permission,
          userController,
          permissionsController,
          theme,
        )).toList(),
      ],
    );
  }

  /// **الحصول على لون الدور مع مراعاة الثيم**
  Color getRoleColor(String role, ThemeData theme) {
    switch (role) {
      case 'مدير':
        return theme.colorScheme.primary;
      case 'مشرف':
        return Colors.teal;
      case 'مستخدم':
        return Colors.greenAccent;
      default:
        return theme.colorScheme.secondary;
    }
  }

  /// **الحصول على لون نص الدور**
  Color getRoleTextColor(String role, ThemeData theme) {
    switch (role) {
      case 'مدير':
        return theme.colorScheme.onPrimaryContainer;
      case 'مشرف':
        return Colors.teal.shade800;
      case 'مستخدم':
        return Colors.pink.shade700;
      default:
        return theme.colorScheme.onSecondary;
    }
  }

  /// **إنشاء خلية الصلاحية داخل الصف**
  DataCell buildPermissionCell(BuildContext context,
      UserHive user,
      String permission,
      UserController userController,
      PermissionsController permissionsController,
      ThemeData theme) {
     final hasPermission = user.permissions[permission] ?? false;

    return DataCell(
      Center(
        child: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: hasPermission,
            onChanged: (value) => handlePermissionChange(
              context,
              user,
              permission,
              value ?? false,
              userController,
              permissionsController,
            ),
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return theme.colorScheme.primary;
              }
              return null;
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  /// **معالجة تغيير الصلاحية**
  void handlePermissionChange(
      BuildContext context,
      UserHive user,
      String permission,
      bool value,
      UserController userController,
      PermissionsController permissionsController,
      ) async {
    try {
      updateUserPermission(context,user,permission,value,userController,permissionsController);


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }}

  /// **تحديث صلاحية المستخدم**
  Future<void> updateUserPermission(BuildContext context,
      UserHive user,
      String permission,
      bool newValue,
      UserController userController,
      PermissionsController permissionsController) async {
    try {
      await permissionsController.updatePermission(
          user.role, permission, newValue, context);

      /// **تحديث صلاحيات المستخدم محليًا**
      var updatedPermissions = {...user.permissions, permission: newValue};
      final updatedUser = user.copyWith(permissions: updatedPermissions);
      userController.updateUser(user.id, updatedUser);

      showSnackBar(context, 'تم تحديث صلاحية ${user.name} بنجاح', Colors.green);
    } catch (e) {
      showSnackBar(
          context, 'فشل في تحديث الصلاحية: ${e.toString()}', Colors.red);
    }
  }

  /// **إظهار رسالة إشعار**
  void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }


}