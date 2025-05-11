import 'package:cii/controllers/project_controller.dart';
import 'package:cii/models/project.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProjectCreate extends StatefulWidget {
  const ProjectCreate({super.key});

  @override
  State<ProjectCreate> createState() => _ProjectCreateState();
}

class _ProjectCreateState extends State<ProjectCreate> {

  // controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _projectRefController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _contractorController = TextEditingController();

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
    final String projectRef = _projectRefController.text;
    final String client = _clientController.text;
    final String contractor = _contractorController.text;

    projectController.createProject(
      name: name,
      description: description,
      location: location,
      projectRef: projectRef,
      client: client,
      contractor: contractor
    );

    // navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.newProject),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // navigate back
            Navigator.pop(context);
          },
        )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(38.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextInput(AppStrings.projectTite, AppStrings.projectTitleExample, _nameController),
              const SizedBox(height: 28.0),
              buildLongTextInput(AppStrings.projectDescription, AppStrings.projectDescriptionExample, _descriptionController),
              const SizedBox(height: 28.0),
              buildTextInput(AppStrings.projectLocation, AppStrings.projectLocationExample, _locationController),
              const SizedBox(height: 28.0),
              buildTextInput(AppStrings.projectRef, AppStrings.projectRefExample, _projectRefController),
              const SizedBox(height: 28.0),
              buildTextInput(AppStrings.projectClient, AppStrings.projectClientExample, _clientController),
              const SizedBox(height: 28.0),
              buildTextInput(AppStrings.projectContractor, AppStrings.projectContractorExample, _contractorController),
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