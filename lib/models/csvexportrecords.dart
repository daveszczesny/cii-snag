
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'csvexportrecords.g.dart';

@HiveType(typeId: 12)
class CsvExportRecords extends HiveObject {
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final DateTime exportDate;

  @HiveField(2)
  final String fileName;

  @HiveField(3)
  final String fileHash;

  @HiveField(4)
  final int fileSize;

  CsvExportRecords({
    String? uuid,
    required this.exportDate,
    required this.fileName,
    required this.fileHash,
    required this.fileSize,
  }) : uuid = uuid ?? const Uuid().v4();
}