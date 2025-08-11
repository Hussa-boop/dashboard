import 'package:dashboard/dashborder/controller/auth_controller.dart';
import 'package:dashboard/data/models/user_model/user_hive.dart';
import 'package:dashboard/mobil/modules/screen_home/screen_login/edite_profiled_user.dart';
import 'package:dashboard/mobil/modules/screen_home/screen_login/login_screen.dart';
import 'package:dashboard/mobil/shard/network/firebase/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../dashborder/controller/user_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    // ✅ جلب المعرف من FirebaseAuth
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 70, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                "⚠️ لم يتم العثور على مستخدم مسجل الدخول",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ تحميل المستخدم من قائمة المستخدمين
    final user = userController.getUserById(userId);

    if (user == null || user.id.isEmpty) {
      return const Scaffold(

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري تحميل بيانات المستخدم...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(

      body: Directionality(
        textDirection:  TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  // صورة المستخدم مع تأثير ظل
                  Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(user.profileImage),
                  ),
                ),
                  Spacer(),
                  // اسم المستخدم بخط كبير
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // بطاقة معلومات المستخدم
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معلومات الاتصال',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRowWithIcon(Icons.email, 'البريد الإلكتروني', user.email),
                      _buildInfoRowWithIcon(Icons.phone, 'رقم الهاتف', user.phoneNumber),
                      _buildInfoRowWithIcon(Icons.location_on, 'العنوان', user.address),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // بطاقة معلومات الحساب
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معلومات الحساب',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRowWithIcon(Icons.badge, 'الدور', user.role),
                      _buildInfoRowWithIcon(
                        Icons.circle,
                        'الحالة',
                        user.status,
                        valueColor: user.status == 'نشط' ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // زر تسجيل الخروج
              Row(
                children: [
                  // زر تسجيل الخروج
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async => await _showLogoutConfirmation(context),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('تسجيل الخروج', style: TextStyle(fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // زر تعديل الملف الشخصي
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async => await _showEditProfileConfirmation(context,user),
                      icon: const Icon(Icons.edit, size: 20),
                      label: const Text('تعديل الملف', style: TextStyle(fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueGrey[700],
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
// دالة تأكيد تسجيل الخروج
  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthController>(context, listen: false).logout();
              AuthService().logoutUser(context);
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[700],
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      await AuthController().logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
    }
  }

// دالة تأكيد تعديل الملف
  Future<void> _showEditProfileConfirmation(BuildContext context,UserHive user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الملف', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('سيتم نقلك إلى صفحة التعديل، هل تريد المتابعة؟'),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[700],
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
  // صف معلومات مع أيقونة
  Widget _buildInfoRowWithIcon(IconData icon, String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blue.shade800),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  // الصف القديم للمعلومات (محتفظ به للتوافق)
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}



