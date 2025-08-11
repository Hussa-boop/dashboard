import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
part 'hive_prcel.g.dart'; // سيتم إنشاؤه بواسطة Hive

@HiveType(typeId: 1) // typeId يجب أن يكون فريدًا
class Parcel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String trackingNumber;

  @HiveField(2)
  final String status;

  @HiveField(3)
  final DateTime? shippingDate;
  @HiveField(4)
  final String senderName; // ✅ اسم المرسل

  @HiveField(5)
  final String receiverName; // ✅ اسم المستلم

  @HiveField(6)
  final String orderName; // ✅ اسم الطلب
  @HiveField(7)
  final double? longitude; // ✅ اسم الطلب
  @HiveField(8)
  final double? latitude; // ✅ اسم الطلب
  @HiveField(9)
  final String? receiverPhone; // ✅
  @HiveField(10)
  final String? destination; // ✅ اسم الطلب

  // الحقول الجديدة المطلوبة
  @HiveField(11)
  final int parceID; // ✅ معرف الطرد (Primary Key)

  @HiveField(12)
  final String receverName; // ✅ اسم المستلم

  @HiveField(13)
  final double prWight; // ✅ الوزن المسبق

  @HiveField(14)
  final String? noted; // ✅ ملاحظات المرسل (اختياري)

  @HiveField(15)
  final String preType; // ✅ نوع الطرد

  @HiveField(16)
  final String? shipmentID; // ✅ معرف الشحنة المرتبطة

  Parcel({
    required this.id,
    required this.trackingNumber,
    required this.status,
    this.shippingDate,
    required this.senderName,
    required this.receiverName,
    required this.orderName,
    this.longitude,
    this.latitude,
    this.receiverPhone,
    this.destination,
    required this.parceID,
    required this.receverName,
    required this.prWight,
    this.noted,
    required this.preType,
    this.shipmentID,
  });

  // Add copyWith method
  Parcel copyWith({
    String? id,
    String? trackingNumber,
    String? status,
    DateTime? shippingDate,
    String? senderName,
    String? receiverName,
    String? orderName,
    double? longitude,
    double? latitude,
    String? receiverPhone,
    String? destination,
    int? parceID,
    String? receverName,
    double? prWight,
    String? noted,
    String? preType,
    String? shipmentID,
  }) {
    return Parcel(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      status: status ?? this.status,
      shippingDate: shippingDate ?? this.shippingDate,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,
      orderName: orderName ?? this.orderName,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      destination: destination ?? this.destination,
      parceID: parceID ?? this.parceID,
      receverName: receverName ?? this.receverName,
      prWight: prWight ?? this.prWight,
      noted: noted ?? this.noted,
      preType: preType ?? this.preType,
      shipmentID: shipmentID ?? this.shipmentID,
    );
  }

  factory Parcel.fromJson(DocumentSnapshot doc) {
    Map json = doc.data() as Map<String, dynamic>;
    return Parcel(
      id: doc.id, // استخدام معرف المستند بدلاً من الحقل إن أمكن
      trackingNumber: json['trackingNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      senderName: json['senderName']?.toString() ?? '',
      receiverName: json['receiverName']?.toString() ?? '',
      orderName: json['orderName']?.toString() ?? '',
      shippingDate: _parseTimestamp(json['shippingDate'] ?? json['registrationDate']),
      longitude: _parseDouble(json['longitude']),
      latitude: _parseDouble(json['latitude']),
      receiverPhone: json['receiverPhone']?.toString(),
      destination: json['destination']?.toString(),
      parceID: _parseInt(json['parceID']),
      receverName: json['receverName']?.toString() ?? '',
      prWight: _parseDouble(json['prWight']) ?? 0.0,
      noted: json['noted']?.toString(),
      preType: json['preType']?.toString() ?? 'standard',
      shipmentID: json['shipmentID']?.toString(),
    );
  }

// دالة مساعدة لتحويل Timestamp
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) return DateTime.tryParse(timestamp);
    return null;
  }

// دوال مساعدة للتحويل الآمن لأنواع البيانات
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // إضافة دالة fromJson للتعامل مع Map مباشرة (مطلوب للربط مع Shipment)
  factory Parcel.fromJsonMap(Map<String, dynamic> json) {
    return Parcel(
      id: json['id'] ?? '',
      trackingNumber: json['trackingNumber'] ?? '',
      status: json['status'] ?? '',
      senderName: json['senderName'] ?? '',
      receiverName: json['receiverName'] ?? '',
      orderName: json['orderName'] ?? '',
      shippingDate: json['shippingDate'] != null
          ? DateTime.tryParse(json['shippingDate'])
          : null,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      receiverPhone: json['receiverPhone'],
      destination: json['destination'] ?? '',
      parceID: json['parceID'] ?? 0,
      receverName: json['receverName'] ?? '',
      prWight: (json['prWight'] as num?)?.toDouble() ?? 0.0,
      noted: json['noted'],
      preType: json['preType'] ?? '',
      shipmentID: json['shipmentID'],
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'trackingNumber': trackingNumber,
  //     'status': status,
  //     'shippingDate': shippingDate != null ? Timestamp.fromDate(shippingDate!) : null,
  //     'senderName': senderName,
  //     'receiverName': receiverName,
  //     'orderName': orderName,
  //     'longitude': longitude,
  //     'latitude': latitude,
  //     'receiverPhone': receiverPhone,
  //     'destination': destination,
  //     'parceID': parceID,
  //     'receverName': receverName,
  //     'prWight': prWight,
  //     'noted': noted,
  //     'preType': preType,
  //     'shipmentID': shipmentID,
  //   };
  // }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingNumber': trackingNumber,
      'status': status,
      'shippingDate': shippingDate?.toIso8601String(), // ✅ هذا هو التعديل
      'senderName': senderName,
      'receiverName': receiverName,
      'orderName': orderName,
      'longitude': longitude,
      'latitude': latitude,
      'receiverPhone': receiverPhone,
      'destination': destination,
      'parceID': parceID,
      'receverName': receverName,
      'prWight': prWight,
      'noted': noted,
      'preType': preType,
      'shipmentID': shipmentID,
    };
  }

  String get formattedDate {
    if (shippingDate == null) return 'غير محدد';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = shippingDate!;
    final shipmentDay = DateTime(date.year, date.month, date.day);

    if (shipmentDay == today) {
      return 'اليوم ${DateFormat('h:mm a').format(date)}';
    } else if (shipmentDay == today.subtract(const Duration(days: 1))) {
      return 'أمس ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('yyyy/MM/dd - hh:mm a').format(date);
    }
  }

}
