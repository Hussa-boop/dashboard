import 'dart:convert';

import 'package:dashboard/dashborder/controller/user_controller.dart';
import 'package:dashboard/mobil/modules/screen_home/screen_login/login_screen.dart';
import 'package:http/http.dart'as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../dashborder/controller/auth_controller.dart';
import '../../../../../dashborder/home_screen.dart';
import '../../../../../data/models/user_model/user_hive.dart';
import '../../../view_data_shipments/show_massege/class_messag_user.dart';
import '../../home_screen.dart';
import 'state_login_cubit.dart';
import 'package:provider/provider.dart';
class LoginCubit extends Cubit<LoginState> {
  // متغيرات TextEditingController
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailSignController = TextEditingController();
  final TextEditingController passwordSignController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Form Keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  // Focus Nodes
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode emailSignupFocusNode = FocusNode();
  final FocusNode passwordSignupFocusNode = FocusNode();

  // State variables
  bool isLoading = false;

  int selectedIndex = 0;
  String _ipAddress = '';

  LoginCubit() : super(LoginInitial());

  static LoginCubit get(BuildContext context) => BlocProvider.of(context);

  // تغيير تبويب التسجيل/الدخول
  void changeTabIndex(int index) {
    selectedIndex = index;
    emit(LoginChangeTabState());
  }



  User? user;

  //-------------------------------- دوال ارسال واستقبال البيانات الى firestoe------------------------
  //{
  Future<void> linkShipmentsToUser(String userId, String phone) async {
    final firestore = FirebaseFirestore.instance;

    // البحث عن الشحنات المرتبطة برقم الهاتف
    final queryByPhone = await firestore
        .collection('parcel')
        .where('receiverPhone', isEqualTo: phone)
        .get();

    for (var doc in queryByPhone.docs) {
      final data = doc.data();
      final currentUsers = List<String>.from(data['userIds'] ?? []);

      // إذا لم يكن المستخدم مضافًا من قبل، قم بإضافته
      if (!currentUsers.contains(userId)) {
        currentUsers.add(userId);
        await firestore.collection('parcel').doc(doc.id).update({
          'userIds': currentUsers,
        });
      }
    }
  }




  // دالة للحصول على IP حقيقي
  Future<String?> _getIpAddress() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

