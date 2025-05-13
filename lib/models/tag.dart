import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'tag.g.dart';

@HiveType(typeId: 4)
class Tag extends HiveObject {

  @HiveField(0)
  final String name;

  @HiveField(1)
  String? description;

  @HiveField(2)
  Color color;

  Tag({
    required this.name,
    this.description,
    this.color = Colors.blue,
  });

}