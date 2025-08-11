import 'package:hive/hive.dart';

part 'permissions_hive.g.dart'; // ملف الكود المولد

// تعريف النموذج
@HiveType(typeId:3) // تأكد من أن typeId فريد
class PermissionsHive {
  @HiveField(0)
  late String role;

  @HiveField(1)
  late Map<String, bool> permissions;

  // Constructor
  PermissionsHive({
    required this.role,
    required this.permissions,
  });

  // Factory constructor for deserialization
  // دالة لتحويل من Map إلى PermissionsHive
  factory PermissionsHive.fromJson(Map<String, dynamic> json) {
    return PermissionsHive(
      role: json['role']?.toString() ?? '',
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'permissions': permissions,
    };
  }

  PermissionsHive copyWith({
    String? role,
    Map<String, bool>? permissions,
  }) {
    return PermissionsHive(
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
    );
  }
}