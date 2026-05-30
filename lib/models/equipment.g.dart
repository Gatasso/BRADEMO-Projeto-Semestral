// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EquipmentAdapter extends TypeAdapter<Equipment> {
  @override
  final int typeId = 0;

  @override
  Equipment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Equipment(
      name: fields[0] as String,
      room: fields[1] as String,
      campus: fields[2] as String,
      reportDate: fields[3] as DateTime,
      priority: fields[4] as String,
      reports: fields[5] as int,
      details: fields[6] as String,
      imageUrl: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Equipment obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.room)
      ..writeByte(2)
      ..write(obj.campus)
      ..writeByte(3)
      ..write(obj.reportDate)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.reports)
      ..writeByte(6)
      ..write(obj.details)
      ..writeByte(7)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
