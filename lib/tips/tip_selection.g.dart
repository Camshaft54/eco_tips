// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_selection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TipSelectionAdapter extends TypeAdapter<TipSelection> {
  @override
  final int typeId = 3;

  @override
  TipSelection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TipSelection(
      (fields[0] as List).cast<String>(),
    )..points = fields[1] as int;
  }

  @override
  void write(BinaryWriter writer, TipSelection obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.tips)
      ..writeByte(1)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipSelectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
