// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 0;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      uuid: fields[0] as String?,
      id: fields[1] as String?,
      name: fields[2] as String,
      description: fields[3] as String?,
      mainImagePath: fields[4] as String?,
      comments: (fields[5] as List?)?.cast<Comment>(),
      dateCreated: fields[6] as DateTime?,
      dateModified: fields[7] as DateTime?,
      dueDate: fields[19] as DateTime?,
      dateCompleted: fields[8] as DateTime?,
      projectRef: fields[9] as String?,
      client: fields[10] as String?,
      contractor: fields[11] as String?,
      finalRemarks: fields[12] as String?,
      location: fields[13] as String?,
      status: fields[14] as Status?,
      createdCategories: (fields[17] as List?)?.cast<Category>(),
      createdTags: (fields[16] as List?)?.cast<Tag>(),
      snagsCreatedCount: fields[18] as int?,
      pdfExportRecords: (fields[20] as List?)?.cast<PdfExportRecords>(),
      csvExportRecords: (fields[21] as List?)?.cast<CsvExportRecords>(),
      snags: (fields[15] as List?)?.cast<Snag>(),
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.mainImagePath)
      ..writeByte(5)
      ..write(obj.comments)
      ..writeByte(6)
      ..write(obj.dateCreated)
      ..writeByte(7)
      ..write(obj.dateModified)
      ..writeByte(8)
      ..write(obj.dateCompleted)
      ..writeByte(9)
      ..write(obj.projectRef)
      ..writeByte(10)
      ..write(obj.client)
      ..writeByte(11)
      ..write(obj.contractor)
      ..writeByte(12)
      ..write(obj.finalRemarks)
      ..writeByte(13)
      ..write(obj.location)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.snags)
      ..writeByte(16)
      ..write(obj.createdTags)
      ..writeByte(17)
      ..write(obj.createdCategories)
      ..writeByte(18)
      ..write(obj.snagsCreatedCount)
      ..writeByte(19)
      ..write(obj.dueDate)
      ..writeByte(20)
      ..write(obj.pdfExportRecords)
      ..writeByte(21)
      ..write(obj.csvExportRecords);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
