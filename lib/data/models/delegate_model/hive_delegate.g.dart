// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_delegate.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DelegateAdapter extends TypeAdapter<Delegate> {
  @override
  final int typeId = 8;

  @override
  Delegate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Delegate(
      delevID: fields[0] as int,
      deveName: fields[1] as String,
      deveAddress: fields[2] as String,
      isActive: fields[3] == null ? true : fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Delegate obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.delevID)
      ..writeByte(1)
      ..write(obj.deveName)
      ..writeByte(2)
      ..write(obj.deveAddress)
      ..writeByte(3)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelegateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
