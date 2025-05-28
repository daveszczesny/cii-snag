import 'dart:io';

import 'package:cii/controllers/project_controller.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/category.dart' as cii;
import 'package:cii/models/tag.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
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
  final TextEditingController _dueDateController = TextEditingController();
  final List<cii.Category> _categories = List<cii.Category>.from(cii.Category.defaultCategories);
  final List<Tag> _tags = []; // no default tags

  String imagePath = '';

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
    final String dueDate = _dueDateController.text;

    final dueDateTime = parseDate(dueDate);

    if (projectRef.isEmpty) {
      // do not allow empty project ref
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project reference cannot be empty'),
          duration: Duration(seconds: 2),
        )
      );
      return;
    } else if (projectController.isUniqueProjectRef(projectRef) == false) {
      // do not allow duplicate project ref
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project reference already exists: $projectRef'),
          duration: const Duration(seconds: 2),
        )
      );
      return;
    }

    if (name.isEmpty) {
      // if the name is empty, create a default name 'Project #$no' and also show a snackbar
      int no = projectController.getAllProjects().length + 1;
      name = '${AppStrings.project} #$no';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.projectNameDefault(name)),
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
      imagePath: imagePath,
      dueDate: dueDateTime,
    );

    // navigate back
    Navigator.pop(context);
  }

  void onChange(String path) {
    setState((){
      imagePath = path;
    });
  }

  Widget onDelete(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Image'),
      content: const Text('Are you sure you want to delete this image?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel')
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // delete the image
            imagePath = '';
            setState(() {});
          },
          child: const Text('Delete')
        )
      ],
    );
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
              if (imagePath != '' && File(imagePath).existsSync()) ... [
                  buildThumbnailImageShowcase(context, imagePath, onDelete: onDelete),
                  const SizedBox(height: 24.0),
                ] else ... [
                  // if there is no project image allow the user to add one
                  buildImageInput_V2(context, (v) => setState(() {imagePath = v;})),
                  const SizedBox(height: 24.0),
              ],
              buildTextInput(AppStrings.projectTite, AppStrings.projectTitleExample, _nameController),
              const SizedBox(height: 28.0),
              buildTextInput(AppStrings.projectRef, AppStrings.projectRefExample, _projectRefController, optional: false),
              const SizedBox(height: 28.0),
              buildLongTextInput(AppStrings.projectDescription, AppStrings.projectDescriptionExample, _descriptionController),
              const SizedBox(height: 28.0),
              buildTextInput(AppStrings.projectLocation, AppStrings.projectLocationExample, _locationController),
              const SizedBox(height: 28.0),
              buildTextInput(AppStrings.projectClient, AppStrings.projectClientExample, _clientController),
              const SizedBox(height: 28.0),
              buildTextInput(AppStrings.projectContractor, AppStrings.projectContractorExample, _contractorController),
              const SizedBox(height: 28.0),
              buildDatePickerInput(context, 'Due Date', '12.05.2025', _dueDateController),
              const SizedBox(height: 28.0),
              ObjectSelector(
                label: AppStrings.category,
                pluralLabel: AppStrings.categories,
                hint: AppStrings.categoryHint(),
                options: _categories,
                getName: (cat) => cat.name,
                getColor: (cat) => cat.color,
                onCreate: (name, color) {
                  setState(() {
                    _categories.add(cii.Category(name: capitilize(name), color: color));
                    cii.Category.sortCategories(_categories);
                  });
                },
                hasColorSelector: false,
              ),
              const SizedBox(height: 28.0),
              ObjectSelector(
                label: AppStrings.tag,
                pluralLabel: AppStrings.tags,
                hint: AppStrings.tagHint(),
                options: _tags,
                getName: (tag) => tag.name,
                getColor: (tag) => tag.color,
                onCreate: (name, color) {
                  setState(() {
                    _tags.add(Tag(name: capitilize(name), color: color));
                  });
                },
                hasColorSelector: true,
              ),
              const SizedBox(height: 35.0),
              buildTextButton(AppStrings.projectCreate, createProject),
              const SizedBox(height: 12.0),
            ]
          )
        )
      )
    );
  }
}