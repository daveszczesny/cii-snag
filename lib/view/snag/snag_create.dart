import 'package:cii/controllers/project_controller.dart';
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/category.dart' as cii;
import 'package:cii/models/priority.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
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

  List<String> imageFilePaths = [];
  Map<String, String> annotatedImages = {};

  String selectedImage = '';

  late ProjectController controller;
  late List<Project> filteredProjects = [];
  late SingleProjectController? projectController;

  // status
  late ValueNotifier<String> selectedStatusOption;
  final List<String> statusOptions = Status.values.map((e) => e.name).toList(); // get the name of each status

  // priority
  late ValueNotifier<String> selectedPriorityOption;
  final List<String> priorityOptions = ['Low', 'Medium', 'High'];


  @override
  void initState() {
    super.initState();
    projectController = widget.projectController;
    selectProject();

    selectedStatusOption = ValueNotifier<String>(statusOptions.first);
    selectedPriorityOption = ValueNotifier<String>(priorityOptions.first);

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
          
          const SnackBar(content: Text(AppStrings.noProjectsFoundQuickAdd)),
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
      name = '${AppStrings.snag} #$no';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.snagNameDefault(name)),
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
          status: Status.getStatus(selectedStatusOption.value),
        )
      );

      Navigator.pop(context);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ProjectDetail(projectController: projectController!))
      );
    }
  }  

  void onChange({String p = ''}) {
    if (selectedImage == '') {

      // check if an annotated image exists
      if (annotatedImages.isNotEmpty) {
        if (annotatedImages.containsKey(imageFilePaths[0])) {
          selectedImage = annotatedImages[imageFilePaths[0]]!;
        } else {
          selectedImage = imageFilePaths[0];
        }
      } else {
        selectedImage = imageFilePaths.isNotEmpty ? imageFilePaths[0] : '';
      }

    } else {
      if (annotatedImages.isNotEmpty) {
        if (annotatedImages.containsKey(p)) {
          selectedImage = annotatedImages[p]!;
        } else {
          selectedImage = p;
        }
      } else {
        selectedImage = p;
      }
    }

    setState(() {});
  }

  void saveAnnotatedImage(String originalPath, String path) {
    setState(() {
      annotatedImages[originalPath] = path;
      onChange(p: originalPath);
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
          title: const Text(AppStrings.snagCreate),
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
          padding: const EdgeInsets.all(24.0),
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
              // buildImageInput(AppStrings.uploadImage, context, imageFilePaths, onChange),

              if (imageFilePaths.isEmpty) ... [
                buildMultipleImageInput_V2(context, imageFilePaths, onChange),
              ] else ... [
                showImageWithEditAbility(context, selectedImage != '' ? selectedImage : imageFilePaths[0], saveAnnotatedImage)
              ],

              const SizedBox(height: 14.0),
              if (imageFilePaths.isNotEmpty) ... [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildImageShowcase(context, onChange, saveAnnotatedImage, imageFilePaths),
                    if (imageFilePaths.length < 5) ... [
                      buildMultipleImageInput_V2(context, imageFilePaths, onChange, large: false),
                    ],
                  ],
                ),
                const SizedBox(height: 28.0),
              ],
              buildTextInput(AppStrings.snagName, AppStrings.snagNameExample, nameController),
              const SizedBox(height: 28.0),
              buildTextInput(AppStrings.assignee, AppStrings.assigneeExample, assigneeController),
              const SizedBox(height: 28.0),
              buildTextInput(AppStrings.projectLocation, AppStrings.snagLocationExample, locationController),
              const SizedBox(height: 28.0),
              buildCustomSegmentedControl(label: 'Priority', options: priorityOptions, selectedNotifier: selectedPriorityOption),
              const SizedBox(height: 28.0),
              buildCustomSegmentedControl(label: 'Status', options: statusOptions, selectedNotifier: selectedStatusOption),
              const SizedBox(height: 28.0),
              if (projectController != null) ... [
                ObjectSelector(
                  label: AppStrings.category,
                  pluralLabel: AppStrings.categories,
                  hint: AppStrings.categoryHint,
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
                  label: AppStrings.tag,
                  pluralLabel: AppStrings.tags,
                  hint: AppStrings.tagHint,
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
              const SizedBox(height: 35.0),
              buildTextButton(AppStrings.snagCreate, createSnag),
              const SizedBox(height: 12.0),
            ],
          )
        )
      )
    );
  }
}