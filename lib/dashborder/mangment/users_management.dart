import 'dart:async';
import 'dart:convert';

import 'package:dashboard/dashborder/server/server_login_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/auth_controller.dart';
import '../controller/user_controller.dart';
import '../controller/search_controller.dart';
import '../controller/filter_controller.dart';
import '../home_screen.dart';
import 'package:dashboard/data/models/user_model/user_hive.dart';
import '../modules/add_edit_user.dart'; // استيراد النموذج الجديد
import 'package:http/http.dart'as http;

import '../modules/theme.dart';
class UsersManagement extends StatelessWidget {
  final Widget child;
  UsersManagement({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final searchController = Provider.of<Search_Controller>(context);
    final filterController = Provider.of<FilterController>(context);
    final ScrollController _controller1 = ScrollController();
    final ScrollController _controller2 = ScrollController();
    // تصفية المستخدمين بناءً على نص البحث والمعايير المحددة
    final filteredUsers = userController.users.where((user) {
      final query = searchController.searchQuery.toLowerCase();
      final matchesSearch = user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
      final matchesRole = filterController.selectedRole == 'الكل' ||
          user.role == filterController.selectedRole;
      final matchesStatus = filterController.selectedStatus == 'الكل' ||
          user.status == filterController.selectedStatus;
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();

    return Scaffold(
      endDrawer: (ResponsiveWidget.isSmallScreen(context)||ResponsiveWidget.isMediumScreen(context)) ? child: null,

      appBar: AppBar(
        title: const Text(
          'إدارة المستخدمين',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
     leading:   IconButton(
       icon: Icon(Icons.sync),
       tooltip: 'مزامنة بيانات',
       onPressed: () async {
         await userController.fetchUsersFromServer(); // جلب البيانات من MySQL وتحديث Hive
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('✅ تم تحديث الشحنات بنجاح!'), backgroundColor: Colors.green),
         );
       },
     ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // حقل البحث
              buildSearchField(searchController),

              const SizedBox(height: 16),

              // فلاتر الأدوار والحالة
              Row(
                children: [
                  Expanded(
                    child: buildDropdownField(
                      value: filterController.selectedRole,
                      items: ['الكل', 'مدير', 'مستخدم', 'مشرف'],
                      onChanged: (value) {
                        filterController.setSelectedRole(value!);
                      },
                      hint: 'الدور',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildDropdownField(
                      value: filterController.selectedStatus,
                      items: ['الكل', 'نشط', 'غير نشط', 'محظور'],
                      onChanged: (value) {
                        filterController.setSelectedStatus(value!);
                      },
                      hint: 'الحالة',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // قائمة المستخدمين
              Expanded(
                child: ListView.builder(

                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return buildUserCard(user, userController, context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'adduser1',
        onPressed: ()async {
          final userController =
              Provider.of<UserController>(context, listen: false);
          final authController =
              Provider.of<AuthController>(context, listen: false);

          final currentUser = userController.usersList.firstWhere(
            (user) => user.id == authController.currentUserId,
            // 🔹 جلب المستخدم النشط
            orElse: () => UserHive(
                id: '',
                name: '',
                email: '',
                role: '',
                status: '',
                registrationDate: '',
                phoneNumber: '',
                address: '',
                permissions: {}, password: ''),
          );

          if (currentUser.permissions['إضافة مستخدم'] == true) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditUser()),
            );
            // 2️⃣ إرسال البيانات من Hive إلى MySQL



          } else {
            ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
                content: Text('❌ ليس لديك صلاحية لإضافة مستخدم جديد'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue.shade800,
      ),
    );
  }

  Timer? _debounce;

  void onSearchChanged(String query, Search_Controller searchController) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchController.setSearchQuery(query);
    });
  }

  // دالة لبناء حقل البحث
  Widget buildSearchField(Search_Controller searchController) {
    return TextFormField(

      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Colors.black),
        labelText: 'ابحث عن مستخدم...',
        prefixIcon: Icon(Icons.search, color: Colors.blue.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      onChanged: (value) => onSearchChanged(value, searchController),
    );
  }

  // دالة لبناء القائمة المنسدلة
  Widget buildDropdownField({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.transparent,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // دالة لبناء بطاقة المستخدم

  Widget buildUserCard(UserHive user, UserController userController, BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = themeProvider.currentTheme;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => showUserDetailsModal(context, user, themeProvider),
            splashColor: theme.colorScheme.primary.withOpacity(0.1),
            highlightColor: theme.colorScheme.primary.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة المستخدم
                  buildUserAvatar(user, theme),
                  const SizedBox(width: 16),

                  // معلومات المستخدم
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الاسم والدور
                        buildUserHeader(user, theme),
                        const SizedBox(height: 12),

                        // معلومات الاتصال
                        buildContactInfo(user, theme),
                        const SizedBox(height: 12),

                        // الحالة والصلاحيات
                        buildStatusAndPermissions(user, theme),
                      ],
                    ),
                  ),

                  // أزرار الإجراءات
                  buildActionButtons(user, context, theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildUserAvatar(UserHive user, ThemeData theme) {
    return Stack(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: theme.cardColor,
              child: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(user.profileImage),
                backgroundColor: theme.scaffoldBackgroundColor,
              ),
            ),
          ),
        ),
        if (user.status == 'نشط')
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.cardColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildUserHeader(UserHive user, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: theme.textTheme.headline6?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            user.role,
            style: theme.textTheme.caption?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildContactInfo(UserHive user, ThemeData theme) {
    return Column(
      children: [
        buildInfoRow(
          icon: Icons.email_outlined,
          value: user.email,
          theme: theme,
        ),
        const SizedBox(height: 6),
        buildInfoRow(
          icon: Icons.phone_outlined,
          value: user.phoneNumber,
          theme: theme,
        ),
        const SizedBox(height: 6),
        buildInfoRow(
          icon: Icons.location_on_outlined,
          value: user.address,
          theme: theme,
        ),
      ],
    );
  }

  Widget buildInfoRow({required IconData icon, required String value, required ThemeData theme}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.textTheme.caption?.color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyText2?.copyWith(
              color: theme.textTheme.caption?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget buildStatusAndPermissions(UserHive user, ThemeData theme) {
    final statusColor = user.status == 'نشط' ? Colors.green : Colors.orange;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 10, color: statusColor),
              const SizedBox(width: 6),
              Text(
                user.status,
                style: theme.textTheme.caption?.copyWith(
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),

        if (user.permissions.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 12,
                    color: theme.colorScheme.secondary),
                const SizedBox(width: 6),
                Text(
                  '${user.permissions.length} صلاحيات',
                  style: theme.textTheme.caption?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildActionButtons(UserHive user, BuildContext context, ThemeData theme) {
    return Column(
      children: [
        IconButton(
          icon: Icon(Icons.edit_outlined),
          tooltip: 'تعديل',
          color: theme.colorScheme.primary,
          onPressed: () async {
            final userController = Provider.of<UserController>(context, listen: false);
            final authController = Provider.of<AuthController>(context, listen: false);
            final logService = Provider.of<LoginLogService>(context, listen: false);

            try {
              final currentUser = userController.usersList.firstWhere(
                    (user) => user.id == authController.currentUserId,
                orElse: () => UserHive(
                  id: '',
                  name: '',
                  email: '',
                  role: '',
                  status: '',
                  registrationDate: '',
                  phoneNumber: '',
                  address: '',
                  permissions: {},
                  password: '',
                ),
              );

              if (currentUser.permissions['تعديل مستخدم'] == true) {
                // تسجيل حدث محاولة التعديل
                await logService.logEvent(
                  userId: authController.currentUserId ?? 'unknown',
                  eventType: 'user_edit_attempt',
                  details: 'محاولة تعديل مستخدم: ${user.id}',
                  ipAddress: await getIpAddress(),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditUser(user: user),
                  ),
                );
              } else {
                // تسجيل حدث محاولة تعديل بدون صلاحية
                await logService.logEvent(
                  userId: authController.currentUserId ?? 'unknown',
                  eventType: 'unauthorized_edit_attempt',
                  details: 'محاولة تعديل مستخدم بدون صلاحية: ${user.id}',
                  ipAddress: await getIpAddress(),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ ليس لديك صلاحية لتعديل مستخدم'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              // تسجيل الخطأ
              await logService.logError(
                userId: authController.currentUserId ?? 'unknown',
                action: 'user_edit',
                error: e.toString(),
                ipAddress: await getIpAddress(),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ حدث خطأ: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        IconButton(

          icon:Icon( Icons.delete_outline),
          tooltip: 'حذف',

          color: Colors.red,
          onPressed: () async {
            final userController = Provider.of<UserController>(context, listen: false);
            final authController = Provider.of<AuthController>(context, listen: false);
            final logService = Provider.of<LoginLogService>(context, listen: false);

            try {
              final currentUser = userController.usersList.firstWhere(
                    (user) => user.id == authController.currentUserId,
                orElse: () => UserHive(
                  id: '',
                  name: '',
                  email: '',
                  role: '',
                  status: '',
                  registrationDate: '',
                  phoneNumber: '',
                  address: '',
                  permissions: {},
                  password: '',
                ),
              );

              showDeleteConfirmationDialog(
                context,
                'تأكيد الحذف',
                'هل أنت متأكد من أنك تريد حذف هذا المستخدم؟',
                    () async {
                  if (currentUser.permissions['حذف مستخدم'] == true) {
                    if (user.id.isNotEmpty) {
                      try {
                        // تسجيل حدث بدء الحذف
                        await logService.logEvent(
                          userId: authController.currentUserId ?? 'system',
                          eventType: 'user_delete_start',
                          details: 'بدء عملية حذف المستخدم: ${user.id}',
                          ipAddress:await  getIpAddress(),
                        );
                        // await userController.deleteWithReauth(user.password);
                        await userController.deleteUser(user.id);



                        // تسجيل نجاح الحذف
                        await logService.logEvent(
                          userId: authController.currentUserId ?? 'system',
                          eventType: 'user_delete_success',
                          details: 'تم حذف المستخدم: ${user.id}',
                          ipAddress: await getIpAddress(),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ تم حذف المستخدم بنجاح'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        // تسجيل فشل الحذف
                        await logService.logError(
                          userId: authController.currentUserId ?? 'system',
                          action: 'user_delete',
                          error: e.toString(),
                          ipAddress: await getIpAddress(),
                        );

                        print("❌ خطأ أثناء حذف المستخدم: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ حدث خطأ أثناء الحذف: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('⚠️ المستخدم غير موجود!'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } else {
                    // تسجيل محاولة حذف بدون صلاحية
                    await logService.logEvent(
                      userId: authController.currentUserId ?? 'unknown',
                      eventType: 'unauthorized_delete_attempt',
                      details: 'محاولة حذف مستخدم بدون صلاحية: ${user.id}',
                      ipAddress: await getIpAddress(),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ ليس لديك صلاحية لحذف مستخدم'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                'حذف',
              );
            } catch (e) {
              await logService.logError(
                userId: authController.currentUserId ?? 'unknown',
                action: 'user_delete_init',
                error: e.toString(),
                ipAddress: await getIpAddress(),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ حدث خطأ: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Future<String> getIpAddress() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'].toString();
      }
      return 'Unknown IP';
    } catch (e) {
      return 'IP Error: ${e.toString()}';
    }
  }
  void showDeleteConfirmationDialog(BuildContext context, String title,
      String content, void Function()? onPressed, String contentText) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق النافذة
              },
              child:
                  Text('إلغاء', style: TextStyle(color: Colors.blue.shade800)),
            ),
            TextButton(
              onPressed: onPressed,
              child: Text(contentText, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  //-------------------------------------عرض التفاصيل عند النقر على بطاقة المستخدم-------

  void showUserDetailsModal(BuildContext context, UserHive user, ThemeProvider themeProvider) {
    final theme = themeProvider.currentTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // User Header
                buildModalHeader(user, theme),
                const SizedBox(height: 24),

                // User Details Grid
                GridView.count(

                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    buildDetailItem(
                      icon: Icons.email_outlined,
                      title: 'البريد الإلكتروني',
                      value: user.email,
                      theme: theme,
                    ),
                    buildDetailItem(
                      icon: Icons.phone_outlined,
                      title: 'رقم الهاتف',
                      value: user.phoneNumber,
                      theme: theme,
                    ),
                    buildDetailItem(
                      icon: Icons.person_outline,
                      title: 'الدور',
                      value: user.role,
                      theme: theme,
                    ),
                    buildDetailItem(
                      icon: Icons.calendar_today_outlined,
                      title: 'تاريخ التسجيل',
                      value: user.registrationDate,
                      theme: theme,
                    ),
                    buildDetailItem(
                      icon: Icons.location_on_outlined,
                      title: 'العنوان',
                      value: user.address,
                      theme: theme,
                    ),
                    buildDetailItem(
                      icon: Icons.lock_outline,
                      title: 'الحالة',
                      value: user.status,
                      theme: theme,
                      valueColor: user.status == 'نشط' ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Permissions Section
                if (user.permissions.isNotEmpty) ...[
                  buildSectionTitle('الصلاحيات', theme),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.permissions.entries
                        .where((e) => e.value == true)
                        .map((e) => buildPermissionChip(e.key, theme))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: theme.dividerColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text('إغلاق', style: theme.textTheme.button),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async{
                          Navigator.pop(context);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditUser(user: user),
                            ),
                          );

                          if (result == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم تحديث بيانات المستخدم بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: Text('تعديل', style: theme.textTheme.button?.copyWith(
                            color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildModalHeader(UserHive user, ThemeData theme) {
    return Row(
      children: [
        buildUserAvatar(user, theme,),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: theme.textTheme.headline6),
              const SizedBox(height: 4),
              Text(user.role, style: theme.textTheme.subtitle2?.copyWith(
                color: theme.textTheme.caption?.color,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSectionTitle(String title, ThemeData theme) {
    return Row(
      children: [
        Container(
          height: 16,
          width: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.subtitle1?.copyWith(
          fontWeight: FontWeight.w600,
        )),
      ],
    );
  }

  Widget buildPermissionChip(String permission, ThemeData theme) {
    return Chip(
      label: Text(permission, style: theme.textTheme.caption),
      backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.caption),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: theme.textTheme.caption?.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value, style: theme.textTheme.bodyText2?.copyWith(
                color: valueColor ?? theme.textTheme.headline6?.color,
              )),
            ),
          ],
        ),
      ],
    );
  }
}
