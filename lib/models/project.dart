import 'package:cii/models/comment.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';


part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {

  // A unique identifier for the project
  @HiveField(0)
  final String uuid;

  // Human-readable id of the project
  @HiveField(1)
  final String id;

  // Name of the project
  @HiveField(2)
  String name;

  // Description of the project
  @HiveField(3)
  String? description;

  // Main image of the project
  @HiveField(4)
  String? mainImagePath;

  // List of comments on the project
  @HiveField(5)
  List<Comment>? comments = [];

  // Date based attributes
  @HiveField(6)
  DateTime? dateCreated;

  @HiveField(7)
  DateTime? dateModified;

  @HiveField(8)
  DateTime? dateCompleted;

  // Other Attributes
  @HiveField(9)
  String? projectRef;

  @HiveField(10)
  String? client;

  @HiveField(11)
  String? contractor;

  @HiveField(12)
  String? finalRemarks;

  // Location, might need to expand this
  // for future addition of integrated map
  @HiveField(13)
  String? location;

  @HiveField(14)
  Status status;

  @HiveField(15)
  List<Snag> snags = [];



  Project({
    String? uuid,
    required this.id,
    required this.name,
    this.description,
    this.mainImagePath,
    this.comments,
    DateTime? dateCreated,
    this.dateModified,
    this.dateCompleted,
    this.projectRef,
    this.client,
    this.contractor,
    this.finalRemarks,
    this.location,
    Status? status,
  })
  :
    uuid = uuid ?? const Uuid().v4(),
    dateCreated = dateCreated ?? DateTime.now(),
    status = status ?? Status.todo;

}