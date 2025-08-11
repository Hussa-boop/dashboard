// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_shipment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShipmentAdapter extends TypeAdapter<Shipment> {
  @override
  final int typeId = 7;

  @override
  Shipment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shipment(
      shippingID: fields[0] as int,
      shippingDate: fields[1] as DateTime,
      deliveryDate: fields[2] as DateTime,
      shippingAddress: fields[3] as String,
      parcels: (fields[4] as List).cast<Parcel>(),
      delegateID: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Shipment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.shippingID)
      ..writeByte(1)
      ..write(obj.shippingDate)
      ..writeByte(2)
      ..write(obj.deliveryDate)
      ..writeByte(3)
      ..write(obj.shippingAddress)
      ..writeByte(4)
      ..write(obj.parcels)
      ..writeByte(5)
      ..write(obj.delegateID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShipmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
