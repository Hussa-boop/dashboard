import 'package:dashboard/mobil/modules/screen_home/screen_login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تسجيل مستخدم جديد
  Future<User?> registerUser(String email, String password, String name, String phone, String role, String address) async {
    try {
      // التحقق مما إذا كان البريد الإلكتروني موجودًا
      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        throw FirebaseAuthException(
          code: "email-already-in-use",
          message: "البريد الإلكتروني مستخدم بالفعل. قم بتسجيل الدخول.",
        );
      }
      // 1. إنشاء حساب المستخدم في Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String userId = userCredential.user!.uid;

      // 2. حفظ بيانات المستخدم في Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'id': userId,
        'name': name,
        'email': email,
        'phoneNumber': phone,
        'role': 'مستخدم',
        'status': 'نشط',
        'profileImage':'assets/DeliveryTruckLoading.png',
        'permissions':{'تتبع الشحنة':
        true,


          'إضافة طلب': true,
          'تعديل طلب': true,
          'حذف طلب': true,},
        'registrationDate': DateTime.now().toIso8601String(),
      });

      // 3. ربط الشحنات بهذا المستخدم حسب رقم الهاتف أو الاسم
      await linkShipmentsToUser(userId, phone, name);

      return null;
    } catch (e) {
      print("❌ خطأ في التسجيل: $e");
      throw e;
    }
  }

  Future<void> linkShipmentsToUser(String userId, String phone, String name) async {
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
    }
  }




  // تسجيل الدخول
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      print(' ${userCredential.user}');
      return userCredential.user;

    } catch (e) {
      print("❌ خطأ في تسجيل الدخول: $e");
      return null;
    }
  }

  // تسجيل الخروج
  Future<void> logoutUser(context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }




}
