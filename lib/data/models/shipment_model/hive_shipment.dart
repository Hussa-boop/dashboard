import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:dashboard/data/models/prcel_model/hive_parcel.dart';
part 'hive_shipment.g.dart';

@HiveType(typeId: 7) // تأكد من أن typeId فريد
class Shipment extends HiveObject {
  @HiveField(0)
  final int shippingID;

  @HiveField(1)
  final DateTime shippingDate;

  @HiveField(2)
  final DateTime deliveryDate;

  @HiveField(3)
  final String shippingAddress;

  @HiveField(4)
  final List<Parcel> parcels;

  @HiveField(5)
  final int? delegateID;
  
  @HiveField(6)
  final String? supervisorId;

  Shipment({
    required this.shippingID,
    required this.shippingDate,
    required this.deliveryDate,
    required this.shippingAddress,
    required this.parcels,
    this.delegateID,
    this.supervisorId,
  });
// دالة مساعدة لتحويل dynamic إلى int
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'shippingID': shippingID,
      'shippingDate': Timestamp.fromDate(shippingDate),
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'shippingAddress': shippingAddress,
      'parcels': parcels.map((p) => p.toJson()).toList(),
      'delegateID': delegateID,
      'supervisorId': supervisorId,
    };
  }

  factory Shipment.fromJson(Map<String, dynamic> json) {
    try {
      return Shipment(
        shippingID: _parseInt(json['shippingID']),
        shippingDate: json['shippingDate'] is Timestamp
            ? (json['shippingDate'] as Timestamp).toDate()
            : DateTime.tryParse(json['shippingDate']?.toString() ?? '') ??
                DateTime.now(),
        deliveryDate: json['deliveryDate'] is Timestamp
            ? (json['deliveryDate'] as Timestamp).toDate()
            : DateTime.tryParse(json['deliveryDate']?.toString() ?? '') ??
                DateTime.now(),
        shippingAddress: json['shippingAddress']?.toString() ?? '',
        parcels: (json['parcels'] as List? ?? [])
            .map((p) => p is Map<String, dynamic>
                ? Parcel.fromJsonMap(p)
                : Parcel(
                    id: '',
                    trackingNumber: '',
                    status: 'pending',
                    shippingDate: DateTime.now(),
                    senderName: '',
                    receiverName: '',
                    orderName: '',
                    longitude: 0.0,
                    latitude: 0.0,
                    destination: '',
                    parceID: 0,
                    receverName: '',
                    prWight: 0.0,
                    preType: 'standard',
                  ))
            .toList(),
        delegateID:
            json['delegateID'] != null ? _parseInt(json['delegateID']) : null,
        supervisorId: json['supervisorId']?.toString(),
      );
    } catch (e, stackTrace) {
      print('Error parsing Shipment from JSON: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON data: $json');
      throw Exception('Failed to parse shipment data: $e');
    }
  }

  Shipment copyWith({
    String? shippingAddress,
    List<Parcel>? parcels,
    int? delegateID,
    String? supervisorId,
  }) {
    return Shipment(
      shippingID: shippingID,
      shippingDate: shippingDate,
      deliveryDate: deliveryDate,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      parcels: parcels ?? this.parcels,
      delegateID: delegateID ?? this.delegateID,
      supervisorId: supervisorId ?? this.supervisorId,
    );
  }

  // إضافة دالة لإضافة طرد إلى الشحنة
  Shipment addParcel(Parcel parcel) {
    final updatedParcel = Parcel(
      id: parcel.id,
      trackingNumber: parcel.trackingNumber,
      status: parcel.status,
      shippingDate: parcel.shippingDate,
      senderName: parcel.senderName,
      receiverName: parcel.receiverName,
      orderName: parcel.orderName,
      longitude: parcel.longitude,
      latitude: parcel.latitude,
      receiverPhone: parcel.receiverPhone,
      destination: parcel.destination,
      parceID: parcel.parceID,
      receverName: parcel.receverName,
      prWight: parcel.prWight,
      noted: parcel.noted,
      preType: parcel.preType,
      shipmentID: shippingID.toString(), // ربط الطرد بالشحنة الحالية
    );

    final updatedParcels = List<Parcel>.from(parcels)..add(updatedParcel);

    return Shipment(
      shippingID: shippingID,
      shippingDate: shippingDate,
      deliveryDate: deliveryDate,
      shippingAddress: shippingAddress,
      parcels: updatedParcels,
      delegateID: delegateID,
      supervisorId: supervisorId,
    );
  }

  // إضافة دالة لإزالة طرد من الشحنة
  Shipment removeParcel(int parceID) {
    final updatedParcels = parcels.where((p) => p.parceID != parceID).toList();

    return Shipment(
      shippingID: shippingID,
      shippingDate: shippingDate,
      deliveryDate: deliveryDate,
      shippingAddress: shippingAddress,
      parcels: updatedParcels,
      delegateID: delegateID,
      supervisorId: supervisorId,
    );
  }

  // Factory method to create an empty shipment
  factory Shipment.empty() {
    return Shipment(
      shippingID: 0,
      shippingDate: DateTime.now(),
      deliveryDate: DateTime.now(),
      shippingAddress: '',
      parcels: [],
      delegateID: null,
      supervisorId: null,
    );
  }
}