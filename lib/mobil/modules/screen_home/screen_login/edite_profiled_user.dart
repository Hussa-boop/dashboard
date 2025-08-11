import 'dart:io';

import 'package:dashboard/dashborder/controller/user_controller.dart';
import 'package:dashboard/data/models/user_model/user_hive.dart';
import 'package:dashboard/mobil/modules/screen_home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final UserHive user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState(user: user);
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _pickedImage;
  final UserHive user;
  _EditProfileScreenState({required this.user});
  
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController passwordController;

  @override
  void initState() {
    final currentUser = Provider.of<UserController>(context, listen: false).currentUser!;
    nameController = TextEditingController(text: currentUser.name);
    emailController = TextEditingController(text: currentUser.email);
    phoneController = TextEditingController(text: currentUser.phoneNumber);
    addressController = TextEditingController(text: currentUser.address);
    passwordController = TextEditingController(text: currentUser.password);
    super.initState();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final userController = Provider.of<UserController>(context, listen: false);
      final currentUser = userController.currentUser!;

      final updatedUser = currentUser.copyWith(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        address: addressController.text.trim(),
        password: passwordController.text.trim(),
        // ملاحظة: صورة الملف الشخصي يتم تحديثها فقط إذا تم اختيار صورة جديدة
        profileImage: _pickedImage?.path ?? currentUser.profileImage,
      );

      await userController.updateUser(currentUser.id, updatedUser);
 await FirebaseAuth.instance.currentUser?.updatePassword(passwordController.text);
      if (mounted) {
        // إغلاق مؤشر التحميل
        Navigator.pop(context);
        
        // عرض رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم تحديث الملف الشخصي بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // العودة إلى صفحة الملف الشخصي
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) =>  HomeLayoutUser()),
          (route) => false,
        );
      }
    } catch (e) {
      // إغلاق مؤشر التحميل
      Navigator.pop(context);
      
      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ حدث خطأ: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserController>(context).currentUser!;
    final image = _pickedImage != null ? FileImage(_pickedImage!) : AssetImage(user.profileImage);

    return Scaffold(
      appBar: AppBar(
        title: const Text("تعديل الملف الشخصي"),
        backgroundColor: Colors.blue.shade800,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) =>  HomeLayoutUser()),
              (route) => false,
            );
          },
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // صورة الملف الشخصي
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
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
                        radius: 60,
                        backgroundImage: image as ImageProvider,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade800,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // بطاقة معلومات الاتصال
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
                        const SizedBox(height: 8),
                        _buildField("الاسم", nameController, Icons.person),
                        const SizedBox(height: 16),
                        _buildField(
                          "البريد الإلكتروني",
                          emailController,
                          Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          "رقم الهاتف",
                          phoneController,
                          Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildField("العنوان", addressController, Icons.location_on),
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
                        const SizedBox(height: 8),
                        _buildField(
                          "كلمة المرور",
                          passwordController,
                          Icons.lock,
                          obscure: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // أزرار الإجراءات
                Row(
                  children: [
                    // زر الإلغاء
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: const Text('إلغاء'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.blue.shade800),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) =>  HomeLayoutUser()),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // زر الحفظ
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("حفظ التعديلات"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _saveProfile,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade800),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? 'يرجى إدخال $label' : null,
    );
  }
}