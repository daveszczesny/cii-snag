import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/selector.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';

class SnagDetail extends StatefulWidget {
  final SingleProjectController projectController;
  final SnagController snag;
  final VoidCallback? onStatusChanged;

  const SnagDetail({super.key, required this.projectController, required this.snag, this.onStatusChanged});

  @override
  State<SnagDetail> createState() => _SnagDetailState();
}

class _SnagDetailState extends State<SnagDetail> {

  // Text editing controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController= TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController assigneeController = TextEditingController();
  final TextEditingController reviewedByController = TextEditingController();
  final TextEditingController finalremarksController = TextEditingController();

  late ValueNotifier<String> selectedStatusOption;
  final List<String> statusOptions = Status.values.map((e) => e.name).toList(); // get the name of each status

  late List<String> imageFilePaths;
  String selectedImage = '';

  bool isEditable = false;

  @override
  void initState() {
    super.initState();
    imageFilePaths = widget.snag.imagePaths;

    final currentStatus = widget.snag.status.name;

    final initialStatus = statusOptions.firstWhere(
      (s) => s.toLowerCase() == currentStatus.toLowerCase(),
      orElse: () => statusOptions.first
    );
    selectedStatusOption = ValueNotifier<String>(initialStatus);

    selectedStatusOption.addListener(() async {
      final newStatus = Status.values.firstWhere(
        (s) => s.name == selectedStatusOption.value,
        orElse: () => Status.todo
      );

      // If status is completed, show the remarks dialog
      if (newStatus == Status.completed) {
        await buildFinalRemarksWidget(
          context,
          widget.snag,
          widget.projectController,
          () {
            widget.snag.status = newStatus;
            widget.projectController.saveProject();
            widget.onStatusChanged!();
            setState(() {});
          },
          List<String>.from(widget.snag.finalImagePaths),
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.8,
        );
      } else {
        setState(() {
          widget.snag.status = newStatus;
          widget.projectController.saveProject();
          widget.onStatusChanged!();
        });
      }
    });
  }

  void setAsMainImage(String selectedImagePath) {
    String originalPath = selectedImagePath;
    for (var entry in widget.snag.annotatedImagePaths.entries) {
      if (entry.value == selectedImagePath) {
        originalPath = entry.key;
        break;
      }
    }

    if (widget.snag.imagePaths.contains(originalPath)) {
      widget.snag.imagePaths.remove(originalPath);
      widget.snag.imagePaths.insert(0, originalPath);
      widget.projectController.saveProject();
      setState(() {
        imageFilePaths = widget.snag.imagePaths;
        selectedImage = '';
        widget.onStatusChanged!();
      });
    }
  }

  // image related methods
  void onChange({String p = ''}) {
    final annotatedImages = widget.snag.annotatedImagePaths;
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
    widget.onStatusChanged!();
    setState(() {});
  }

  void saveAnnotatedImage(String originalPath, String path) {
    setState(() {
      widget.snag.annotatedImagePaths[originalPath] = path;
      onChange(p: originalPath);
    });
  }

  String getAnnotatedImage(String path) {
    final annotatedImages = widget.snag.annotatedImagePaths;
    if (annotatedImages.isNotEmpty) {
      if (annotatedImages.containsKey(path)) {
        return annotatedImages[path]!;
      }
    }
    return path;
  }
// -----------------------------------------------

