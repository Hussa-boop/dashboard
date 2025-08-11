// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trak_login_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoginLogAdapter extends TypeAdapter<LoginLog> {
  @override
  final int typeId = 6;

  @override
  LoginLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginLog(
      userId: fields[0] as String,
      timestamp: fields[1] as DateTime,
      action: fields[2] as String,
      deviceName: fields[4] as String?,
      ipAddress: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoginLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.action)
      ..writeByte(4)
      ..write(obj.deviceName)
      ..writeByte(5)
      ..write(obj.ipAddress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
