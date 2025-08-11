import 'package:dashboard/data/models/login_trak_model/trak_login_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginLogService extends ChangeNotifier {
  static const String _boxName = 'login_logs';
  late Box<LoginLog> _logsBox;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> init() async {
    await Firebase.initializeApp();
    _logsBox = await Hive.openBox<LoginLog>(_boxName);
  }
  Future<void> logEvent({
    required String userId,
    required String eventType,
    required String details,
    required String ipAddress,
  }) async {
    await _firestore.collection('user_actions').add({
      'userId': userId,
      'timestamp': DateTime.now(),
      'eventType': eventType,
      'details': details,
      'ipAddress': ipAddress,
    });
  }

  Future<void> logError({
    required String userId,
    required String action,
    required String error,
    required String ipAddress,
  }) async {
    await _firestore.collection('errors').add({
      'userId': userId,
      'timestamp': DateTime.now(),
      'action': action,
      'error': error,
      'ipAddress': ipAddress,
    });
  }
  Future<void> logLogin(String userId, String deviceName, String ipAddress) async {
    final log = LoginLog(
      userId: userId,
      timestamp: DateTime.now(),
      action: 'login',
      ipAddress: ipAddress,
      deviceName: deviceName,
    );

    // Save to Hive
    await _logsBox.add(log);

    // Save to Firebase
    await _firestore.collection('login_logs').add({
      'userId': userId,
      'timestamp': DateTime.now(),
      'action': 'login',
      'ipAddress': ipAddress,
      'deviceName': deviceName,
    });
  }

  Future<void> logLogout(String userId, String deviceNames, String ipAddress) async {
    final log = LoginLog(
      userId: userId,
      timestamp: DateTime.now(),
      action: 'logout',
      ipAddress: ipAddress,
      deviceName: deviceNames,
    );

    // Save to Hive
    await _logsBox.add(log);

    // Save to Firebase
    await _firestore.collection('login_logs').add({
      'userId': userId,
      'timestamp': DateTime.now(),
      'action': 'logout',
      'ipAddress': ipAddress,
      'deviceName': deviceNames,
    });
  }

  Future<List<LoginLog>> getUserLogs(String userId, {int? limit}) async {
    // Get from Firebase first
    try {
      QuerySnapshot snapshot = await _firestore.collection('login_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit ?? 100)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => LoginLog.fromFirebase(doc.data() as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error fetching from Firebase: $e');
    }

    // Fallback to Hive if Firebase fails
    var logs = _logsBox.values
        .where((log) => log.userId == userId)
        .toList()
        .reversed
        .toList();

    if (limit != null && logs.length > limit) {
      logs = logs.sublist(0, limit);
    }

    return logs;
  }

  Future<List<LoginLog>> getAllLogs({int? limit}) async {
    // Get from Firebase first
    try {
      QuerySnapshot snapshot = await _firestore.collection('login_logs')
          .orderBy('timestamp', descending: true)
          .limit(limit ?? 100)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => LoginLog.fromFirebase(doc.data() as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error fetching from Firebase: $e');
    }

    // Fallback to Hive if Firebase fails
    var logs = _logsBox.values.toList().reversed.toList();

    if (limit != null && logs.length > limit) {
      logs = logs.sublist(0, limit);
    }

    return logs;
  }
  // ------------------------------------ دوال مراقبة الصلاحيات --------
  Future<void> logPermissionChange({
    required String userId,
    required String role,
    required String permission,
    required bool newValue,
    required String ipAddress,
  }) async {
    final log = {
      'userId': userId,
      'timestamp': DateTime.now(),
      'action': 'permission_change',
      'details': 'تم تغيير صلاحية $permission للدور $role إلى $newValue',
      'role': role,
      'permission': permission,
      'newValue': newValue,
      'ipAddress': ipAddress,
    };

    await _firestore.collection('permission_logs').add(log);
  }

  Future<void> logRoleChange({
    required String userId,
    required String action, // 'add_role' أو 'delete_role'
    required String roleName,
    required String ipAddress,
  }) async {
    final log = {
      'userId': userId,
      'timestamp': DateTime.now(),
      'action': action,
      'details': action == 'add_role'
          ? 'تم إضافة دور جديد: $roleName'
          : 'تم حذف الدور: $roleName',
      'roleName': roleName,
      'ipAddress': ipAddress,
    };

    await _firestore.collection('role_logs').add(log);
  }


  // ------------------------------------------------------------------

}