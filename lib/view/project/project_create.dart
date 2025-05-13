import 'package:cii/controllers/project_controller.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/category.dart' as cii;
import 'package:cii/models/tag.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/selector.dart';
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
  final List<cii.Category> _categories = List<cii.Category>.from(cii.Category.defaultCategories);
  final List<Tag> _tags = []; // no default tags

  late ProjectController projectController;

  @override
  void initState() {
    super.initState();
    projectController = ProjectController(Hive.box<Project>('projects'));
  }

  void createProject() {
    String name = _nameController.text;
    final String description = _descriptionController.text;
    final String location = _locationController.text;
    final String projectRef = _projectRefController.text;
    final String client = _clientController.text;
    final String contractor = _contractorController.text;

    if (name.isEmpty) {
      // if the name is empty, create a default name 'Project #$no' and also show a snackbar
      int no = projectController.getAllProjects().length + 1;
      name = 'Project #$no';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project name is empty. Default name $name will be used'),
          duration: const Duration(seconds: 2),
        )
      );
    }

    projectController.createProject(
      name: name,
      description: description,
      location: location,
      projectRef: projectRef,
      client: client,
      contractor: contractor,
      categories: _categories,
      tags: _tags,
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
          padding: const EdgeInsets.all(24.0),
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
              ObjectSelector(
                label: 'Category',
                pluralLabel: 'Categories',
                hint: 'This allows you to create new categories to be used for snags in the project. Each snag can be assigned a single category',
                options: _categories,
                getName: (cat) => cat.name,
                getColor: (cat) => cat.color,
                onCreate: (name, color) {
                  setState(() {
                    _categories.add(cii.Category(name: capitilize(name), color: color));
                  });
                },
              ),
              const SizedBox(height: 28.0),
              ObjectSelector(
                label: 'Tag',
                pluralLabel: 'Tags',
                hint: 'This allows you to create new tags to be used for snags in the project. Each snag can have multiple tags',
                options: _tags,
                getName: (tag) => tag.name,
                getColor: (tag) => tag.color,
                onCreate: (name, color) {
                  setState(() {
                    _tags.add(Tag(name: capitilize(name), color: color));
                  });
                }
              ),
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