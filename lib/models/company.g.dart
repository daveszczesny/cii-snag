// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanyAdapter extends TypeAdapter<Company> {
  @override
  final int typeId = 8;

  @override
  Company read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Company(
      uuid: fields[0] as String?,
      companyName: fields[1] as String,
      companyAddress: fields[2] as String?,
      companyPhone: fields[3] as String?,
      companyEmail: fields[4] as String?,
      companyWebsite: fields[5] as String?,
      companyLogoPath: fields[6] as String?,
      companySlogan: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Company obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.companyName)
      ..writeByte(2)
      ..write(obj.companyAddress)
      ..writeByte(3)
      ..write(obj.companyPhone)
      ..writeByte(4)
      ..write(obj.companyEmail)
      ..writeByte(5)
      ..write(obj.companyWebsite)
      ..writeByte(6)
      ..write(obj.companyLogoPath)
      ..writeByte(7)
      ..write(obj.companySlogan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
