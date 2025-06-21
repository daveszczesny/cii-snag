import 'dart:io';

import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/pdfexportrecords.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/category.dart' as cii;
import 'package:cii/models/status.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SingleProjectController {
  final Project project;
  final ValueNotifier<List<PdfExportRecords>> pdfExportRecordsNotifier = ValueNotifier<List<PdfExportRecords>>([]);

  SingleProjectController(this.project) {
    pdfExportRecordsNotifier.value = project.pdfExportRecords ?? <PdfExportRecords>[];
  }

  void updateProject(Project updatedProject) {
    project.name = updatedProject.name;
    project.description = updatedProject.description;
    project.status = updatedProject.status;
    project.dateCompleted = updatedProject.dateCompleted;
    project.snags = updatedProject.snags;
  }

  void saveProject() {
    project.save();
  }

  void deleteProject() {
    project.delete();
  }

  void addSnag(Snag snag) {
    project.snags.add(snag);
    project.dateModified = DateTime.now();
    project.snagsCreatedCount++;

    // change the status of a project to 'In Progress' if it was previously 'New'
    if (project.status.name == Status.todo.name) {
      project.status = Status.inProgress;
    }
    
    saveProject();
  }

  void updateSnag(Snag updatedSnag) {
    int index = project.snags.indexWhere((snag) => snag.uuid == updatedSnag.uuid);
    if (index != -1) {
      project.snags[index] = updatedSnag;
      project.save();
    }
    saveProject();
  }

  void deleteSnag(Snag snag) {
    project.snags.remove(snag);
    saveProject();
  }

  List<SnagController> getAllSnags() {
    return project.snags.map((snag) => SnagController(snag)).toList();
  }

  List<SnagController> getSnagsByStatus(Status status) {
    return project.snags
        .where((snag) => snag.status.name.toLowerCase() == status.name.toLowerCase())
        .map((snag) => SnagController(snag))
        .toList();
  }

  List<SnagController> getSnagsByPriority(String priority) {
    return project.snags
        .where((snag) => snag.priority.name == priority)
        .map((snag) => SnagController(snag))
        .toList();
  }

  double getSnagProgress() {
    if (project.snags.isEmpty) {
      return 0.0;
    }
    int totalResolvedSnags = project.snags.where((snag) => snag.status.name == Status.completed.name).length;
    return totalResolvedSnags / project.snags.length;
  }

  int getTotalSnags() {
    return project.snags.length;
  }

  int getTotalSnagsByStatus(Status status) {
    return project.snags.where((snag) => snag.status.name == status.name).length;
  }

  int getTotalSnagsByPriority(String priority) {
    return project.snags.where((snag) => snag.priority.name == priority).length;
  }

  List<Snag> filterSnags(String filter) {
    switch (filter.toLowerCase()) {
      case 'recent':
        return project.snags.toList()
          ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
      case 'closed':
        return project.snags
            .where((snag) => snag.status == Status.completed)
            .toList()
          ..sort((a, b) => b.dateCompleted!.compareTo(a.dateCompleted!));
      case 'all':
      default:
        return project.snags.toList()
          ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
    }
  }

  String? get getDescription {
    return project.description;
  }

  String? get getLocation {
    return project.location;
  }
  String? get getClient {
    return project.client;
  }
  String? get getContractor {
    return project.contractor;
  }
  String? get getProjectRef {
    return project.projectRef;
  }

  String? get getName {
    return project.name;
  }
  String? get getStatus {
    return project.status.name;
  }

  DateTime? get getDateCreated {
    return project.dateCreated;
  }

  DateTime? get getDateCompleted {
    return project.dateCompleted;
  }
  String? get getSnags {
    return project.snags.toString();
  }
  String? get getProjectUUID {
    return project.uuid;
  }

  String? get getProjectId {
    return project.id;
  }

  String? get getMainImagePath {
    return project.mainImagePath;
  }

  List<cii.Category>? get getCategories {
    return project.createdCategories;
  }

  List<Tag>? get getTags {
    return project.createdTags;
  }

  DateTime? get getDueDate {
    return project.dueDate;
  }

  String? get getDueDateString {
    return project.dueDate != null ? DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(project.dueDate!) : null;
  }

  void setName(String name) {
    project.name = name;
    saveProject();
  }

  void setMainImagePath(String path) {
    project.mainImagePath = path;
    saveProject();
  }

  void setDescription(String description) {
    project.description = description;
    saveProject();
  }

  void setLocation(String location) {
    project.location = location;
    saveProject();
  }
  void setClient(String client) {
    project.client = client;
    saveProject();
  }
  void setContractor(String contractor) {
    project.contractor = contractor;
    saveProject();
  }
  void setProjectRef(String projectRef) {
    project.projectRef = projectRef;
    saveProject();
  }

  void setStatus(String status) {
    project.status = Status.getStatus(status) ?? Status.todo;
    saveProject();
  }

  void removeCategory(String name) {
    project.createdCategories?.removeWhere((category) => category.name == name);
  }

  void removeTag(String name) {
    project.createdTags?.removeWhere((tag) => tag.name == name);
  }

  void addTag(String name, Color color) {
    project.createdTags ??= <Tag>[];
    project.createdTags?.add(Tag(name: name, color: color));
    saveProject();
  }

  void addCategory(String name, Color color) {
    project.createdCategories ??= <cii.Category>[];
    project.createdCategories?.add(cii.Category(name: name, color: color));
    saveProject();
  }

  void sortCategories() {
    cii.Category.sortCategories(project.createdCategories!);
  }

  List<Snag> getSnagsByCategory(String cat) {
    return project.snags.where((snag) =>
      snag.categories != null &&
      snag.categories!.isNotEmpty &&
      snag.categories!.first.name.toLowerCase() == cat.toLowerCase()
    ).toList();
  }

  List<Snag> getSnagsWithNoCategory() {
    return project.snags.where((snag) => snag.categories == null || snag.categories!.isEmpty).toList();
  }

  int getSnagsCreatedCount() {
    // this represents the total number of snags created in the project
    // regardless if the snag was deleted or not
    return project.snagsCreatedCount;
  }

  void addPdfExportRecord(PdfExportRecords record) {
    project.pdfExportRecords ??= <PdfExportRecords>[];
    project.pdfExportRecords?.add(record);
    pdfExportRecordsNotifier.value = List.from(project.pdfExportRecords!);
    saveProject();
  }

  List<PdfExportRecords> getPdfExportRecords() {
    return project.pdfExportRecords ?? <PdfExportRecords>[];
  }

  ValueListenable<List<PdfExportRecords>> getPdfExportRecordsListenable() {
    return pdfExportRecordsNotifier;
  }

  void deletePdfExportRecord(PdfExportRecords record) async {
    if (project.pdfExportRecords == null) {
      return; // No records to delete
    }
    // remove from the list
    project.pdfExportRecords!.removeWhere((r) => r.uuid == record.uuid);
    pdfExportRecordsNotifier.value = List.from(project.pdfExportRecords!);
    saveProject();

    // delete file
    try {
      final dir = Directory(await getPdfDirectory());
      final file = File('${dir.path}/${record.fileName}');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  void updateDetail(String key, String value) {
    switch (key) {
      case 'name':
        project.name = value;
        break;
      case 'description':
        project.description = value;
        break;
      case 'location':
        project.location = value;
        break;
      case 'client':
        project.client = value;
        break;
      case 'contractor':
        project.contractor = value;
        break;
      case 'projectRef':
        project.projectRef = value;
        break;
      case 'dueDate':
        project.dueDate = parseDate(value);
        break;
      default:
        print('Unknown key: $key');
        return;
    }
    saveProject();
  }

}