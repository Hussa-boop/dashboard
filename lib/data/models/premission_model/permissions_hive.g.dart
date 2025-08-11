// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PermissionsHiveAdapter extends TypeAdapter<PermissionsHive> {
  @override
  final int typeId = 3;

  @override
  PermissionsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PermissionsHive(
      role: fields[0] as String,
      permissions: (fields[1] as Map).cast<String, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, PermissionsHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.role)
      ..writeByte(1)
      ..write(obj.permissions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
