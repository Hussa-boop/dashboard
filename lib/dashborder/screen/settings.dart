import 'package:dashboard/visitor_screen/custmur.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/auth_controller.dart';
import '../controller/settings_controller.dart';
import '../controller/parcel_controller/parcel_controller.dart';
import '../controller/user_controller.dart';
import '../mangment/permissions_management.dart';
import '../modules/theme.dart';
import 'list_login_user.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsController = Provider.of<SettingsController>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final authController = Provider.of<AuthController>(context);
    final userController = Provider.of<UserController>(context);
    final shipmentController =
        Provider.of<ParcelController>(context, listen: false);
    // ✅ جلب بيانات المستخدم الحالي
    final currentUser = authController.currentUserId != null
        ? userController.getUserById(authController.currentUserId!)
        : null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('عام'),
                    _buildSettingCard(
                      children: [
                        _buildSettingItem(
                          icon: Icons.notifications,
                          title: 'تفعيل الإشعارات',
                          trailing: Switch(
                            value: settingsController.notificationsEnabled,
                            onChanged: (value) {
                              settingsController.toggleNotifications(value);
                            },
                            activeColor: Colors.blue,
                          ),
                        ),
                        const Divider(),
                        _buildSettingItem(
                          icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          title: 'الوضع الليلي',
                          trailing: Switch(
                            value: settingsController.darkModeEnabled,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                              settingsController.toggleDarkMode(value);
                            },
                            activeColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('اللغة'),
                    _buildSettingCard(
                      children: [
                        _buildSettingItem(
                          icon: Icons.language,
                          title: 'اختر اللغة',
                          trailing: DropdownButton<String>(
                            value: settingsController.selectedLanguage,
                            items: ['العربية', 'English'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                settingsController.changeLanguage(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('إدارة الأدوار والصلاحيات'),
                    _buildSettingCard(
                      children: [
                        _buildSettingItem(
                          icon: Icons.people,
                          title: 'إدارة الأدوار',
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            onPressed: () {
                              if (currentUser?.role == "مدير") {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => UsersManagement(),
                                //     ));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('❌ ليس لديك الصلاحية '),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }

                              // الانتقال إلى صفحة إدارة الأدوار
                            },
                          ),
                        ),
                        const Divider(),
                        _buildSettingItem(
                          icon: Icons.security,
                          title: 'إدارة الصلاحيات',
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            onPressed: () {
                              if (currentUser?.role == "مدير") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PermissionsManagement(),
                                    ));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('❌ ليس لديك الصلاحية '),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              // الانتقال إلى صفحة إدارة الصلاحيات
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('إعدادات الأمان'),
                    _buildSettingCard(
                      children: [
                        _buildSettingItem(
                          icon: Icons.lock,
                          title: 'سجل الدخول والخروج',
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            onPressed: () {
                              if (currentUser?.role == "مدير") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LoginHistoryScreen(),
                                    ));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('❌ ليس لديك الصلاحية '),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              // الانتقال إلى صفحة تغيير كلمة المرور
                            },
                          ),
                        ),
                        const Divider(),
                        _buildSettingItem(
                          icon: Icons.verified_user,
                          title: 'تفعيل المصادقة الثنائية',
                          trailing: Switch(
                            value: false, // يمكن ربطه بالـ Controller
                            onChanged: (value) {
                              // تفعيل أو تعطيل المصادقة الثنائية
                            },
                            activeColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('إعدادات الفواتير والدفع'),
                    _buildSettingCard(
                      children: [
                        _buildSettingItem(
                          icon: Icons.payment,
                          title: 'إدارة طرق الدفع',
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            onPressed: () {
                              // الانتقال إلى صفحة إدارة طرق الدفع
                            },
                          ),
                        ),
                        const Divider(),
                        _buildSettingItem(
                          icon: Icons.receipt,
                          title: 'إشعارات الفواتير',
                          trailing: Switch(
                            value: true, // يمكن ربطه بالـ Controller
                            onChanged: (value) {
                              // تفعيل أو تعطيل إشعارات الفواتير
                            },
                            activeColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('إعدادات النظام العام'),
                    _buildSettingCard(
                      children: [
                        _buildSettingItem(
                          icon: Icons.settings,
                          title: 'تخصيص النظام',
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdvancedHomeScreen(),
                                  ));
                              // الانتقال إلى صفحة تخصيص النظام
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('إعدادات قاعدة البيانات'),
                    _buildSettingCard(
                      children: [
                        _buildSettingItem(
                          icon: Icons.sync,
                          title: 'مزامنة البيانات',
                          trailing: ElevatedButton.icon(
                            onPressed: () async {
                              _syncData(
                                  context, userController, shipmentController);
                            },
                            icon: const Icon(Icons.sync, color: Colors.white),
                            label: const Text('مزامنة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم حفظ الإعدادات بنجاح'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue.shade600,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'حفظ التغييرات',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]))),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade800,
      ),
    );
  }

  Widget _buildSettingCard({required List<Widget> children}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade600),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
    );
  }

  // 🔹 دالة مزامنة البيانات عند الضغط على الزر
  Future<void> _syncData(BuildContext context, UserController userController,
      ParcelController shipmentController) async {
    final messenger = ScaffoldMessenger.of(context);
    final id = userController.usersListFire;
    messenger.showSnackBar(const SnackBar(
      content: Text('جارٍ مزامنة البيانات...'),
      backgroundColor: Colors.blue,
    ));
    shipmentController.parcel.map(((e) {}));
    try {
      // 1️⃣ جلب البيانات من الخادم إلى Hive
      await userController.fetchUsersFromServer();
      await shipmentController.fetchParcelsFromFirestore();
      // 2️⃣ تحديث البيانات في Firestore و Hive
      for (var shipment in shipmentController.parcel) {
        await shipmentController.updateParcelInFirestore(shipment.id, shipment);
      }
      // 2️⃣ إرسال البيانات من Hive إلى MySQL
      await userController.updateUser(id.id, id);

      messenger.showSnackBar(const SnackBar(
        content: Text('✅ تمت مزامنة البيانات بنجاح!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print(e);
      messenger.showSnackBar(SnackBar(
        content: Text('❌ فشل في المزامنة: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
