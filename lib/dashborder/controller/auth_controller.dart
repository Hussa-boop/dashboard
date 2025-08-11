import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:dashboard/data/models/login_trak_model/trak_login_user.dart';
import '../server/server_login_user.dart';

class AuthController with ChangeNotifier {
  String? _currentUserId;
  DateTime? _lastActivity;
  late Box<String> _authBox;
  late LoginLogService _loginLogService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? get currentUserId => _currentUserId;
  bool get isLoggedIn => _currentUserId != null;

  bool get isUserActive {
    if (_lastActivity == null) return false;
    return DateTime.now().difference(_lastActivity!) < Duration(minutes: 15);
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc =
            await _firestore.collection('active_sessions').doc(user.uid).get();
        if (doc.exists) {
          _currentUserId = user.uid;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }

    _authBox = await Hive.openBox('authBox',
        compactionStrategy: (entries, deletedEntries) =>
            deletedEntries > (entries * 0.2));
    _loginLogService = LoginLogService();
    await _loginLogService.init();
    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _currentUserId = _authBox.get('currentUserId');
    notifyListeners();
  }

  Future<void> login({
    String? userId,
    String? ipAddress,
    String? Name,
  }) async {
    try {
      if (userId == null) {
        throw Exception('User ID is required');
      }

      // 1. تحديث القيمة في Firestore
      await _firestore.collection('active_sessions').doc(userId).set({
        'userId': userId,
        'lastLogin': DateTime.now(),
        'ipAddress': ipAddress,
        'deviceInfo': Name,
      });

      // 2. تحديث القيمة المحلية
      _currentUserId = userId;
      await _authBox.put('currentUserId', userId);
      await _loginLogService.logLogin(
          userId, Name ?? 'Unknown', ipAddress ?? 'Unknown');
      _updateLastActivity();
      notifyListeners();
    } catch (e) {
      print('Error during login: $e');
      _currentUserId = null;
      await _authBox.delete('currentUserId');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout({
    String? ipAddress,
    String? Name,
  }) async {
    try {
      if (_currentUserId != null) {
        await _firestore
            .collection('active_sessions')
            .doc(_currentUserId)
            .delete();
        final FirebaseAuth auth = FirebaseAuth.instance;
        await auth.signOut();
        notifyListeners();
      }
      if (_currentUserId != null) {
        // مسح ذاكرة التخزين المؤقت للصور
        imageCache.clear();
        imageCache.clearLiveImages();
        await _loginLogService.logLogout(
          _currentUserId!,
          Name ?? 'غير معروف', // قيمة افتراضية إذا كانت فارغة
          ipAddress ?? 'غير معروف', // قيمة افتراضية إذا كانت فارغة
        );
        notifyListeners();
      }

      _currentUserId = null;
      await _authBox.delete('currentUserId');
      notifyListeners();
    } catch (e) {
      // يمكن إضافة تسجيل الخطأ هنا
      rethrow;
    }
  }

  void _updateLastActivity() {
    _lastActivity = DateTime.now();
  }

  Future<void> updateLastActivity() async {
    _updateLastActivity();
    // يمكنك هنا إضافة أي منطق إضافي تحتاجه
  }

  Future<List<LoginLog>> getUserLoginHistory(String userId) async {
    try {
      return await _loginLogService.getUserLogs(userId);
    } catch (e) {
      // يمكنك إضافة تسجيل الخطأ هنا
      rethrow;
    }
  }

  Future<List<LoginLog>> getAllLoginHistory() async {
    try {
      return await _loginLogService.getAllLogs();
    } catch (e) {
      // يمكنك إضافة تسجيل الخطأ هنا
      rethrow;
    }
  }

  @override
  void dispose() {
    _authBox.close();
    super.dispose();
  }
}
