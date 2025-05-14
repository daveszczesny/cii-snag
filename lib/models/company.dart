

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'company.g.dart';

@HiveType(typeId: 8)
class Company extends HiveObject {
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  String companyName;

  @HiveField(2)
  String? companyAddress;

  @HiveField(3)
  String? companyPhone;

  @HiveField(4)
  String? companyEmail;

  @HiveField(5)
  String? companyWebsite;

  @HiveField(6)
  String? companyLogoPath;

  @HiveField(7)
  String? companySlogan;

  Company({
    String? uuid,
    required this.companyName,
    this.companyAddress,
    this.companyPhone,
    this.companyEmail,
    this.companyWebsite,
    this.companyLogoPath,
    this.companySlogan,
  }) : uuid = uuid ?? const Uuid().v4();
}