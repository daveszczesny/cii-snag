import 'package:cii/models/priority.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/services/snag_service.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/snag/widgets/snag_app_bar.dart';
import 'package:cii/view/snag/widgets/snag_category_section.dart';
import 'package:cii/view/snag/widgets/snag_due_date_alert.dart';
import 'package:cii/view/snag/widgets/snag_form_section.dart';
import 'package:cii/view/snag/widgets/snag_image_section.dart';
import 'package:cii/view/snag/widgets/snag_status_section.dart';
import 'package:cii/view/snag/widgets/snag_tag_section.dart';
import 'package:cii/view/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnagDetail extends ConsumerStatefulWidget {
  final String projectId;
  final String snagId;
  final VoidCallback? onStatusChanged;

  const SnagDetail({super.key, required this.projectId, required this.snagId, this.onStatusChanged});

  @override
  ConsumerState<SnagDetail> createState() => _SnagDetailState();
}

class _SnagDetailState extends ConsumerState<SnagDetail> {

  // Text editing controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController= TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController assigneeController = TextEditingController();
  final TextEditingController reviewedByController = TextEditingController();
  final TextEditingController finalremarksController = TextEditingController();

  late ValueNotifier<String> selectedStatusOption;
  late ValueNotifier<String> selectedPriorityOption;
  final List<String> statusOptions = Status.values.map((e) => e.name).toList(); // get the name of each status
  final List<String> priorityOptions = Priority.values.map((p) => p.name).toList(); // get the name of each priority

  List<String> imageFilePaths = [];
  String selectedImage = '';
  bool isEditable = false;

