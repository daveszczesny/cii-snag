import 'package:cii/models/project.dart';
import 'package:cii/models/status.dart';
import 'package:hive/hive.dart';

class ProjectController {

  final Box<Project> projectBox;

  ProjectController(this.projectBox);

  void addProject(Project project) {
    projectBox.add(project);
  }

  void createProject(
    String id,
    String name,
    String description,
  ) {
    final project = Project(
      id:id,
      name: name,
      description: description,
    );

    projectBox.add(project);

  }

  Project getProjectById(String id) {
    return projectBox.values.firstWhere((project) => project.id == id, orElse: () => throw Exception('Project not found'));
  }


  Stream<List<Project>> filterProjects(String filter) async*{
    List<Project> filteredProjects;
    switch (filter.toLowerCase()) {
      case 'recent':
        filteredProjects = projectBox.values.toList()
          ..sort((a, b) => b.dateCreated!.compareTo(a.dateCreated!));
        break;
      case 'completed':
        filteredProjects = projectBox.values
            .where((project) => project.status == Status.completed)
            .toList()
          ..sort((a, b) => b.dateCompleted!.compareTo(a.dateCompleted!));
        break;
      case 'all':
      default:
        filteredProjects = projectBox.values.toList()
          ..sort((a, b) => b.dateCreated!.compareTo(a.dateCreated!));
        break;
    }
    yield filteredProjects;
  }
}