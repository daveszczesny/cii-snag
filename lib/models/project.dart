import 'package:cii/models/category.dart';
import 'package:cii/models/comment.dart';
import 'package:cii/models/csvexportrecords.dart';
import 'package:cii/models/pdfexportrecords.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/tag.dart';
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
  final String? id;

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

  // Tags are project specific
  // All tags are created by the user, and can be reused when creating snags
  @HiveField(16)
  List<Tag>? createdTags;

  // Categories are project specific
  // There will be some premade categories but more can be created by the user
  // Will be used to categorize snags
  @HiveField(17)
  List<Category>? createdCategories;

  @HiveField(18)
  int snagsCreatedCount;

  @HiveField(19)
  DateTime? dueDate;

  @HiveField(20)
  List<PdfExportRecords>? pdfExportRecords;

  @HiveField(21)
  List<CsvExportRecords>? csvExportRecords;


  Project({
    String? uuid,
    String? id,
    required this.name,
    this.description,
    this.mainImagePath,
    this.comments,
    DateTime? dateCreated,
    DateTime? dateModified,
    DateTime? dueDate,
    this.dateCompleted,
    this.projectRef,
    this.client,
    this.contractor,
    this.finalRemarks,
    this.location,
    Status? status,
    List<Category>? createdCategories,
    List<Tag>? createdTags,
    int? snagsCreatedCount,
    List<PdfExportRecords>? pdfExportRecords,
    List<CsvExportRecords>? csvExportRecords,
    List<Snag>? snags,
  })
  :
    uuid = uuid ?? const Uuid().v4(),
    id = id ?? humanReadableId(name),
    dateCreated = dateCreated ?? DateTime.now(),
    dateModified = dateModified ?? DateTime.now(),
    dueDate = dueDate,
    status = status ?? Status.todo,
    createdCategories = createdCategories ?? [],
    createdTags = createdTags ?? [],
    snagsCreatedCount = snagsCreatedCount ?? 0,
    pdfExportRecords = pdfExportRecords ?? [],
    csvExportRecords = csvExportRecords ?? [],
    snags = snags ?? [];

  Project.from(Project other)
    : uuid = other.uuid,
      id = other.id,
      name = other.name,
      description = other.description,
      mainImagePath = other.mainImagePath,
      comments = other.comments,
      dateCreated = other.dateCreated,
      dateModified = other.dateModified,
      dateCompleted = other.dateCompleted,
      projectRef = other.projectRef,
      client = other.client,
      contractor = other.contractor,
      finalRemarks = other.finalRemarks,
      location = other.location,
      status = other.status,
      snags = other.snags.map((s) => s).toList(),
      createdCategories = other.createdCategories?.map((c) => c).toList(),
      createdTags = other.createdTags?.map((t) => t).toList(),
      snagsCreatedCount = other.snagsCreatedCount,
      dueDate = other.dueDate,
      pdfExportRecords = other.pdfExportRecords?.map((r) => r).toList(),
      csvExportRecords = other.csvExportRecords?.map((r) => r).toList();

  Project copyWith({
    String? name,
    String? description,
    String? mainImagePath,
    Status? status,
    String? location,
    String? client,
    String? contractor,
    String? projectRef,
    DateTime? dueDate,
    List<Category>? createdCategories,
    List<Tag>? createdTags,
    String? finalRemarks,
    DateTime? dateCreated,
    DateTime? dateModified,
    DateTime? dateCompleted,
    int? snagsCreatedCount,
    List<PdfExportRecords>? pdfExportRecords,
    List<CsvExportRecords>? csvExportRecords,
    List<Snag>? snags,
    List<Comment>? comments,
  }) {
    return Project(
      uuid: uuid,
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      mainImagePath: mainImagePath ?? this.mainImagePath,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? DateTime.now(),
      dateCompleted: dateCompleted ?? this.dateCompleted,
      projectRef: projectRef ?? this.projectRef,
      client: client ?? this.client,
      contractor: contractor ?? this.contractor,
      finalRemarks: finalRemarks ?? this.finalRemarks,
      location: location ?? this.location,
      status: status ?? this.status,
      createdCategories: createdCategories ?? this.createdCategories,
      createdTags: createdTags ?? this.createdTags,
      snagsCreatedCount: snagsCreatedCount ?? this.snagsCreatedCount,
      dueDate: dueDate ?? this.dueDate,
      pdfExportRecords: pdfExportRecords ?? this.pdfExportRecords,
      csvExportRecords: csvExportRecords ?? this.csvExportRecords,
      snags: snags ?? this.snags,
      comments: comments ?? this.comments,
    );
  }

  static String humanReadableId(String name) {
    // Generate a human-readable ID
    // Remove spaces and special characters, keep only alphanumeric characters
    final sanitized = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    // Extract the first 3 characters or pad with random alphanumeric characters if too short
    final id = sanitized.length >= 3
        ? sanitized.substring(0, 3).toUpperCase()
        : (sanitized.toUpperCase() + const Uuid().v4().split('-')[0]).substring(0, 3);

    return id;
  }


}