         _ipAddress=  data['ip'];

      } else {
        _ipAddress = 'Unable to get IP';
      }
    } catch (e) {
      _ipAddress = 'Error: ${e.toString()}';
    }
    return _ipAddress;
  }



  // ---------------------------------------------------------------------------
  // -------------------------------امن ولكن معقد ------------------------------
  Future<void> loginUser(BuildContext context) async {
    if (!loginFormKey.currentState!.validate()) {
      emit(LoginError('الرجاء إدخال بيانات صحيحة'));
      return;
    }

    emit(LoginLoading());
    isLoading = true;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        final userController = Provider.of<UserController>(context, listen: false);
        final authController = Provider.of<AuthController>(context, listen: false);

        await user.reload();

        // 1. تحميل بيانات المستخدم الحالي فقط
        await userController.loadUser(user.uid);



        // 3. ربط الشحنات بالمستخدم
        final phone = userController.currentUser?.phoneNumber ?? '';
        await userController.linkShipmentsToUser(user.uid, phone);

        // 4. تسجيل النشاط
        await authController.login(
          userId: user.uid,
          ipAddress: await _getIpAddress(),
          Name: userController.currentUser?.name ?? user.email ?? "مستخدم",
        );
print(userController.currentUser!.role);
        // 5. التوجيه حسب الدور مع تحسين الأداء
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => (userController.currentUser?.role =='مستخدم') ?HomeLayoutUser():HomePagesDashBoard()),
              (route) => false,
        );

        AppAlerts.showSuccess(context: context, message: "✅ مرحبًا بعودتك!");
        emit(LoginSuccess(user));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _handleFirebaseAuthError(e);
      AppAlerts.showError(context: context, message: errorMessage);
      emit(LoginError(errorMessage));
    } catch (e) {
      AppAlerts.showError(context: context, message: '❌ خطأ غير متوقع: $e');
      emit(LoginError('حدث خطأ غير متوقع'));
    } finally {
      isLoading = false;
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد حساب مرتبط بالبريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'user-disabled':
        return 'هذا الحساب معطل';
      case 'too-many-requests':
        return 'عدد محاولات تسجيل الدخول كثيرة، حاول لاحقاً';
      default:
        return 'يرجى الاتصال بالانترنت';
    }
  }


  Future<void> signUpUser(BuildContext context) async {
    if (!signupFormKey.currentState!.validate()) {
      emit(SignError('الرجاء إدخال بيانات صحيحة'));
      return;
    }

    emit(SignLoading());
    isLoading = true;

    try {
      // 1. إنشاء الحساب في Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailSignController.text.trim(),
        password: passwordSignController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        final userController = Provider.of<UserController>(context, listen: false);
        final authController = Provider.of<AuthController>(context, listen: false);

        // 2. إنشاء كائن المستخدم مع الصلاحيات الأساسية
        final newUser = UserHive(
          id: user.uid,
          name: fullNameController.text.trim(),
          email: emailSignController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          password: passwordSignController.text,
          status: "نشط",
          address: "غير محدد",
          role: "مستخدم", // يتم تعيينه كمستخدم عادي افتراضياً
          registrationDate: DateTime.now().toIso8601String(),
          profileImage: "assets/DeliveryTruckLoading.png",
          permissions: _getDefaultUserPermissions(),
        );
        // 3. إضافة المستخدم الجديد (سيتم حفظه في Firestore و Hive)
        await userController.addUser(newUser);

        // 4. تحميل بيانات المستخدم الحالي فقط
        await userController.loadUser(user.uid);


        // 6. ربط الشحنات
        await linkShipmentsToUser(user.uid, phoneController.text);
        // 5. تسجيل النشاط
        await authController.login(
         userId:  user.uid,
          ipAddress: await _getIpAddress(),
          Name: newUser.name,
        );

        // 6. التوجيه للصفحة الرئيسية
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeLayoutUser()),
              (route) => false,
        );

        emit(SignSuccess(user));
        AppAlerts.showSuccess(context: context, message: "✅ تم إنشاء الحساب بنجاح!");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _handleSignUpError(e);
      emit(SignError(errorMessage));
      AppAlerts.showError(context: context, message: errorMessage);
    } catch (e) {
      AppAlerts.showError(context: context, message: "❌ خطأ غير متوقع: ${e.toString()}");
      emit(SignError("حدث خطأ أثناء التسجيل"));
    } finally {
      isLoading = false;
    }
  }

  Map<String, bool> _getDefaultUserPermissions() {
    return {
      'عرض الإحصائيات': true,
      'إضافة شحنة': true,
      'تعديل شحنة': false, // صلاحيات محدودة للمستخدم العادي
      'حذف شحنة': false,
      'تتبع الشحنة': true,
    };
  }

  String _handleSignUpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة، يجب أن تكون 6 أحرف على الأقل';
      case 'invalid-email':
        return 'بريد إلكتروني غير صالح';
      default:
        return 'حدث خطأ أثناء التسجيل: ${e.message}';
    }
  }



  Future<void> logout(BuildContext context) async {
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final userController = Provider.of<UserController>(context, listen: false);
      final ipAddress = await _getIpAddress();

      // 1. تسجيل نشاط الخروج
      await authController.logout(
        ipAddress: ipAddress,
        Name: userController.currentUser?.name ?? 'Unknown Device',
      );

      // 2. تسجيل الخروج من Firebase
      await FirebaseAuth.instance.signOut();



      // 4. التوجيه لشاشة تسجيل الدخول
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );

      AppAlerts.showSuccess(context: context, message: "تم تسجيل الخروج بنجاح");
    } catch (e) {
      AppAlerts.showError(
        context: context,
        message: 'حدث خطأ أثناء تسجيل الخروج: ${e.toString()}',
      );
      rethrow;
    }
  }
  // إعادة تعيين كلمة المرور عبر البريد الإلكتروني
  Future<void> resetPassword(String email, context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Scaffold.of(context).showBottomSheet((context) => SnackBar(
          content: Text('تم ارسال كلمة المرور الى البريد الإلكتروني')));

      print("✅ تم إرسال رابط إعادة تعيين كلمة المرور إلى البريد الإلكتروني");
    } catch (e) {
      Text('❌ خطأ في إعادة تعيين كلمة المرور:$e');
      rethrow;
    }
  }
  // ------------------------------------------------------------------------

  //-------------------------------الدوال المساعده---------------------------
// للتحقق من صحة البريد الإلكتروني
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

// للتحقق من صحة كلمة المرور
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
    }
    return null;
  }
// للتحقق من صحة كلمة المرور
  String? validateName(String? value) {
    if (value!.isEmpty) {
      return 'الرجاء ادخال الاسم الكامل مع اللقب';
    }
    return null;
  }
  String? validatePhone(String? value) {
    if (value!.isEmpty) {
      return 'ارجاء ادخال رقم الهاتف';
    }
    return null;
  }

  // ------------------------------------------------------------------------------
  bool isPassword = false;


  void togglePasswordVisibility() {
    isPassword = !isPassword;
    emit(LoginTogglePasswordState());
  }


//   -------------------------------------dispose ------
  @override
  Future<void> close() {
    // التخلص من جميع الـ controllers و focus nodes
    emailController.dispose();
    passwordController.dispose();
    emailSignController.dispose();
    passwordSignController.dispose();

    phoneController.dispose();
    addressController.dispose();
    fullNameController.dispose();

    passwordFocusNode.dispose();
    phoneFocusNode.dispose();
    emailSignupFocusNode.dispose();
    passwordSignupFocusNode.dispose();

    print('تم إغلاق LoginCubit وتنظيف الموارد');
    return super.close();
  }
}
