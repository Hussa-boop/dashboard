import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'trak_login_user.g.dart';

@HiveType(typeId: 6)
class LoginLog {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String action; // 'login' أو 'logout'

  @HiveField(4)
  final String? deviceName;

  @HiveField(5)
  final String? ipAddress;

  LoginLog({
    required this.userId,
    required this.timestamp,
    required this.action,
    this.deviceName,
    this.ipAddress,
  });

  String get formattedTime {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
  }

  factory LoginLog.fromFirebase(Map<String, dynamic> data) {
    return LoginLog(
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      action: data['action'] ?? '',
      deviceName: data['deviceName'],
      ipAddress: data['ipAddress'],
    );
  }

  String get actionDescription {
    return action == 'login' ? 'تسجيل دخول' : 'تسجيل خروج';
  }
}