  void _showCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      builder: (BuildContext context) {
        final categories = widget.projectController.getCategories!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: FractionallySizedBox(
            heightFactor: 0.7,
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return ListTile(
                  title: Text(cat.name),
                  onTap: () {
                    setState(() {
                      widget.snag.setCategory(cat);
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      }
    );
  }

  Widget snagDetailEditable(BuildContext context) {
    final name = widget.snag.name; 
    final description = widget.snag.description != '' ? widget.snag.description : 'No Description';
    final id = widget.snag.getId; // not nullable
    final dateCreated = formatDate(widget.snag.dateCreated);
    final assignee = widget.snag.assignee != '' ? widget.snag.assignee : 'Unassigned';
    final location = widget.snag.location != '' ? widget.snag.location : 'No Location';
    final dueDate = widget.snag.getDueDate != null ? widget.snag.getDueDateString! : 'No Due Date';
    final reviewedBy = widget.snag.reviewedBy != '' ? widget.snag.reviewedBy : 'No Reviewer';
    final finalRemarks = widget.snag.finalRemarks != '' ? widget.snag.finalRemarks : 'No Final Remarks';

    const double gap = 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextDetail('ID', id),
        const SizedBox(height: gap),
        buildTextInput(AppStrings.snagName(), name, nameController),
        const SizedBox(height: gap),
        buildLongTextInput('Description', description, descriptionController),
        const SizedBox(height: gap),
        buildTextDetail('Date Created', dateCreated),
        const SizedBox(height: gap),
        buildTextInput('Assignee', assignee, assigneeController),
        const SizedBox(height: gap),
        buildTextInput('Location', location, locationController),
        const SizedBox(height: gap),
        buildDatePickerInput(context, 'Due Date', dueDate, dueDateController),
        const SizedBox(height: gap),
        if (widget.snag.finalRemarks.isNotEmpty) ... [
          const SizedBox(height: gap),
          buildTextInput("Reviewed By", reviewedBy, reviewedByController),
          const SizedBox(height: gap),
          buildTextInput("Final Remarks", finalRemarks, finalremarksController),
        ]
      ],
    );
  }

  Widget snagDetailNoEdit() {
    final name = widget.snag.name; 
    final description = widget.snag.description != '' ? widget.snag.description : 'No Description';
    final id = widget.snag.getId; // not nullable
    final dateCreated = formatDate(widget.snag.dateCreated);
    final assignee = widget.snag.assignee != '' ? widget.snag.assignee : 'Unassigned';
    final location = widget.snag.location != '' ? widget.snag.location : 'No Location';
    final dueDate = widget.snag.getDueDate != null ? widget.snag.getDueDateString! : 'No Due Date';
    final reviewedBy = widget.snag.reviewedBy != '' ? widget.snag.reviewedBy : 'No Reviewer';
    final finalRemarks = widget.snag.finalRemarks != '' ? widget.snag.finalRemarks : 'No Final Remarks';
    var dueDateSubtext = '';
    var dueDateIcon;


    if (widget.snag.getDueDate != null) {
      final dueDateTime = widget.snag.getDueDate!;
      final now = DateTime.now();
      final diff = dueDateTime.difference(now).inDays;
      const iconSize = 16.0;

      if (diff < 0) {
        dueDateSubtext = 'Overdue by ${diff.abs()} days';
        dueDateIcon = Icon(Icons.warning, size: iconSize, color: Colors.red.withOpacity(0.8));
      } else if (diff == 0) {
        dueDateSubtext = 'Due today';
        dueDateIcon = Icon(Icons.schedule, size: iconSize, color: Colors.orange.withOpacity(0.8));
      } else {
        dueDateSubtext = '${diff + 1} days left';
        if (diff <= 7) {
          dueDateIcon = Icon(Icons.schedule, size: iconSize, color: Colors.orange.withOpacity(0.8));
        } else if (diff <= 14) {
          dueDateIcon = Icon(Icons.schedule, size: iconSize, color: Colors.green.withOpacity(0.8));
        } else {
          dueDateIcon = null; // No icon for more than 14 days
        }
      }

    }

    const double gap = 16;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextDetail('ID', id),
        const SizedBox(height: gap),
        buildTextDetail('Snag Name', name),
        const SizedBox(height: gap),
        buildJustifiedTextDetail('Description', description),
        const SizedBox(height: gap),
        buildTextDetail('Date Created', dateCreated),
        const SizedBox(height: gap),
        buildTextDetail('Assignee', assignee),
        const SizedBox(height: gap),
        buildTextDetail('Location', location),
        const SizedBox(height: gap),
        buildTextDetailWithIcon('Due Date', dueDate, dueDateIcon, subtext: dueDateSubtext),
        if (widget.snag.status.name == Status.completed.name) ... [
          const SizedBox(height: gap),
          buildTextDetail('Reviewed By', reviewedBy),
          const SizedBox(height: gap),
          buildTextDetail('Final remarks', finalRemarks),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.snag.name),
        leading: isEditable == false ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ) : GestureDetector(
            onTap: () {
              // cancel the edit
              // check if anything has changed
              if (
                (nameController.text != '' && nameController.text != widget.snag.name) ||
                (descriptionController.text != '' && descriptionController.text != widget.snag.description) ||
                (assigneeController.text != '' && assigneeController.text != widget.snag.assignee) ||
                (locationController.text != '' && locationController.text != widget.snag.location) ||
                (dueDateController.text != '' && dueDateController.text != widget.snag.getDueDateString)
              ) {
                // show a dialog to confirm
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Discard Changes'),
                      content: const Text('Are you sure you want to discard the changes?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel')
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              isEditable = !isEditable;
                            });
                          },
                          child: const Text('Discard')
                        )
                      ],
                    );
                  }
                );
              } else {
                isEditable = !isEditable;
              }
              setState(() {});
            },
            child: const Icon(Icons.close)
          ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isEditable) {
                       // set snag details
                    final newName = nameController.text;
                    // name isn't nullable
                    if (newName != '') {
                      widget.snag.setName(newName);
                    }
                    final newDescription = descriptionController.text;
                    widget.snag.setDescription(newDescription);
                    final newAssignee = assigneeController.text;
                    widget.snag.setAssignee(newAssignee);
                    final newLocation = locationController.text;
                    widget.snag.setLocation(newLocation);
                    final newDueDate = dueDateController.text;
                    if (newDueDate.isNotEmpty) {
                      widget.snag.setDueDate(newDueDate);
                    }

                    if (widget.snag.status.name == Status.completed.name) {
                      final newReviewedBy = reviewedByController.text;
                      final newFinalRemarks = finalremarksController.text;
                      widget.snag.setReviewedBy(newReviewedBy);
                      widget.snag.setFinalRemarks(newFinalRemarks);
                    }
                    isEditable = !isEditable;
                    widget.projectController.saveProject();
                    widget.onStatusChanged!();
                  } else {
                    nameController.text = widget.snag.name;
                    descriptionController.text = widget.snag.description;
                    assigneeController.text = widget.snag.assignee;
                    locationController.text = widget.snag.location;
                    dueDateController.text = widget.snag.getDueDateString ?? '';
                    isEditable = !isEditable;
                  }
                });
              },
              child: isEditable ?
                const Icon(Icons.check)
                : const Text('Edit')
            )
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  if (imageFilePaths.isEmpty || File(imageFilePaths[0]).existsSync() == false) ... [
                    buildMultipleImageInput_V2(context, imageFilePaths, onChange),
                  ] else ... [
                    showImageWithEditAbility(context, selectedImage != '' ? selectedImage : getAnnotatedImage(imageFilePaths[0]), saveAnnotatedImage)
                  ],

                  const SizedBox(height: 14.0),

                  // small image showcase
                  if (imageFilePaths.isNotEmpty && File(imageFilePaths[0]).existsSync()) ... [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildImageShowcase(context, onChange, saveAnnotatedImage, imageFilePaths, onLongPress: setAsMainImage),
                        if (imageFilePaths.length < 5) ... [
                          buildMultipleImageInput_V2(context, imageFilePaths, onChange, large: false),
                        ],
                      ],
                    ),
                    const SizedBox(height: 28.0),
                  ],

                  buildCustomSegmentedControl(label: 'Status', options: statusOptions, selectedNotifier: selectedStatusOption),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isEditable) ... [
                          snagDetailEditable(context)
                        ] else ... [
                          snagDetailNoEdit()
                        ]
                      ],
                    )
                  ),

                  if (widget.snag.finalImagePaths.isNotEmpty && File(widget.snag.finalImagePaths[0]).existsSync()) ... [
                    const SizedBox(height: 16.0),
                    const Text('Final Images', style: TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
                    const SizedBox(height: 8.0),
                    buildImageShowcase(
                      context,
                      ({String p = ''}) {setState(() {});},
                      () {},
                      widget.snag.finalImagePaths
                    ),
                  ],

                  const SizedBox(height: 28.0),
                  const Divider(height: 20, thickness: 0.5, color: Colors.grey),
                  const SizedBox(height: 28.0),

                  // Category and Tags
                  ObjectSelector(
                    label: AppStrings.category,
                    pluralLabel: AppStrings.categories,
                    hint: AppStrings.tagHint(),
                    options: widget.projectController.getCategories ?? [],
                    getName: (cat) => cat.name,
                    getColor: (cat) => cat.color,
                    allowMultiple: false,
                    onCreate: (name, color) {
                      setState(() {
                        widget.projectController.addCategory(capitilize(name), color);
                      });
                    },
                    onSelect: (cat) {
                      setState(() {
                        widget.snag.setCategory(cat);
                        widget.projectController.saveProject();
                        widget.onStatusChanged!();
                      });
                    },
                    hasColorSelector: true,
                  ),

                  const SizedBox(height: 24.0),
                  const Text(AppStrings.tags),
                  ObjectSelector(
                    label: AppStrings.tag,
                    pluralLabel: AppStrings.tags,
                    hint: AppStrings.tagHint(),
                    options: widget.projectController.getTags ?? [],
                    getName: (tag) => tag.name,
                    getColor: (tag) => tag.color,
                    allowMultiple: true, // Enable multi-select
                    onCreate: (name, color) {
                      setState(() {
                        widget.projectController.addTag(capitilize(name), color);
                      });
                    },
                    onSelect: (tag) {
                      setState(() {
                        // Check if tag is already in snag
                        if (widget.snag.tags.contains(tag)) {
                          // Remove tag from snag
                          widget.snag.snag.tags?.remove(tag);
                        } else {
                          // Add tag to snag
                          widget.snag.setTag(tag);
                        }
                      });
                    },
                    hasColorSelector: true,
                  ),
                ],
              ),
            )
          ]
        )
      ),
    );
  }
}