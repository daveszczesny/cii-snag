import 'package:cii/models/comment.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/priority.dart' as snag_priority;
import 'package:cii/models/tag.dart';
import 'package:cii/models/category.dart' as cii;
import 'package:cii/view/utils/constants.dart';
import 'package:cii/controllers/notification_controller.dart';
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
    snag.lastModified = DateTime.now();
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

  DateTime? get getDateClosed {
    return snag.dateClosed;
  }

  String? get getDateClosedString {
    return snag.dateClosed != null ? DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dateClosed!) : null;
  }

  bool get isClosed {
    return snag.status.name == Status.completed.name;
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

  cii.Category? getCategoryByName(String name) {
    if (snag.categories == null || snag.categories!.isEmpty) return null;

    try {
      return snag.categories!.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return null;
    }
  }

  void removeCategoryByName(String name) {
    snag.categories!.removeWhere((cat) => cat.name == name);
  }

  Tag? getTagByName(String name) {
    if (snag.tags == null || snag.tags!.isEmpty) return null;

    try {
      return snag.tags!.firstWhere((tag) => tag.name == name);
    } catch (e) {
      return null;
    }
  }

  void removeTagByName(String name) {
    if (snag.tags == null || snag.tags!.isEmpty) return;

    try {
      snag.tags!.removeWhere((tag) => tag.name == name);
    } catch (e) {
      return;
    }
  }

  void setName(String v) { 
    snag.name = v; 
    snag.lastModified = DateTime.now();
    _triggerNotificationCheck();
  }
  void setDescription(String v) { 
    snag.description = v; 
    snag.lastModified = DateTime.now();
  }
  void setLocation(String v) { 
    snag.location = v; 
    snag.lastModified = DateTime.now();
  }
  void setAssignee(String v) { 
    snag.assignee= v; 
    snag.lastModified = DateTime.now();
  }
  void setFinalRemarks(String v) { 
    snag.finalRemarks = v; 
    snag.lastModified = DateTime.now();
  }
  void setTag(Tag tag) {
    snag.tags ??= [];
    snag.tags!.add(tag);
    snag.lastModified = DateTime.now();
  }
  void setDueDate(String v) { 
    snag.dueDate = DateFormat(AppDateTimeFormat.dateTimeFormatPattern).parse(v); 
    snag.lastModified = DateTime.now();
  }
  void setDateClosed(String v) {
    snag.dateClosed = DateFormat(AppDateTimeFormat.dateTimeFormatPattern).parse(v);
    snag.lastModified = DateTime.now();
  }
  void setReviewedBy(String value) { 
    snag.reviewedBy = value; 
    snag.lastModified = DateTime.now();
  }

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
    snag.lastModified = DateTime.now();
  }

  void _triggerNotificationCheck() {
    // Trigger notification check when snag is modified
    NotificationController().checkAndCreateNotifications();
  }
}