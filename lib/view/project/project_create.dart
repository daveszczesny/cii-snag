import 'package:cii/controllers/project_controller.dart';
import 'package:cii/models/project.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProjectCreate extends StatefulWidget {
  const ProjectCreate({Key? key}) : super(key: key);

  @override
  State<ProjectCreate> createState() => _ProjectCreateState();
}

class _ProjectCreateState extends State<ProjectCreate> {

  // controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  late ProjectController projectController;

  @override
  void initState() {
    super.initState();
    projectController = ProjectController(Hive.box<Project>('projects'));
  }

  void createProject() {
    final String name = _nameController.text;
    final String description = _descriptionController.text;
    final String location = _locationController.text;

    projectController.createProject(
      name,
      description,
      location
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // navigate back
          },
        )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(38.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextInput('Project title', 'Ex. My new project', _nameController),
              const SizedBox(height: 28.0),
              buildLongTextInput('Description', 'Ex. Short description of project', _descriptionController),
              const SizedBox(height: 28.0),

              ElevatedButton(
                onPressed: createProject,
                child: const Text('Create project'),
              )
            ]
          )
        )
      )
    );
  }
}