import 'package:cii/models/comment.dart';
import 'package:cii/models/priority.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/models/category.dart' as cii;
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'snag.g.dart';

@HiveType(typeId: 2)
class Snag extends HiveObject {

  // Mandatory fields
  @HiveField(0)
  final String uuid;

  // Human-readable id of the snag
  @HiveField(1)
  final String id;

  @HiveField(14)
  final String? projectId;

  // Name of the snag
  @HiveField(2)
  String name;

  @HiveField(3)
  final DateTime dateCreated;

  @HiveField(4)
  Status status;

  @HiveField(5)
  Priority priority;

  // Optional fields
  @HiveField(6)
  String? description;

  @HiveField(7)
  List<String>? imagePaths;

  @HiveField(8)
  String? assignee;

  @HiveField(9)
  List<Comment>? comments;

  @HiveField(10)
  String? finalRemarks;

  @HiveField(11)
  String? location;

  // Date Based attributes
  @HiveField(12)
  DateTime? lastModified;

  @HiveField(13)
  DateTime? dateCompleted;

  @HiveField(15)
  List<Tag>? tags;

  @HiveField(16)
  List<cii.Category>? categories;

  Snag({
    String? uuid,
    String? id,
    this.projectId,
    required this.name,
    DateTime? dateCreated,
    Status? status,
    Priority? priority,
    this.description,
    this.imagePaths,
    this.assignee,
    this.comments,
    this.finalRemarks,
    this.location,
    this.lastModified,
    this.dateCompleted,
    this.tags,
    this.categories,
  }):
    uuid = uuid ?? const Uuid().v4(),
    id = id ?? createHumanReadableId(projectId ?? 'PID'),
    dateCreated = dateCreated ?? DateTime.now(),
    status = status ?? Status.todo,
    priority = priority ?? Priority.low;


    static String createHumanReadableId(String projectId) {
      return '$projectId-${const Uuid().v4().split('-')[0]}';
    }
}