  @override
  void initState() {
    super.initState();

    selectedStatusOption = ValueNotifier<String>(statusOptions.first);
    selectedPriorityOption = ValueNotifier<String>(priorityOptions.first);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListeners();
    });
  }

  void _setupListeners() {
    Snag snag = SnagService.getSnag(ref, widget.snagId);
    setState(() {imageFilePaths = List<String>.from(snag.imagePaths ?? []);});

    selectedPriorityOption.addListener(() async {
      snag = SnagService.getSnag(ref, widget.snagId);

      final newPriority = Priority.values.firstWhere(
        (p) => p.name == selectedPriorityOption.value,
        orElse: () => Priority.low
      );

      // Update snag with the priority
      if (snag.priority.name == newPriority.name) return; // no need to update?
      final Snag updatedSnag = snag.copyWith(priority: newPriority);
      SnagService.updateSnag(ref, updatedSnag);
    });

    selectedStatusOption.addListener(() async {
      
      // Ensure snag is up-to-date in the listener
      snag = SnagService.getSnag(ref, widget.snagId);

      final newStatus = Status.values.firstWhere(
        (s) => s.name == selectedStatusOption.value,
        orElse: () => Status.todo
      );

      // If status is completed, show the remarks dialog
      if (newStatus == Status.completed) {
        final previousStatus = snag.status.name;

        await buildFinalRemarksWidget(
          context,
          snag,
          () {
            snag.status = newStatus;
            // TODO: What is this?
            final Project project = ProjectService.getProject(ref, widget.projectId);
            ProjectService.updateProject(ref, project);
            widget.onStatusChanged?.call();
            setState(() {});
          },
          List<String>.from(snag.finalImagePaths ?? []),
          ref,
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.8,
        );

        if (snag.status != Status.completed) {
          // User cancelled the completion, revert the selected status
          selectedStatusOption.value = previousStatus;
        }
      } else {
        final Snag updatedSnag = snag.copyWith(
          status: newStatus
        );
        SnagService.updateSnag(ref, updatedSnag);
        setState(() {
          widget.onStatusChanged?.call();
        });
      }
    });
  }

  void setAsMainImage(String selectedImagePath) {
    final Snag snag = SnagService.getSnag(ref, widget.snagId);
    String originalPath = selectedImagePath;
    for (var entry in (snag.annotatedImagePaths ?? {}).entries) {
      if (entry.value == selectedImagePath) {
        originalPath = entry.key;
        break;
      }
    }

    if ((snag.imagePaths ?? []).contains(originalPath)) {
      var imagePaths = snag.imagePaths!;
      imagePaths.remove(originalPath);
      imagePaths.insert(0, originalPath);
      final updatedSnag = snag.copyWith(imagePaths: imagePaths);
      SnagService.updateSnag(ref, updatedSnag);
      setState(() {
        imageFilePaths = snag.imagePaths ?? [];
        selectedImage = '';
        widget.onStatusChanged?.call();
      });
    }
  }

  // image related methods
  void onChange({String p = ""}) {
    final Snag snag = SnagService.getSnag(ref, widget.snagId);
    final annotatedImages = snag.annotatedImagePaths;

    if (p != "") {
      // User clicked on a specific image - set it as selected
      if ((annotatedImages ?? {}).containsKey(p)) {
        selectedImage = annotatedImages![p]!;
      } else {
        selectedImage = p;
      }
    } else {
      // Update snag object
      final updatedSnag = snag.copyWith(imagePaths: imageFilePaths);
      SnagService.updateSnag(ref, updatedSnag);

      // check if current selectedImage still exists
      String originalPath = selectedImage;
      for (var entry in (annotatedImages ?? {}).entries) {
        if (entry.value == selectedImage) {
          originalPath = entry.key;
          break;
        }
      }

      // clear selectedimage if it no longer exists
      if (selectedImage != "" && !imageFilePaths.contains(originalPath)) {
        selectedImage = "";
      }

      if (selectedImage == "" && imageFilePaths.isNotEmpty) {
        final annotatedMap = annotatedImages ?? {};
        if (annotatedMap.containsKey(imageFilePaths[0])) {
          selectedImage = annotatedMap[imageFilePaths[0]]!;
        } else {
          selectedImage = imageFilePaths[0];
        }
      }
    }

    setState(() {});
    widget.onStatusChanged?.call();
  }

  void saveAnnotatedImage(String originalPath, String path) {
    final Snag snag = SnagService.getSnag(ref, widget.snagId);
    var annotedPaths = Map<String, String>.from(snag.annotatedImagePaths ?? {});
    annotedPaths[originalPath] = path;
    final updatedSnag = snag.copyWith(
      annotatedImagePaths: annotedPaths
    );
    SnagService.updateSnag(ref, updatedSnag);
    setState(() {
      onChange(p: originalPath);
    });
  }

  String getAnnotatedImage(String path) {
    final Snag snag = SnagService.getSnag(ref, widget.snagId);
    final annotatedImages = snag.annotatedImagePaths;
    final annotatedMap = annotatedImages ?? {};
    if (annotatedMap.isNotEmpty) {
      if (annotatedMap.containsKey(path)) {
        return annotatedMap[path]!;
      }
    }
    return path;
  }


  @override
  Widget build(BuildContext context) {

    final snag = SnagService.getSnag(ref, widget.snagId);

    if (imageFilePaths.isEmpty) {
      imageFilePaths = snag.imagePaths ?? [];
    }

    if (selectedStatusOption.value != snag.status.name) {
      selectedStatusOption.value = snag.status.name;
    }
    if (selectedPriorityOption.value != snag.priority.name) {
      selectedPriorityOption.value = snag.priority.name;
    }


    Map<String, TextEditingController> controllers = {
      "name": nameController,
      "description": descriptionController,
      "assignee": assigneeController,
      "location": locationController,
      "dueDate": dueDateController,
      "reviewedBy": reviewedByController,
      "finalRemarks": finalremarksController
    };

    final Project project = ProjectService.getProject(ref, widget.projectId);
    return Scaffold(
      appBar: SnagAppBar(
        snag: snag,
        isEditable: isEditable,
        controllers: controllers,
        onToggleEdit: () => setState(() => isEditable = !isEditable),
        onStatusChanged: widget.onStatusChanged,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SnagImageSection(
                    imageFilePaths: imageFilePaths,
                    selectedImage: selectedImage,
                    onChange: onChange,
                    saveAnnotatedImage: saveAnnotatedImage,
                    setAsMainImage: setAsMainImage,
                    getAnnotatedImage: getAnnotatedImage,
                  ),

                  // Alert on due date
                  SnagDueDateAlert(snag: snag), 

                  // Status
                  SnagStatusSection(label: "Status", statusOptions: statusOptions, selectedStatusOption: selectedStatusOption, isEditable: isEditable),
                  const SizedBox(height: 20.0),
                  SnagStatusSection(label: "Priority", statusOptions: priorityOptions, selectedStatusOption: selectedPriorityOption, isEditable: isEditable),
                  const SizedBox(height: 28.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SnagFormSection(
                          snag: snag,
                          isEditable: isEditable,
                          controllers: controllers
                        ),
                      ],
                    )
                  ),

                  if ((snag.finalImagePaths ?? []).isNotEmpty) ... [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16.0),
                          const Text("Final Images", style: TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: "Roboto")),
                          buildImageShowcase(
                            context,
                            ({String p = ""}) { setState(() {}); },
                            () {},
                            snag.finalImagePaths ?? []
                          )
                        ],
                      )
                    ),
                  ],
                  const SizedBox(height: 28.0),
                  const Divider(height: 20, thickness: 0.5, color: Colors.grey),
                  const SizedBox(height: 28.0),
                  SnagCategorySection(project: project, snag: snag, onChanged: () => setState(() => widget.onStatusChanged?.call())),
                  const SizedBox(height: 24.0),
                  SnagTagSection(project: project, snag: snag, onChanged: () => setState(() => widget.onStatusChanged?.call()))
                ],
              ),
            ),
            const SizedBox(height: 24.0),
          ]
        )
      ),
    );
  }
}
