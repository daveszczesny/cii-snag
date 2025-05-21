import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController assigneeController = TextEditingController();

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

    selectedStatusOption.addListener(() {
      setState(() {
        widget.snag.status = Status.values.firstWhere(
          (s) => s.name == selectedStatusOption.value,
          orElse: () => Status.todo
        );
        widget.projectController.saveProject();
        widget.onStatusChanged!();
      });
    });
  }

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

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Widget snagDetailEditable(BuildContext context) {
    final name = widget.snag.name; 
    final description = widget.snag.description != '' ? widget.snag.description : 'No Description';
    final id = widget.snag.getId; // not nullable
    final dateCreated = formatDate(widget.snag.dateCreated);
    final assignee = widget.snag.assignee != '' ? widget.snag.assignee : 'Unassigned';
    final location = widget.snag.location != '' ? widget.snag.location : 'No Location';
    const double gap = 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextDetail('ID', id),
        const SizedBox(height: gap),
        buildEditableTextDetail(context, 'Snag Name', name, nameController,
          onChanged: () {
            setState(() {
              widget.snag.setName(nameController.text);
              widget.onStatusChanged!();
            });
          }),
        const SizedBox(height: gap),
        buildEditableTextDetail(context, 'Description', description, descriptionController,
          onChanged: () {
            setState(() {
              widget.snag.setDescription(descriptionController.text);
            });
          }),
        const SizedBox(height: gap),
        buildTextDetail('Date Created', dateCreated),
        const SizedBox(height: gap),
        buildEditableTextDetail(context, 'Assignee', assignee, assigneeController,
          onChanged: () {
            setState(() {
              widget.snag.setAssignee(assigneeController.text);
              widget.onStatusChanged!();
            });
          }),
        const SizedBox(height: gap),
        buildEditableTextDetail(context, 'Location', location, locationController,
          onChanged: () {
            setState(() {
              widget.snag.setLocation(locationController.text);
            });
          }),
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
      ],
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.snag.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // edit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () { isEditable = !isEditable; setState(() {}); },
                        child: const Icon(Icons.edit, color: Colors.black, size: 24.0),
                      ),
                    ]
                  ),
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
                        buildImageShowcase(context, onChange, saveAnnotatedImage, imageFilePaths),
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

                  const Divider(height: 20, thickness: 0.5, color: Colors.grey),

                  // Status

                  // Category and Tags
                  if (widget.snag.categories.isNotEmpty) ... [
                    const Text(AppStrings.category),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.snag.categories.map((cat) {
                        return GestureDetector(
                          onTap: () => _showCategoryModal(context),
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 90,
                              maxWidth: 140,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: cat.color,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat.name,
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Roboto',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          )
                        );
                    }).toList()),
                    const SizedBox(height: 28.0)
                  ],

                  if (widget.snag.tags.isNotEmpty) ... [
                    const Text(AppStrings.tags),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: widget.snag.tags.map((tag) {
                        return GestureDetector(
                          onTap: () => {},
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 90,
                              maxWidth: 140,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: tag.color,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              tag.name,
                              style: const TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Roboto',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          )
                        );
                    }).toList()),
                    const SizedBox(height: 28.0)
                  ],
                ],
              ),
            )
          ]
        )
      ),
    );
  }
}