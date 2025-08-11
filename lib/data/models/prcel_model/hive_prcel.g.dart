// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_parcel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParcelAdapter extends TypeAdapter<Parcel> {
  @override
  final int typeId = 1;

  @override
  Parcel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Parcel(
      id: fields[0] as String,
      trackingNumber: fields[1] as String,
      status: fields[2] as String,
      shippingDate: fields[3] as DateTime?,
      senderName: fields[4] as String,
      receiverName: fields[5] as String,
      orderName: fields[6] as String,
      longitude: fields[7] as double?,
      latitude: fields[8] as double?,
      receiverPhone: fields[9] as String?,
      destination: fields[10] as String?,
      parceID: fields[11] as int? ?? 0,
      receverName: fields[12] as String? ?? '',
      prWight: fields[13] as double? ?? 0.0,
      noted: fields[14] as String?,
      preType: fields[15] as String? ?? 'standard',
      shipmentID: fields[16] != null ? (fields[16] as int).toString() : null,
    );
  }

  @override
  void write(BinaryWriter writer, Parcel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.trackingNumber)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.shippingDate)
      ..writeByte(4)
      ..write(obj.senderName)
      ..writeByte(5)
      ..write(obj.receiverName)
      ..writeByte(6)
      ..write(obj.orderName)
      ..writeByte(7)
      ..write(obj.longitude)
      ..writeByte(8)
      ..write(obj.latitude)
      ..writeByte(9)
      ..write(obj.receiverPhone)
      ..writeByte(10)
      ..write(obj.destination)
      ..writeByte(11)
      ..write(obj.parceID)
      ..writeByte(12)
      ..write(obj.receverName)
      ..writeByte(13)
      ..write(obj.prWight)
      ..writeByte(14)
      ..write(obj.noted)
      ..writeByte(15)
      ..write(obj.preType)
      ..writeByte(16)
      ..write(obj.shipmentID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParcelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
