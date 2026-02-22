import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/providers/project_provider.dart';

final singleProjectProvider = Provider.family<Project?, String>((ref, projectId) {
  final projects = ref.watch(projectProvider);
  try {
    return projects.firstWhere((p) => p.id.toString() == projectId);
  } catch (e) {
    // TODO: Add warning / error log that project could not be found
    return null;
  }
});

// Notifier for managing individual project operations
class SingleProjectNotifier extends StateNotifier<Project?> {
  final Ref ref;

  SingleProjectNotifier(Project? project, this.ref) : super(project);

  void updateProject(Map<String, dynamic> updates) {
    if (state == null) return;

    if (updates.containsKey("name")) state!.name = updates["name"];
    if (updates.containsKey("description")) state!.description = updates["description"];
    if (updates.containsKey("location")) state!.location = updates["location"];
    if (updates.containsKey("client")) state!.client = updates["client"];
    if (updates.containsKey("contractor")) state!.contractor = updates["contractor"];
    if (updates.containsKey("projectRef")) state!.projectRef = updates["projectRef"];
    if (updates.containsKey("mainImagePath")) state!.mainImagePath = updates["mainImagePath"];
    if (updates.containsKey("dueDate")) state!.dueDate = updates["dueDate"];

    state!.dateModified = DateTime.now();
    state = state; // trigger state change
    ref.read(projectProvider.notifier).updateProject(state!);
  }

  void addSnag(Snag snag) {
    if (state == null) return;

    state!.dateModified = DateTime.now();
    state!.snagsCreatedCount++;

    if (state!.status.name == Status.todo.name) {
      state!.status = Status.inProgress;
    }

    state = state;
    ref.read(projectProvider.notifier).updateProject(state!);
  }

  void deleteProject() {
    if (state != null) {
      ref.read(projectProvider.notifier).deleteProject(state!.uuid);
      state = null;
    }
  }
}

final singleProjectNotifierProvider = StateNotifierProvider.family<SingleProjectNotifier, Project?, String>(
  (ref, projectId) {
    final project = ref.watch(singleProjectProvider(projectId));
    return SingleProjectNotifier(project, ref);
  }
);

