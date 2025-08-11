import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user_hive.g.dart'; // ملف الكود المولد

// تعريف النموذج
@HiveType(typeId: 4) // تأكد من أن typeId فريد
class UserHive {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final String registrationDate; // تخزين التاريخ كنص (ISO8601)

  @HiveField(6)
  final String phoneNumber;

  @HiveField(7)
  final String address;

  @HiveField(8)
  final String profileImage;
  @HiveField(9) // رقم الحقل التالي بعد 8
  final Map<String, bool> permissions;
  @HiveField(10) // رقم الحقل التالي بعد 8
  final String password;

  UserHive({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.registrationDate,
    required this.phoneNumber,
    required this.address,
    this.profileImage = 'assets/DeliveryTruckLoading.png',
    this.permissions = const {}, // الصلاحيات الافتراضية
    required this.password,
  });
// في ملف user_hive.dart
  UserHive copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? status,
    String? registrationDate,
    String? phoneNumber,
    String? address,
    String? profileImage,
    Map<String, bool>? permissions,
    String? password,
  }) {
    return UserHive(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      registrationDate: registrationDate ?? this.registrationDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      permissions: permissions ?? this.permissions,
      password: password ?? this.password,
    );
  }

  // Factory constructor for deserialization
  factory UserHive.fromJson(Map<String, dynamic> json) {
    try {
      // معالجة حقل الصلاحيات بشكل صحيح
      Map<String, bool> permissions = {};

      if (json['permissions'] is String) {
        // إذا كانت الصلاحيات نص JSON
        permissions = Map<String, bool>.from(jsonDecode(json['permissions']));
      } else if (json['permissions'] is Map) {
        // إذا كانت الصلاحيات خريطة مباشرة
        permissions = Map<String, bool>.from(json['permissions']);
      }

      return UserHive(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        registrationDate: json['registrationDate']?.toString() ??
            DateTime.now().toIso8601String(),
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        profileImage: json['profileImage']?.toString() ?? '',
        permissions: permissions,
        password: json['password']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing UserHive from JSON: $e');
      throw Exception('Failed to parse user data');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'registrationDate': registrationDate,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImage': profileImage,
      'permissions': permissions,
      'password': password
    };
  }

  //اكواد خاصه بالفايربيز {
  UserHive CopyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? status,
    String? registrationDate,
    String? phoneNumber,
    String? address,
    String? profileImage,
    Map<String, bool>? permissions,
    String? password,
  }) {
    return UserHive(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      registrationDate: registrationDate ?? this.registrationDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      permissions: permissions ?? this.permissions,
      password: password ?? this.password,
    );
  }

  // تحويل من Firestore document إلى UserHive
  factory UserHive.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // معالجة الصلاحيات
    Map<String, bool> permissions = {};
    if (data['permissions'] is Map) {
      permissions = Map<String, bool>.from(data['permissions']);
    }

    return UserHive(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      status: data['status'] ?? 'active',
      registrationDate: data['registrationDate']?.toString() ??
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ??
          DateTime.now().toIso8601String(),
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      profileImage: data['profileImage'] ?? 'assets/DeliveryTruckLoading.png',
      permissions: permissions,
      password: data['password'] ??
          '', // تحذير: لا تخزن كلمات المرور كنص صريح في الواقع
    );
  }

  // تحويل إلى Map لاستخدامها مع Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'registrationDate': registrationDate,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImage': profileImage,
      'permissions': permissions,
      'updatedAt': FieldValue.serverTimestamp(),
      // لا تخزن كلمة المرور هنا (يتم التعامل معها عبر Firebase Authentication)
    };
  }

  // دالة مساعدة للتحقق من الصلاحية
  bool hasPermission(String permission) {
    return permissions[permission] ?? false;
  }
  //}

  factory UserHive.empty() {
    return UserHive(
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
      profileImage: 'assets/DeliveryTruckLoading.png',
    );
  }
}
