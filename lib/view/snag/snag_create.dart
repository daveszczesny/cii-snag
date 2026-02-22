import 'package:cii/models/category.dart' as cii;
import 'package:cii/models/priority.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/models/tier_limits.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/services/tier_service.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/project/project_detail.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/project/project_utils.dart';
import 'package:cii/view/utils/selector.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnagCreate extends ConsumerStatefulWidget{
  final String? projectId;

  const SnagCreate({super.key, this.projectId});

  @override
  ConsumerState<SnagCreate> createState() => _SnagCreateState();
}

class _SnagCreateState extends ConsumerState<SnagCreate> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController assigneeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  final TextEditingController projectInputController = TextEditingController();
  cii.Category? snagCategory;
  List<Tag>? snagTags = [];

  List<String> imageFilePaths = [];
  Map<String, String> annotatedImages = {};

  String selectedImage = '';

  // TODO - might need this filtered projects thing
  late List<Project> filteredProjects = [];

  // status
  late ValueNotifier<String> selectedStatusOption;
  final List<String> statusOptions = Status.values.map((e) => e.name).toList(); // get the name of each status

  // priority
  late ValueNotifier<String> selectedPriorityOption;
  final List<String> priorityOptions = ['Low', 'Medium', 'High'];
  
  String? selectedProjectId;

  @override
  void initState() {
    super.initState();
    clearInputs();
    selectedProjectId = widget.projectId;

    selectedStatusOption = ValueNotifier<String>(statusOptions.first);
    selectedPriorityOption = ValueNotifier<String>(priorityOptions.first);

  }

  void selectProject() async {
    if (selectedProjectId == null) {
      final List<Project> projects = ProjectService.getProjects(ref);
      filteredProjects = getProjectByStatus(projects, "recent");

      if (filteredProjects.isNotEmpty) {
        selectedProjectId = projects.first.id!; 
        setState(() {}); // TODO - is this needed?
      }

      // TODO: Check, i removed an else block when filterProjects is empty, might not be possible but check
    }
  }

  String createSnagId(Project project) {
    // get date in yyyyMMdd format
    String date = DateTime.now()
      .toString()
      .substring(0, 10)
      .replaceAll('-', '');
    final projectRef = project.projectRef;
    final snagCount = project.snagsCreatedCount;
    final formattedSnagCount = (snagCount + 1)
      .toString()
      .padLeft(4, '0');
    String snagId = '$projectRef$date-$formattedSnagCount';
    return snagId;
  }

  void createSnag() {
    final Project project = ProjectService.getProject(ref, selectedProjectId!);

    String name = nameController.text;
    final String description = descriptionController.text;
    final String assignee = assigneeController.text;
    final String location = locationController.text;
    final Priority priority = Priority.getPriorityByString(selectedPriorityOption.value);
    final String dueDate = dueDateController.text;
    final dueDateTime = parseDate(dueDate);

    if (name.isEmpty) {
      int no = ProjectService.getSnagCount(ref, project.id!) + 1;
      // if the name is empty, create a default name 'Snag #$no' and also show a snackbar
      name = '${AppStrings.snag()} #$no';
      
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.snagNameDefault(name)),
          duration: const Duration(seconds: 2),
        )
      );
    }

    // reorder imageFilePaths so that the first image is the selected image
    if (selectedImage != '') {
      String originalPath = selectedImage;
      for (var entry in annotatedImages.entries) {
        if (entry.value == selectedImage) {
          originalPath = entry.key;
          break;
         }
      }
      if (imageFilePaths.contains(originalPath)) {
        imageFilePaths.remove(originalPath);
        imageFilePaths.insert(0, originalPath);
      }
    }

    final snagId = createSnagId(project!);
    final snag = Snag(
      projectId: selectedProjectId,
      id: snagId,
      name: name,
      location: location,
      description: description,
      assignee: assignee,
      categories: snagCategory != null ? [snagCategory!] : [],
      tags: snagTags,
      priority: priority,
      imagePaths: imageFilePaths,
      annotatedImagePaths: annotatedImages,
      status: Status.getStatus(selectedStatusOption.value),
      dueDate: dueDateTime,
    );

    ProjectService.addSnag(ref, selectedProjectId!, snag);

    Navigator.pop(this.context);
    Navigator.of(this.context).push(
      MaterialPageRoute(builder: (context) => ProjectDetail(projectId: selectedProjectId!))
    );
  }  


  void onChange({String p = ''}) {
    if (p != '') {
      // When a specific image is selected
      if (annotatedImages.containsKey(p)) {
        selectedImage = annotatedImages[p]!;
      } else {
        selectedImage = p;
      }
    } else {
      // Check if current selectedImage still exists in imageFilePaths
      String currentOriginalPath = selectedImage;
      for (var entry in annotatedImages.entries) {
        if (entry.value == selectedImage) {
          currentOriginalPath = entry.key;
          break;
        }
      }
      
      if (selectedImage != '' && !imageFilePaths.contains(currentOriginalPath)) {
        // Current selected image was removed, select first available or clear
        if (imageFilePaths.isNotEmpty) {
          if (annotatedImages.containsKey(imageFilePaths[0])) {
            selectedImage = annotatedImages[imageFilePaths[0]]!;
          } else {
            selectedImage = imageFilePaths[0];
          }
        } else {
          selectedImage = '';
        }
      } else if (selectedImage == '' && imageFilePaths.isNotEmpty) {
        // Only set initial selection if no image is currently selected
        if (annotatedImages.containsKey(imageFilePaths[0])) {
          selectedImage = annotatedImages[imageFilePaths[0]]!;
        } else {
          selectedImage = imageFilePaths[0];
        }
      }
    }
    setState(() {});
  }

  // Discard snag creation
  bool _hasUnsavedChanges() {
    return nameController.text.isNotEmpty ||
           descriptionController.text.isNotEmpty ||
           assigneeController.text.isNotEmpty ||
           locationController.text.isNotEmpty ||
           imageFilePaths.isNotEmpty ||
           snagCategory != null ||
           (snagTags?.isNotEmpty ?? false);
  }

  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
      context: this.context,
      builder: (context) => AlertDialog(
        title: Text('Discard ${AppStrings.snag()}?'),
        content: Text('You have unsaved changes. Do you want to discard this ${AppStrings.snag().toLowerCase()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    ) ?? false;
  }

  void saveAnnotatedImage(String originalPath, String path) {
    setState(() {
      // find the actual original image path
      String originalPath_ = originalPath;

      // check if originalPath is actually an annotated image
      for (var entry in annotatedImages.entries) {
        if (entry.value == originalPath){
          originalPath_ = entry.key;
          break;
        }
      }
      annotatedImages[originalPath_] = path;
      onChange(p: originalPath_);
    });
  }

  void clearInputs() {
    nameController.clear();
    dueDateController.clear();
    assigneeController.clear();
    locationController.clear();
    priorityController.clear();
    imageFilePaths = [];
    annotatedImages.clear();
    snagCategory = null;
    snagTags = [];
  }

  @override
  Widget build(BuildContext context) {
    
    selectProject();

    final currentProject = selectedProjectId != null
      ? ProjectService.getProject(ref, selectedProjectId!)
      : null;

    // TODO replace WillPopScope
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges()) return await _showDiscardDialog();
        return true;
      },
      child: Scaffold(
        // AppBar is only shown if user is using QUICK ADD
        appBar: widget.projectId == null
          ? AppBar(
            title: Text(AppStrings.snagCreate()),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (_hasUnsavedChanges()) {
                  final shouldDiscard = await _showDiscardDialog();
                  if (shouldDiscard) {
                    Navigator.pop(context);
                  }
                } else {
                  Navigator.pop(context);
                }
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
                    if (widget.projectId == null) ... [
                      buildDropdownInputForObjects(
                        label: 'Projects',
                        options: filteredProjects,
                        selectedProject: null,
                        onChanged: (Project? value) {
                          setState(() {
                            selectedProjectId = value!.id;
                          });
                        clearInputs();
                        }
                      ),
                      const SizedBox(height: 28.0),
                    ],

                    // If image is empty, show image input
                    if (imageFilePaths.isEmpty) ... [
                      buildImageInput_V3(context, onChange, imageFilePaths),
                    ] else ... [
                      // so if image is not empty then show image with an edit icon
                      showImageWithEditAbility(context, selectedImage != '' ? selectedImage : imageFilePaths[0], saveAnnotatedImage)
                    ],

                    const SizedBox(height: 14.0),
                    if (imageFilePaths.isNotEmpty) ... [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildImageShowcase(context, onChange, (){}, imageFilePaths),
                          if (imageFilePaths.length < 5) ... [
                            buildImageInput_V3(context, onChange, imageFilePaths, large: false)
                          ],
                        ],
                      ),
                      const SizedBox(height: 28.0),
                    ],
                    buildTextInput(AppStrings.snagName(), AppStrings.snagNameExample, nameController),
                    const SizedBox(height: 28.0),
                    buildLongTextInput("Description", "E.g. Explain the ${AppStrings.snag()}", descriptionController),
                    const SizedBox(height: 28.0),
                    buildTextInput(AppStrings.assignee, AppStrings.assigneeExample, assigneeController),
                    const SizedBox(height: 28.0),
                    buildTextInput(AppStrings.projectLocation, AppStrings.snagLocationExample, locationController),
                    const SizedBox(height: 28.0),
                    buildDatePickerInput(context, 'Due Date', formatDate(DateTime.now()), dueDateController),
                    const SizedBox(height: 28.0),
                    buildCustomSegmentedControl(label: 'Priority', options: priorityOptions, selectedNotifier: selectedPriorityOption),
                    const SizedBox(height: 28.0),
                    buildCustomSegmentedControl(label: 'Status', options: statusOptions, selectedNotifier: selectedStatusOption),
                    const SizedBox(height: 28.0),
              
                    if (selectedProjectId != null) ... [
                      ObjectSelector(
                        label: AppStrings.category,
                        pluralLabel: AppStrings.categories,
                        hint: AppStrings.categoryHint(),
                        options: currentProject?.createdCategories ?? [],
                        getName: (cat) => cat.name,
                        getColor: (cat) => cat.color,
                        onCreate: (name, color) {
                          setState(() {
                            if (currentProject == null) return;
                            final updatedProject = currentProject.copyWith(
                              createdCategories: [
                                cii.Category(name: name, color: color),
                                ... currentProject.createdCategories ?? []
                              ]
                            );
                            ProjectService.updateProject(ref, updatedProject);
                            cii.Category.sortCategories(updatedProject.createdCategories!);
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
                        hint: AppStrings.tagHint(),
                        options: currentProject?.createdTags ?? [],
                        getName: (tag) => tag.name,
                        getColor: (tag) => tag.color,
                        onCreate: (name, color) {
                          setState(() {
                            if (currentProject == null) return;
                            final updatedProject = currentProject.copyWith(
                              createdTags: [
                                Tag(name: name, color: color),
                                ... currentProject.createdTags ?? []
                              ]
                            );
                            ProjectService.updateProject(ref, updatedProject);
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

                    buildTextButton(AppStrings.snagCreate(), () {
                      if (currentProject == null || !TierService.instance.canCreateSnag(ProjectService.getSnagCount(ref, currentProject.id!))) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Max number of ${AppStrings.snags()} per project reached (${TierLimits.free.maxSnagsPerProject})'))
                        );
                        return;
                      }
                      createSnag();
                    }),
                    const SizedBox(height: 12.0),
                  ],
              )
            )
          )
        )
    );
  }
}
