import 'package:cii/models/comment.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/priority.dart' as snag_priority;
import 'package:cii/models/tag.dart';
import 'package:cii/models/category.dart' as cii;
import 'package:cii/view/utils/constants.dart';
import 'package:intl/intl.dart';

class SnagController {

  final Snag snag;
  SnagController(this.snag);

  String get getId {
    return snag.id;
  }

  DateTime get dateCreated {
    return snag.dateCreated;
  }

  String get name {
    return snag.name;
  }

  Status get status {
    return snag.status;
  }

  set status(Status status) {
    snag.status = status;
  }

  snag_priority.Priority get priority {
    return snag.priority;
  }

  DateTime? get getDueDate {
    return snag.dueDate;
  }

  String? get getDueDateString {
    return snag.dueDate != null ? DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dueDate!) : null;
  }

  String get assignee {
    return snag.assignee ?? '';
  }

  String get location {
    return snag.location ?? '';
  }

  String get finalRemarks {
    return snag.finalRemarks ?? '';
  }

  String get reviewedBy {
    return snag.reviewedBy ?? '';
  }

  List<String> get imagePaths {
    return snag.imagePaths ?? [];
  }

  Map<String, String> get annotatedImagePaths {
    return snag.annotatedImagePaths ?? {};
  }

  List<String> get progressImagePaths {
    return snag.progressImagePaths ?? [];
  }

  void addProgressImagePath(String path) {
    snag.progressImagePaths ??= [];
    snag.progressImagePaths!.add(path);
  }
  
  List<Comment> get comments {
    return snag.comments ?? [];
  }
  
  DateTime? get lastModified {
    return snag.lastModified;
  }
  
  DateTime? get dateCompleted {
    return snag.dateCompleted;
  }
  
  String get description {
    return snag.description ?? '';
  }


  List<Tag> get tags {
    return snag.tags ?? [];
  }

  List<String> get finalImagePaths {
    return snag.finalImagePaths ?? [];
  }

  List<cii.Category> get categories {
    return snag.categories ?? [];
  }


  void setName(String v) { snag.name = v; }
  void setDescription(String v) { snag.description = v; }
  void setLocation(String v) { snag.location = v; }
  void setAssignee(String v) { snag.assignee= v; }
  void setFinalRemarks(String v) { snag.finalRemarks = v; }
  void setTag(Tag tag) {
    snag.tags ??= [];
    snag.tags!.add(tag);
  }
  void setReviewedBy(String value) { snag.reviewedBy = value; }

  void setFinalImagePaths(List<String> paths) {
    snag.finalImagePaths = List<String>.from(paths);
  }

  void setCategory(cii.Category category) {
    // limit to 1 category
    if (snag.categories != null && snag.categories!.isNotEmpty) {
      snag.categories!.clear();
    }
    snag.categories ??= [];
    snag.categories!.add(category);
  }

}