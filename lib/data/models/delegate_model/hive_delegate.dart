import 'package:hive/hive.dart';

part 'hive_delegate.g.dart';

@HiveType(typeId: 8)
class Delegate extends HiveObject {
  @HiveField(0)
  final int delevID;

  @HiveField(1)
  final String deveName;

  @HiveField(2)
  final String deveAddress;

  @HiveField(3, defaultValue: true)
  final bool isActive;

  Delegate({
    required this.delevID,
    required this.deveName,
    required this.deveAddress,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'delevID': delevID,
      'deveName': deveName,
      'deveAddress': deveAddress,
      'isActive': isActive,
    };
  }

  factory Delegate.fromJson(Map<String, dynamic> json) {
    return Delegate(
      delevID: json['delevID'] != null
          ? (json['delevID'] is int
              ? json['delevID']
              : int.parse(json['delevID'].toString()))
          : DateTime.now().millisecondsSinceEpoch,
      deveName: json['deveName'] ?? '',
      deveAddress: json['deveAddress'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}
