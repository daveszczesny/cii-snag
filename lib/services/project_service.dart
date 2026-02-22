import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/providers/providers.dart';
import 'package:cii/services/snag_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectService {
  static void addProject(WidgetRef ref, Project project) {
    ref.read(projectProvider.notifier).addProject(project);
  }

  static void updateProject(WidgetRef ref, Project project) {
    ref.read(projectProvider.notifier).updateProject(project);
  }

  static void deleteProject(WidgetRef ref, String projectId) {
    final snags = ref.read(snagsByProjectProvider(projectId));
    for (final snag in snags) {
      SnagService.deleteSnag(ref, snag.id);
    }
    ref.read(projectProvider.notifier).deleteProject(projectId);
  }

  static Project getProject(WidgetRef ref, String projectId) {
    return ref.watch(singleProjectProvider(projectId))!;
  }

  static List<Project> getProjects(WidgetRef ref) {
    return ref.watch(projectProvider);
  }


  /*
    Snags are children of projects
      It makes sense to expose their functions here
  */
  static void addSnag(WidgetRef ref, String projectId, Snag snag) {
    SnagService.addSnag(ref, snag);

    final project = ProjectService.getProject(ref, projectId);
    if (project.status == Status.todo) {
      final updatedProject = project.copyWith(status: Status.inProgress);
      ref.read(projectProvider.notifier).updateProject(updatedProject);
    }

  }

  static void updateSnag(WidgetRef ref, String projectId, Snag snag) {
    SnagService.updateSnag(ref, snag);
  }

  static void deleteSnag(WidgetRef ref, String projectId, String snagId) {
    SnagService.deleteSnag(ref, snagId);
  }

  static List<Snag> getSnags(WidgetRef ref, String projectId) {
    return SnagService.getSnagsByProject(ref, projectId);
  }

  /*
    Utility functions for snags fronted by projects
   */

  static int getSnagCount(WidgetRef ref, String projectId) {
    return getSnags(ref, projectId).length;
  }

  static List<Snag> getSnagsByStatus(WidgetRef ref, String projectId, Status status) {
    return getSnags(ref, projectId)
      .where((s) => s.status == status)
      .toList();
  }
}