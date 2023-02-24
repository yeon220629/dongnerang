// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space.model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpaceAdapter extends TypeAdapter<Space> {
  @override
  final int typeId = 0;

  @override
  Space read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Space(
      uid: fields[0] as String,
      gu: fields[1] as String?,
      spaceName: fields[2] as String,
      spaceImage: fields[3] as String?,
      address: fields[4] as String?,
      category: fields[5] as String?,
      latitude: fields[6] as double,
      longitude: fields[7] as double,
      detailInfo: fields[8] as String?,
      pageLink: fields[9] as String?,
      phoneNum: fields[10] as String?,
      svcName: fields[12] as String?,
      svcStat: fields[13] as String?,
      svcTimeMin: fields[14] as String?,
      svcTimeMax: fields[15] as String?,
      payInfo: fields[16] as String?,
      useTarget: fields[17] as String?,
      updated: fields[18] as String?,
    )..dist = fields[11] as double?;
  }

  @override
  void write(BinaryWriter writer, Space obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.gu)
      ..writeByte(2)
      ..write(obj.spaceName)
      ..writeByte(3)
      ..write(obj.spaceImage)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.latitude)
      ..writeByte(7)
      ..write(obj.longitude)
      ..writeByte(8)
      ..write(obj.detailInfo)
      ..writeByte(9)
      ..write(obj.pageLink)
      ..writeByte(10)
      ..write(obj.phoneNum)
      ..writeByte(11)
      ..write(obj.dist)
      ..writeByte(12)
      ..write(obj.svcName)
      ..writeByte(13)
      ..write(obj.svcStat)
      ..writeByte(14)
      ..write(obj.svcTimeMin)
      ..writeByte(15)
      ..write(obj.svcTimeMax)
      ..writeByte(16)
      ..write(obj.payInfo)
      ..writeByte(17)
      ..write(obj.useTarget)
      ..writeByte(18)
      ..write(obj.updated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
