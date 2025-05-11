import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';

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

  void deleteProject() {
    project.delete();
  }

  void addSnag(Snag snag) {
    project.snags.add(snag);
    project.save();
  }

  void updateSnag(Snag updatedSnag) {
    int index = project.snags.indexWhere((snag) => snag.uuid == updatedSnag.uuid);
    if (index != -1) {
      project.snags[index] = updatedSnag;
      project.save();
    }
  }

  void deleteSnag(Snag snag) {
    project.snags.remove(snag);
    project.save();
  }

  List<Snag> getSnagsByStatus(Status status) {
    return project.snags.where((snag) => snag.status == status).toList();
  }

  List<Snag> getSnagsByPriority(String priority) {
    return project.snags.where((snag) => snag.priority.name == priority).toList();
  }

  double getSnagProgress() {
    if (project.snags.isEmpty) {
      return 0.0;
    }
    int totalResolvedSnags = project.snags.where((snag) => snag.status == Status.completed).length;
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

  List<Snag> getAllSnags() {
    return project.snags;
  }


  String? get getDescription {
    return project.description;
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
  String? get getProjectId {
    return project.uuid;
  }

  String? get getMainImagePath {
    return project.mainImagePath;
  }
}