import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/category.dart' as cii;
import 'package:cii/models/status.dart';
import 'package:cii/models/tag.dart';
import 'package:flutter/material.dart';

class SingleProjectController {
  final Project project;


  SingleProjectController(this.project);

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
    return project.snags.where((snag) => snag.status == status).length;
  }

  int getTotalSnagsByPriority(String priority) {
    return project.snags.where((snag) => snag.priority.name == priority).length;
  }

  List<Snag> filterSnags(String filter) {
    switch (filter.toLowerCase()) {
      case 'recent':
        return project.snags.toList()
          ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
      case 'completed':
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

  void removeCategory(String name) {
    project.createdCategories?.removeWhere((category) => category.name == name);
  }

  void removeTag(String name) {
    project.createdTags?.removeWhere((tag) => tag.name == name);
  }

  void addTag(String name, Color color) {
    project.createdTags ??= <Tag>[];
    project.createdTags?.add(Tag(name: name, color: color));
    project.save();
  }

  void addCategory(String name, Color color) {
    project.createdCategories ??= <cii.Category>[];
    project.createdCategories?.add(cii.Category(name: name, color: color));
    project.save();
  }

}