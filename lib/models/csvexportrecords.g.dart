// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csvexportrecords.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CsvExportRecordsAdapter extends TypeAdapter<CsvExportRecords> {
  @override
  final int typeId = 12;

  @override
  CsvExportRecords read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CsvExportRecords(
      uuid: fields[0] as String?,
      exportDate: fields[1] as DateTime,
      fileName: fields[2] as String,
      fileHash: fields[3] as String,
      fileSize: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CsvExportRecords obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.exportDate)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.fileHash)
      ..writeByte(4)
      ..write(obj.fileSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CsvExportRecordsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
