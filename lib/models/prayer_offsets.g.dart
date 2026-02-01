// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_offsets.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerOffsetsAdapter extends TypeAdapter<PrayerOffsets> {
  @override
  final int typeId = 4;

  @override
  PrayerOffsets read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerOffsets(
      fajr: fields[0] as int,
      dhuhr: fields[1] as int,
      asr: fields[2] as int,
      maghrib: fields[3] as int,
      isha: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerOffsets obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.fajr)
      ..writeByte(1)
      ..write(obj.dhuhr)
      ..writeByte(2)
      ..write(obj.asr)
      ..writeByte(3)
      ..write(obj.maghrib)
      ..writeByte(4)
      ..write(obj.isha);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerOffsetsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
