import 'package:cii/models/category.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/snag.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/services/snag_service.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/selector.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
  final List<String> statusOptions = Status.values.map((e) => e.name).toList(); // get the name of each status

  List<String> imageFilePaths = [];
  String selectedImage = '';

  bool isEditable = false;

  @override
  void initState() {
    super.initState();

    // final currentStatus = widget.snag.status.name;
    // final initialStatus = statusOptions.firstWhere(
      // (s) => s.toLowerCase() == currentStatus.toLowerCase(),
      // orElse: () => statusOptions.first
    // );
    // Changed from initialStatus
    selectedStatusOption = ValueNotifier<String>(statusOptions.first);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupStatusListener();
    });
  }

  void _setupStatusListener() {
    final Snag snag = SnagService.getSnag(ref, widget.snagId);
    setState(() {imageFilePaths = List<String>.from(snag.imagePaths ?? []);});

    selectedStatusOption.addListener(() async {
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
// -----------------------------------------------


  Widget snagDetailEditable(BuildContext context) {
    final Snag snag = SnagService.getSnag(ref, widget.snagId);
    final name = snag.name; 
    final description = !isNullorEmpty(snag.description)
      ? snag.description
      : 'No Description';
    final id = snag.id; // not nullable
    final dateCreated = formatDate(snag.dateCreated);
    final assignee = !isNullorEmpty(snag.assignee)
    ? snag.assignee!
    : 'Unassigned';
    final location = !isNullorEmpty(snag.location)
      ? snag.location!
      : 'No Location';
    final dueDate = snag.dueDate != null
      ? DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dueDate!)
      : 'No Due Date';
    final reviewedBy = !isNullorEmpty(snag.reviewedBy)
      ? snag.reviewedBy!
      : 'No Reviewer';
    final finalRemarks = !isNullorEmpty(snag.finalRemarks)
      ? snag.finalRemarks!
      : 'No Final Remarks';

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
        if (snag.status.name == Status.completed.name) ... [
          const SizedBox(height: gap),
          buildTextInput("Reviewed By", reviewedBy, reviewedByController),
          const SizedBox(height: gap),
          buildTextInput("Final Remarks", finalRemarks, finalremarksController),
        ]
      ],
    );
  }

  Widget snagDetailNoEdit() {
    final Snag snag = SnagService.getSnag(ref, widget.snagId);

    final name = snag.name; 
    final description = !isNullorEmpty(snag.description) ? snag.description! : 'No Description';
    final id = snag.id; // not nullable
    final dateCreated = formatDate(snag.dateCreated);
    final assignee = !isNullorEmpty(snag.assignee) ? snag.assignee! : 'Unassigned';
    final location = !isNullorEmpty(snag.location) ? snag.location! : 'No Location';
    final dueDate = snag.dueDate != null
      ? DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dueDate!)
      : 'No Due Date';
    final reviewedBy = !isNullorEmpty(snag.reviewedBy) ? snag.reviewedBy! : 'No Reviewer';
    final finalRemarks = !isNullorEmpty(snag.finalRemarks) ? snag.finalRemarks! : 'No Final Remarks';
    final dateClosed = snag.dateClosed != null
      ? DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dateClosed!)
      : '-';
    var dueDateSubtext = '';
    var dueDateIcon;


    if (snag.dueDate != null && snag.status.name != Status.completed.name) {
      final dueDateTime = snag.dueDate!;
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
        buildTextDetail('${AppStrings.snag()} Name', name),
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
        if (snag.status.name == Status.completed.name) ... [
          const SizedBox(height: gap),
          buildTextDetail('Date Closed', dateClosed),
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

    final snag = SnagService.getSnag(ref, widget.snagId);

    if (imageFilePaths.isEmpty) {
      imageFilePaths = snag.imagePaths ?? [];
    }

    if (selectedStatusOption.value != snag.status.name) {
      selectedStatusOption.value = snag.status.name;
    }

    final Project project = ProjectService.getProject(ref, widget.projectId);
    return Scaffold(
      appBar: AppBar(
        title: Text(snag.name),
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
                (nameController.text != '' && nameController.text != snag.name) ||
                (descriptionController.text != '' && descriptionController.text != snag.description) ||
                (assigneeController.text != '' && assigneeController.text != snag.assignee) ||
                (locationController.text != '' && locationController.text != snag.location) ||
                (dueDateController.text != '' && snag.dueDate != null && dueDateController.text != DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dueDate!))
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

                final Snag updatedSnag = snag.copyWith(
                  name: nameController.text != '' ? nameController.text : snag.name,
                  description: descriptionController.text,
                  assignee: assigneeController.text,
                  location: locationController.text,
                  dueDate: dueDateController.text.isNotEmpty ? parseDate(dueDateController.text) : snag.dueDate,
                  reviewedBy: reviewedByController.text,
                  finalRemarks: finalremarksController.text,
                );

                SnagService.updateSnag(ref, updatedSnag);

                setState(() {
                  if (isEditable) {
                     // set snag details
                    isEditable = !isEditable;
                    widget.onStatusChanged?.call();
                  } else {
                    nameController.text = snag.name;
                    // TODO: Is ?? "" a problem?
                    descriptionController.text = snag.description ?? "";
                    assigneeController.text = snag.assignee ?? "";
                    locationController.text = snag.location ?? "";
                    dueDateController.text = snag.dueDate != null
                      ? DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dueDate!)
                      : "";
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
                  if (imageFilePaths.isEmpty) ... [
                    buildImageInput_V3(context, onChange, imageFilePaths)
                  ] else ... [
                    showImageWithEditAbility(context, selectedImage != '' ? selectedImage : getAnnotatedImage(imageFilePaths[0]), saveAnnotatedImage)
                  ],

                  const SizedBox(height: 14.0),

                  // small image showcase
                  if (imageFilePaths.isNotEmpty) ... [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildImageShowcase(context, onChange, saveAnnotatedImage, imageFilePaths, onLongPress: setAsMainImage),
                        if (imageFilePaths.length < 5) ... [
                          buildImageInput_V3(context, onChange, imageFilePaths, large: false)
                        ],
                      ],
                    ),
                    const SizedBox(height: 28.0),
                  ],

                  // Alert on due date
                  ValueListenableBuilder(
                    valueListenable: AppDueDateReminder.version,
                    builder: (context, _, __) {
                      if (snag.dueDate != null) {
                        final dueDateTime = snag.dueDate!;
                        final now = DateTime.now();
                        final diff = dueDateTime.difference(now).inDays;
                        
                        if (diff <= AppDueDateReminder.dueDateReminderDays - 1 && diff >= 0) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              border: Border.all(color: Colors.orange, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    diff == 0 ? 'Due today!' : 'Due in ${diff + 1} days',
                                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Status
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

                  if ((snag.finalImagePaths ?? []).isNotEmpty) ... [
                    const SizedBox(height: 16.0),
                    const Text('Final Images', style: TextStyle(color: Color(0xFF333333), fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto')),
                    const SizedBox(height: 8.0),
                    buildImageShowcase(
                      context,
                      ({String p = ''}) {setState(() {});},
                      () {},
                      snag.finalImagePaths ?? []
                    ),
                  ],

                  const SizedBox(height: 28.0),
                  const Divider(height: 20, thickness: 0.5, color: Colors.grey),
                  const SizedBox(height: 28.0),

                  // Category and Tags
                  ObjectSelector(
                    label: AppStrings.category,
                    pluralLabel: AppStrings.categories,
                    hint: AppStrings.categoryHint(),
                    options: project.createdCategories ?? [],
                    getName: (cat) => cat.name,
                    getColor: (cat) => cat.color,
                    allowMultiple: false,
                    onCreate: (name, color) {
                      setState(() {
                        final updatedProject = project.copyWith(
                          createdCategories: [
                            Category(name: capitilize(name), color: color),
                            ...project.createdCategories ?? []
                          ]
                        );
                        ProjectService.updateProject(ref, updatedProject);
                      });
                    },
                    onSelect: (cat) {
                      if (!isListNullorEmpty(snag.categories) && snag.categories!.where((c) => c.name == cat.name).toList().isNotEmpty) {
                        final Snag updatedSnag = snag.copyWith(
                          categories: []
                        );
                        SnagService.updateSnag(ref, updatedSnag);
                        setState(() {
                          widget.onStatusChanged?.call();
                        });
                      } else {
                        final Snag updatedSnag = snag.copyWith(
                          categories: [cat]
                        );
                        SnagService.updateSnag(ref, updatedSnag);
                        setState(() {
                          widget.onStatusChanged?.call();
                        });
                      }
                    },
                    hasColorSelector: true,
                    selectedItems: snag.categories,
                  ),

                  const SizedBox(height: 24.0),

                  // Tag Selector
                  ObjectSelector(
                    label: AppStrings.tag,
                    pluralLabel: AppStrings.tags,
                    hint: AppStrings.tagHint(),
                    options: project.createdTags ?? [],
                    getName: (tag) => tag.name,
                    getColor: (tag) => tag.color,
                    allowMultiple: true, // Enable multi-select
                    onCreate: (name, color) {
                      setState(() {
                        final updatedProject = project.copyWith(
                          createdTags: [
                            Tag(name: capitilize(name), color: color),
                            ...project.createdTags ?? []
                          ]
                        );
                        ProjectService.updateProject(ref, updatedProject);
                      });
                    },
                    onSelect: (tag) {
                      setState(() {
                        // Check if tag is already in snag
                        if (!isListNullorEmpty(snag.tags) && snag.tags!.where((t) => t.name == tag.name).toList().isNotEmpty) {
                          // Remove tag from snag
                          final Snag updatedSnag = snag.copyWith(
                            tags: snag.tags!.where((t) => t.name != tag.name).toList()
                          );
                          SnagService.updateSnag(ref, updatedSnag);
                        } else {
                          // Add tag to snag
                          final Snag updatedSnag = snag.copyWith(
                            tags: [...snag.tags!, tag]
                          );
                          SnagService.updateSnag(ref, updatedSnag);
                          widget.onStatusChanged?.call();
                        }
                      });
                    },
                    hasColorSelector: true,
                    selectedItems: snag.tags,
                  ),
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
