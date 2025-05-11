// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SnagAdapter extends TypeAdapter<Snag> {
  @override
  final int typeId = 2;

  @override
  Snag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Snag(
      uuid: fields[0] as String?,
      id: fields[1] as String?,
      projectId: fields[14] as String?,
      name: fields[2] as String,
      dateCreated: fields[3] as DateTime?,
      status: fields[4] as Status?,
      priority: fields[5] as Priority?,
      description: fields[6] as String?,
      imagePaths: (fields[7] as List?)?.cast<String>(),
      assignee: fields[8] as String?,
      comments: (fields[9] as List?)?.cast<Comment>(),
      finalRemarks: fields[10] as String?,
      location: fields[11] as String?,
      lastModified: fields[12] as DateTime?,
      dateCompleted: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Snag obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(14)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.dateCreated)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.imagePaths)
      ..writeByte(8)
      ..write(obj.assignee)
      ..writeByte(9)
      ..write(obj.comments)
      ..writeByte(10)
      ..write(obj.finalRemarks)
      ..writeByte(11)
      ..write(obj.location)
      ..writeByte(12)
      ..write(obj.lastModified)
      ..writeByte(13)
      ..write(obj.dateCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SnagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
