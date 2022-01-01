// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_survey.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailySurveyAdapter extends TypeAdapter<DailySurvey> {
  @override
  final int typeId = 1;

  @override
  DailySurvey read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailySurvey(
      (fields[0] as Map).cast<String, int>(),
      fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DailySurvey obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.foodTypes)
      ..writeByte(1)
      ..write(obj.emissions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySurveyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
