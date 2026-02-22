import 'package:cii/models/comment.dart';
import 'package:cii/models/priority.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/models/category.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'snag.g.dart';

@HiveType(typeId: 2)
class Snag extends HiveObject {

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

  // List of original image paths
  @HiveField(7)
  List<String>? imagePaths;

  // Map of annotated images and their original paths
  // original path -> annotated path
  @HiveField(17)
  Map<String, String>? annotatedImagePaths;

  @HiveField(18)
  List<String>? progressImagePaths;

  @HiveField(19)
  List<String>? finalImagePaths;

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
  List<Category>? categories;

  @HiveField(20)
  String? reviewedBy;

  @HiveField(21)
  DateTime? dueDate;

  @HiveField(22)
  DateTime? dateClosed;

  Snag({
    String? uuid,
    String? id,
    this.projectId,
    required this.name,
    DateTime? dateCreated,
    DateTime? dueDate,
    Status? status,
    Priority? priority,
    this.description,
    this.imagePaths,
    this.annotatedImagePaths,
    this.assignee,
    this.comments,
    this.finalRemarks,
    this.location,
    this.lastModified,
    this.dateCompleted,
    this.tags,
    this.categories,
    this.reviewedBy,
    this.finalImagePaths,
    DateTime? dateClosed,
  }):
    uuid = uuid ?? const Uuid().v4(),
    id = id ?? 'PID',
    dateCreated = dateCreated ?? DateTime.now(),
    status = status ?? Status.todo,
    priority = priority ?? Priority.low;

  Snag copyWith({
    String? name,
    Status? status,
    Priority? priority,
    String? description,
    List<String>? imagePaths,
    Map<String, String>? annotatedImagePaths,
    String? assignee,
    String? finalRemarks,
    String? location,
    DateTime? dateCompleted,
    List<Tag>? tags,
    List<Category>? categories,
    String? reviewedBy,
    DateTime? dueDate,
    List<String>? finalImagePaths,
    DateTime? dateClosed,
  }) {
    return Snag(
      uuid: uuid,
      id: id,
      projectId: projectId,
      name: name ?? this.name,
      dateCreated: dateCreated,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      annotatedImagePaths: annotatedImagePaths ?? this.annotatedImagePaths,
      finalImagePaths: finalImagePaths,
      dateClosed: dateClosed,
      assignee: assignee,
      finalRemarks: finalRemarks,
      location: location,
      dateCompleted: dateCompleted,
      tags: tags,
      categories: categories,
      reviewedBy: reviewedBy,
      dueDate: dueDate,
    );
  }
}