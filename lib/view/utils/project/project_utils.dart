// Utility functions for projects

import 'package:cii/models/project.dart';
import 'package:cii/models/status.dart';

List<Project> getProjectByStatus(List<Project> projects, String status) {
  switch (status.toLowerCase()) {
    case "closed":
      return projects
        .where((p) => p.status.name == Status.completed.name)
        .toList();
    case "recent":
      final twoWeekLimit = DateTime.now().subtract(const Duration(days: 14));
      List<Project> recentProjects = projects
        .where((p) => p.dateModified!.isAfter(twoWeekLimit))
        .toList();

      if (recentProjects.isEmpty) return [];
      recentProjects.sort((a, b) => b.dateModified!.compareTo(a.dateModified!));
      return recentProjects;
    case "all":
    default:
      if (projects.isEmpty) return [];
      List<Project> allProjects = projects;
      allProjects.sort((a, b) => b.dateModified!.compareTo(a.dateModified!));
      return allProjects;
  }
}
