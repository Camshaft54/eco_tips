// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransportTypeAdapter extends TypeAdapter<TransportType> {
  @override
  final int typeId = 2;

  @override
  TransportType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransportType(
      fields[0] as String,
      fields[1] as String,
      fields[2] as double,
    )
      ..commuteDistance = fields[3] as double
      ..isComplete = fields[4] as bool;
  }

  @override
  void write(BinaryWriter writer, TransportType obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.emissionsPerMile)
      ..writeByte(3)
      ..write(obj.commuteDistance)
      ..writeByte(4)
      ..write(obj.isComplete);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransportTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
