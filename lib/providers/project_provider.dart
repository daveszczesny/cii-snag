import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/models/project.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProjectNotifier extends StateNotifier<List<Project>> {
  ProjectNotifier() : super([]) {
    _loadProjects();
  }

  Box<Project> get _box => Hive.box<Project>('projects');

  void _loadProjects() {
    state = _box.values.toList();
  }

  void addProject(Project project) {
    _box.put(project.id, project);
    state = [...state, project];
  }

  void updateProject(Project project) {
    _box.put(project.id, project);
    final index = state.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      state = [
        ...state.sublist(0, index),
        project,
        ...state.sublist(index + 1),
      ];
    }
  }

  void deleteProject(String projectId) {
    _box.delete(projectId);
    state = state.where((p) => p.id.toString() != projectId).toList();
  }

  void incrementSnagCount(String projectId) {
    final index = state.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final project = state[index];
      final updatedProject = project.copyWith(
        snagsCreatedCount: project.snagsCreatedCount + 1,
      );
      updateProject(updatedProject);
    }
  }
}

final projectProvider = StateNotifierProvider<ProjectNotifier, List<Project>>(
  (ref) => ProjectNotifier(),
);
