import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/data/models/user_model/user_hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../controller/user_controller.dart';

class AddEditUser extends StatefulWidget {
  final UserHive? user;
  const AddEditUser({Key? key, this.user}) : super(key: key);

  @override
  _AddEditUserState createState() => _AddEditUserState();
}

class _AddEditUserState extends State<AddEditUser> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedRole = 'مدير'; // قيمة افتراضية
  String _selectedStatus = 'نشط'; // قيمة افتراضية
  File? _pickedImage; // لتخزين الصورة المختارة

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _phoneNumberController.text = widget.user!.phoneNumber;
      _addressController.text = widget.user!.address;
      _passwordController.text = widget.user!.password;
      _selectedRole = widget.user!.role;
      _selectedStatus = widget.user!.status;
    }
  }

  // دالة لاختيار الصورة من الجهاز
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // دالة لحفظ الصورة في التخزين المحلي
  Future<String?> saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final savedImage = await image.copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final theme = Theme.of(context);
    return Directionality(
     textDirection: TextDirection.rtl, child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.user == null ? 'إضافة مستخدم' : 'تعديل مستخدم',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اختيار الصورة
                  Center(
                    child: GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : AssetImage('assets/DeliveryTruckLoading.png')
                                as ImageProvider,
                        backgroundColor: theme.cardTheme.color,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // اسم المستخدم
                  buildTextField(
                    theme: theme,
                    controller: _nameController,
                    labelText: 'الاسم',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال الاسم';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // البريد الإلكتروني
                  buildTextField(
                    theme: theme,
                    controller: _emailController,
                    labelText: 'البريد الإلكتروني',
                    icon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال البريد الإلكتروني';
                      }
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'الرجاء إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // رقم الهاتف
                  buildTextField(
                    theme: theme,
                    controller: _phoneNumberController,
                    labelText: 'رقم الهاتف',
                    icon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم الهاتف';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // كلمة المرور
                  buildTextField(
                    theme: theme,
                    controller: _passwordController,
                    labelText: 'كلمة المرور',
                    icon: Icons.lock,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كلمة المرور';
                      }
                      if (value.length < 8) {
                        return 'كلمة المرور يجب أن تكون على الأقل 8 أحرف';
                      }
                      final passwordRegex =
                          RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
                      if (!passwordRegex.hasMatch(value)) {
                        return 'كلمة المرور يجب أن تحتوي على أحرف وأرقام';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // العنوان
                  buildTextField(
                    theme: theme,
                    controller: _addressController,
                    labelText: 'العنوان',
                    icon: Icons.location_on,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال العنوان';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // الدور
                  buildDropdownField(
                    theme: theme,
                    value: _selectedRole,
                    labelText: 'الدور',
                    items: [
                      {
                        'value': 'مدير',
                        'icon': Icons.admin_panel_settings,
                        'color': Colors.red
                      },
                      {
                        'value': 'مستخدم',
                        'icon': Icons.person,
                        'color': theme.colorScheme.primary
                      },
                      {
                        'value': 'مشرف',
                        'icon': Icons.supervisor_account,
                        'color': Colors.green
                      },
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  // الحالة
                  buildDropdownField(
                    theme: theme,
                    value: _selectedStatus,
                    labelText: 'الحالة',
                    items: [
                      {
                        'value': 'نشط',
                        'icon': Icons.check_circle,
                        'color': Colors.green
                      },
                      {
                        'value': 'غير نشط',
                        'icon': Icons.pause_circle,
                        'color': Colors.orange
                      },
                      {
                        'value': 'محظور',
                        'icon': Icons.block,
                        'color': Colors.red
                      },
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                  SizedBox(height: 24),

                  // زر الإضافة أو التعديل
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final enteredName = _nameController.text.trim();
                          final enteredEmail = _emailController.text.trim();
                          final enteredPassword = _passwordController.text.trim();
                          UserCredential? userCredential;

                          final isEditMode = widget.user != null;
                          final currentUserId = widget.user?.id ?? '';

                          // تحقق من تكرار الاسم أو البريد
                          bool userExists = userController.usersList.any((user) =>
                              (user.name.toLowerCase() ==
                                      enteredName.toLowerCase() ||
                                  user.email.toLowerCase() ==
                                      enteredEmail.toLowerCase()) &&
                              user.id != currentUserId);

                          if (userExists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'المستخدم "$enteredName" أو البريد الإلكتروني "$enteredEmail" موجود مسبقًا!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          String profileImagePath = widget.user?.profileImage ??
                              'assets/DeliveryTruckLoading.png';
                          if (_pickedImage != null) {
                            profileImagePath =
                                (await saveImageLocally(_pickedImage!))!;
                          }

                          // ✅ إذا كنت تضيف مستخدم جديد، سجل في Firebase Auth أولاً
                          String userId;
                          if (!isEditMode) {
                            try {
                              userCredential = await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: enteredEmail,
                                password: enteredPassword,
                              );
                              userId = userCredential.user!.uid;
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('فشل في إنشاء المستخدم: $e'),
                                    backgroundColor: Colors.red),
                              );
                              return;
                            }
                          } else {
                            userId = widget.user!.id;
                          }

                          // ✅ بناء الكائن
                          final user = UserHive(
                            id: userId,
                            name: enteredName,
                            email: enteredEmail,
                            role: _selectedRole,
                            status: _selectedStatus,
                            registrationDate: widget.user?.registrationDate ??
                                DateTime.now().toIso8601String(),
                            phoneNumber: _phoneNumberController.text,
                            address: _addressController.text,
                            profileImage: profileImagePath,
                            permissions: _selectedRole == 'مدير'
                                ? widget.user?.permissions ??
                                    {
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
                                    }
                                : _selectedRole == 'مستخدم'
                                    ? widget.user?.permissions ??
                                        {
                                          'عرض الإحصائيات': true,
                                          'إضافة شحنة': true,
                                          'تعديل شحنة': true,
                                          'حذف شحنة': true,
                                          'تتبع الشحنة': true,
                                        }
                                    : widget.user?.permissions ??
                                        {
                                          'عرض الإحصائيات': true,
                                          'تتبع الشحنة': true,
                                        },
                            password: enteredPassword,
                          );

                          if (isEditMode) {
                            await userController.updateUser(
                                userId, user); // ✅ يشمل FirebaseAuth أيضاً
                          } else {
                            await userController.addUser(user);
                            await userController.loadUser(userId);
                            await userController.linkShipmentsToUser(
                                userId, user.phoneNumber);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'تم ${isEditMode ? "تحديث" : "إضافة"} المستخدم بنجاح!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        widget.user == null ? 'إضافة' : 'تعديل',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> linkShipmentsToUser(
      String userId, String phone, String name) async {
    final firestore = FirebaseFirestore.instance;

    // 1. البحث عن الشحنات التي تحتوي على نفس رقم الهاتف
    final queryByPhone = await firestore
        .collection('shipments')
        .where('receiverPhone', isEqualTo: phone)
        .get();

    for (var doc in queryByPhone.docs) {
      await firestore.collection('shipments').doc(doc.id).update({
        'userId': userId,
      });
    }

    // ✅ اختياري: البحث أيضًا باستخدام الاسم إذا رغبت
    final queryByName = await firestore
        .collection('shipments')
        .where('receiverName', isEqualTo: name)
        .get();

    for (var doc in queryByName.docs) {
      await firestore.collection('shipments').doc(doc.id).update({
        'userId': userId,
      });
    } // ✅ اختياري: البحث أيضًا باستخدام الاسم المرسل إذا رغبت
    final queryByNames = await firestore
        .collection('shipments')
        .where('senderName', isEqualTo: name)
        .get();

    for (var doc in queryByNames.docs) {
      await firestore.collection('shipments').doc(doc.id).update({
        'userId': userId,
      });
    }
  }

  Widget buildTextField({
    required ThemeData theme,
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
        prefixIcon: Icon(icon, color: theme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: theme.cardTheme.color,
      ),
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      validator: validator,
    );
  }

  Widget buildDropdownField({
    required ThemeData theme,
    required String value,
    required String labelText,
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: theme.cardTheme.color,
      ),
      dropdownColor: theme.cardTheme.color,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Row(
            children: [
              Icon(item['icon'], color: item['color']),
              SizedBox(width: 8),
              Text(item['value']),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
  // دالة لبناء قائمة منسدلة
// دالة لبناء قائمة منسدلة محسنة
}

// ------------- زر التعديل او الاضافة ----------
//if (_formKey.currentState!.validate()) {
//   final enteredName = _nameController.text.trim();
//   final enteredEmail = _emailController.text.trim();
//
//   bool userExists = userController.usersList.any((user) =>
//     (user.name.toLowerCase() == enteredName.toLowerCase() ||
//      user.email.toLowerCase() == enteredEmail.toLowerCase()) &&
//      user.id != widget.user?.id
//   );
//
//   if (userExists) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('المستخدم "$enteredName" أو البريد الإلكتروني "$enteredEmail" موجود مسبقًا!'),
//         backgroundColor: Colors.red,
//       ),
//     );
//     return;
//   }
//
//   String profileImagePath = widget.user?.profileImage ?? 'assets/DeliveryTruckLoading.png';
//   if (_pickedImage != null) {
//     profileImagePath = (await _saveImageLocally(_pickedImage!))!;
//   }
//
//   // إنشاء أو تحديث المستخدم
//   if (widget.user == null) {
//     try {
//       // 1. إنشاء حساب في Firebase Authentication
//       UserCredential userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//             email: enteredEmail,
//             password: _passwordController.text,
//           );
//
//       final user = UserHive(
//         id: userCredential.user!.uid, // استخدام uid من Firebase
//         name: enteredName,
//         email: enteredEmail,
//         role: _selectedRole,
//         status: _selectedStatus,
//         registrationDate: DateTime.now().toIso8601String(),
//         phoneNumber: _phoneNumberController.text,
//         address: _addressController.text,
//         profileImage: profileImagePath,
//         permissions: _selectedRole == 'مدير' ? {
//           'إضافة مستخدم': true,
//           'حذف مستخدم': true,
//           'تعديل مستخدم': true,
//           'عرض الإحصائيات': true,
//           'إضافة شحنة': true,
//           'تعديل شحنة': true,
//           'حذف شحنة': true,
//           'تتبع الشحنة': true,
//           'إضافة طلب': true,
//           'تعديل طلب': true,
//           'حذف طلب': true,
//         } : _selectedRole == 'مستخدم' ? {
//           'عرض الإحصائيات': true,
//           'إضافة شحنة': true,
//           'تعديل شحنة': true,
//           'حذف شحنة': true,
//           'تتبع الشحنة': true,
//         } : {
//           'عرض الإحصائيات': true,
//           'تتبع الشحنة': true,
//         },
//         password: _passwordController.text,
//       );
//
//       // 2. حفظ في Firestore و Hive
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.id)
//           .set(user.toJson());
//
//       userController.addUser(user);
//       await userController.loadUser(user.id);
//       await linkShipmentsToUser(user.id, _phoneNumberController.text, enteredName);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('تم إضافة المستخدم بنجاح!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في إنشاء الحساب: ${e.message}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//   } else {
//     // تحديث المستخدم الحالي
//     final user = UserHive(
//       id: widget.user!.id, // استخدام ID الحالي
//       // ... باقي الخصائص مثل الأعلى ...
//     );
//
//     await userController.updateUser(user.id, user);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('تم تحديث المستخدم بنجاح!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
//
//   if (mounted) Navigator.pop(context);
// }