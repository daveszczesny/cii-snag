import 'package:cii/controllers/project_controller.dart';
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/category.dart' as cii;
import 'package:cii/models/priority.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/view/project/project_detail.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/selector.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SnagCreate extends StatefulWidget {
  final SingleProjectController? projectController;

  const SnagCreate({super.key, this.projectController});

  @override
  State<SnagCreate> createState() => _SnagCreateState();
}

class _SnagCreateState extends State<SnagCreate> {

  final TextEditingController nameController = TextEditingController();
  // final TextEditingController priorityController = TextEditingController();
  final TextEditingController assigneeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  final TextEditingController projectInputController = TextEditingController();
  cii.Category? snagCategory;
  List<Tag>? snagTags = [];
  final List<String> priorityOptions = ['Low', 'Medium', 'High'];

  List<String> imageFilePaths = [];
  Map<String, String> annotatedImages = {};

  late ProjectController controller;
  late List<Project> filteredProjects = [];
  late SingleProjectController? projectController;


  @override
  void initState() {
    super.initState();
    projectController = widget.projectController;
    selectProject();
  }

  void selectProject() async {
    if (projectController == null) {
      controller = ProjectController(Hive.box<Project>('projects'));
      filteredProjects = await controller.filterProjects('recent').first;
      if (filteredProjects.isNotEmpty) {
        projectController = SingleProjectController(filteredProjects.first);
        setState(() {});
      } else {
        // Handle the case where no projects are found
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          
          const SnackBar(content: Text('No projects found. Add a project first.'))
        );
      }
    }
  }

  void createSnag() {
    String name = nameController.text;
    final String assignee = assigneeController.text;
    final String location = locationController.text;
    final Priority priority = Priority.getPriorityByString(priorityController.text);

    if (name.isEmpty) {
      // if the name is empty, create a default name 'Snag #$no' and also show a snackbar
      int no = projectController!.getTotalSnags() + 1;
      name = 'Snag #$no';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Snag name is empty. Default name $name will be used'),
          duration: const Duration(seconds: 2),
        )
      );
    }

    if (projectController != null) {
      projectController?.addSnag(
        Snag(
          projectId: projectController!.getProjectId ?? 'PID',
          name: name,
          location: location,
          assignee: assignee,
          categories: snagCategory != null ? [snagCategory!] : [],
          tags: snagTags,
          priority: priority,
          imagePaths: imageFilePaths,
          annotatedImagePaths: annotatedImages,
        )
      );

      Navigator.pop(context);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ProjectDetail(projectController: projectController!))
      );
    }
  }  

  void onChange() {
    setState(() {});
  }

  void saveAnnotatedImage(String originalPath, String path) {
    setState(() {
      annotatedImages[originalPath] = path;
    });
  }

  void clearInputs() {
    nameController.clear();
    assigneeController.clear();
    locationController.clear();
    priorityController.clear();
    imageFilePaths = [];
    annotatedImages = {};
    snagCategory = null;
    snagTags = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar is only shown if user is using QUICK ADD
      appBar: widget.projectController == null
        ? AppBar(
          title: const Text('Create Snag'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }
          ),
        )
        : null,

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(38.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // If using QUICK ADD ask the user to select a project
              // Check the original project controller passed in to check whether this is a QUICK ADD
              if (widget.projectController == null) ... [
                buildDropdownInputForObjects(
                  label: 'Projects',
                  options: filteredProjects,
                  selectedProject: projectController?.project,
                  onChanged: (Project? value) {
                    setState(() {
                      projectController = SingleProjectController(value!);
                    });
                    clearInputs();
                  }
                ),
                const SizedBox(height: 28.0),
              ],

              buildTextInput(AppStrings.snagName, AppStrings.snagNameExample, nameController),
              const SizedBox(height: 28.0),
              buildTextInput(AppStrings.projectLocation, 'Ex. Living Room', locationController),
              const SizedBox(height: 28.0),
              buildImageInput('Upload Image', context, imageFilePaths, onChange),
              const SizedBox(height: 14.0),
              if (imageFilePaths.isNotEmpty) ... [
                buildImageShowcase(context, onChange, saveAnnotatedImage, imageFilePaths),
                const SizedBox(height: 28.0),
              ],
              buildTextInput(AppStrings.assignee, AppStrings.assigneeExample, assigneeController),
              const SizedBox(height: 28.0),
              buildDropdownInput('Priority', priorityOptions, priorityController),
              const SizedBox(height: 28.0),
              if (projectController != null) ... [
                ObjectSelector(
                  label: 'Category',
                  pluralLabel: 'Categories',
                  hint: 'This allows you to group snags into categories. Each snag can be assigned a single category',
                  options: projectController?.getCategories ?? [],
                  getName: (cat) => cat.name,
                  getColor: (cat) => cat.color,
                  onCreate: (name, color) {
                    setState(() {
                      projectController?.addCategory(name, color);
                    });
                  },
                  onSelect: (obj) {
                    setState(() {
                      if (snagCategory == obj) {
                        snagCategory = null;
                      } else {
                        snagCategory = obj;
                      }
                    });
                  },
                ),
                const SizedBox(height: 28.0),
                ObjectSelector(
                  label: 'Tag',
                  pluralLabel: 'Tags',
                  hint: 'This allows you to assign tags to snags. Each snag can be assigned multiple tags',
                  options: projectController?.getTags ?? [],
                  getName: (tag) => tag.name,
                  getColor: (tag) => tag.color,
                  onCreate: (name, color) {
                    setState(() {
                      projectController?.addTag(name, color);
                    });
                  },
                  onSelect: (obj) {
                    setState(() {
                      if (snagTags!.contains(obj)) {
                        snagTags?.remove(obj);
                      } else {
                        snagTags?.add(obj);
                      }
                    });
                  },
                  allowMultiple: true,
                ),
              ],
              const SizedBox(height: 28.0),
              ElevatedButton(
                onPressed: createSnag,
                child: const Text(AppStrings.snagCreate),
              )
            ],
          )
        )
      )
    );
  }
}