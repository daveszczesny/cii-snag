import 'dart:io';

import 'package:cii/models/project.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/category.dart' as cii;
import 'package:cii/models/tag.dart';
import 'package:cii/utils/common.dart';
import 'package:hive/hive.dart';

class ProjectController {

  final Box<Project> projectBox;

  ProjectController(this.projectBox);

  void addProject(Project project) {
    projectBox.add(project);
  }

  void createProject({
    required String name,
    String? description,
    String? client,
    String? contractor,
    String? location,
    String? projectRef,
    List<cii.Category>? categories,
    List<Tag>? tags,
    String? imagePath, // file name
    DateTime? dueDate,
  }) async {
    try {
      final project = Project(
        name: name,
        description: description,
        client: client,
        contractor: contractor,
        location: location,
        projectRef: projectRef?.toUpperCase(), // ensure project ref is uppercase
        createdCategories: categories != null ? List<cii.Category>.from(categories) : [],
        createdTags: tags,
        mainImagePath: imagePath,
        dueDate: dueDate,

      );
      await projectBox.add(project);
    } catch (e) {
      rethrow;
    }

  }

  void deleteAllProjects() {
    projectBox.clear();
  }

  Project getProjectById(String id) {
    return projectBox.values.firstWhere((project) => project.id == id, orElse: () => throw Exception('Project not found'));
  }

  List<Project> getAllProjects() {
    return projectBox.values.toList();
  }

  List<Project>? getProjectsByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'closed':
        // check if any project is completed
        List<Project> completedProjects = projectBox.values
            .where((project) => project.status.name == Status.completed.name).toList();

        if (completedProjects.isEmpty) { return []; }
        completedProjects.sort((a, b) => b.dateCompleted!.compareTo(a.dateCompleted!));
        return completedProjects;
      case 'recent':
        final twoWeekLimit = DateTime.now().subtract(const Duration(days: 14));
        List<Project> recentProjects = projectBox.values
            .where((project) => project.dateModified!.isAfter(twoWeekLimit))
            .toList();
        if (recentProjects.isEmpty) { return []; }
        recentProjects.sort((a, b) => b.dateModified!.compareTo(a.dateModified!));
        return recentProjects;
      case 'all':
      default:
        List<Project> allProjects = projectBox.values.toList();
        allProjects.sort((a, b) => b.dateModified!.compareTo(a.dateModified!));
        return allProjects;
    }
  }

  Stream<List<Project>> filterProjects(String filter) async*{
    List<Project> filteredProjects;
    switch (filter.toLowerCase()) {
      case 'recent':
        filteredProjects = projectBox.values.toList()
          ..sort((a, b) => b.dateModified!.compareTo(a.dateModified!));
        break;
      case 'closed':
        filteredProjects = projectBox.values
            .where((project) => project.status == Status.completed)
            .toList()
          ..sort((a, b) => b.dateCompleted!.compareTo(a.dateCompleted!));
        break;
      case 'all':
      default:
        filteredProjects = projectBox.values.toList()
          ..sort((a, b) => b.dateModified!.compareTo(a.dateModified!));
        break;
    }
    yield filteredProjects;
  }

  bool isUniqueProjectRef(String ref) {
    return projectBox.values
        .where((project) => project.projectRef == ref)
        .isEmpty;
  }
}