import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/selector.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectDetailPage extends StatefulWidget {
  final SingleProjectController projectController;
  const ProjectDetailPage({super.key, required this.projectController});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController clientController = TextEditingController();
  final TextEditingController contractorController = TextEditingController();
  final TextEditingController projectRefController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  late ValueNotifier<String> selectedStatusOption;
  final List<String> statusOptions = Status.values.map((e) => e.name).toList(); // get the name of each status

  bool isEditable = false;

  @override
  void initState() {
    super.initState();

    final currentStatus = widget.projectController.getStatus ?? statusOptions.first;

    final initialStatus = statusOptions.firstWhere(
      (s) => s.toLowerCase() == currentStatus.toLowerCase(),
      orElse: () => statusOptions.first
    );
    selectedStatusOption = ValueNotifier<String>(initialStatus);

    selectedStatusOption.addListener(() {
      widget.projectController.setStatus(selectedStatusOption.value);
      setState(() {});
    });
  }

  @override
  void dispose() {
    selectedStatusOption.dispose();
    super.dispose();
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
            widget.projectController.setMainImagePath('');
            setState(() {});
          },
          child: const Text('Delete')
        )
      ],
    );
  }

  // format dateCreated
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Widget projectDetailEditable(BuildContext context) {
    const double gap = 16;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        buildEditableTextDetail(context, 'Project Name', widget.projectController.getName!, nameController, onChanged: () {
          setState(() {
            widget.projectController.setName(nameController.text);
          });
        }),
        const SizedBox(height: gap),
        buildTextDetail('Date Created', formatDate(widget.projectController.getDateCreated!)), // date created is not editable
        const SizedBox(height: gap),
        buildEditableTextDetail(context, AppStrings.projectDescription, 
          widget.projectController.getDescription != '' ? widget.projectController.getDescription! : 'Empty description',
          descriptionController,
          onChanged: () {
            setState(() {
              widget.projectController.setDescription(descriptionController.text);
            });
        }),
        const SizedBox(height: gap),
        buildEditableTextDetail(context, AppStrings.projectLocation, 
          widget.projectController.getLocation != '' ? widget.projectController.getLocation! : 'Empty Location',
          locationController,
          onChanged: () {
            setState(() {
              widget.projectController.setLocation(locationController.text);
            });
        }),
        const SizedBox(height: gap),
        buildEditableTextDetail(context, AppStrings.projectClient, 
          widget.projectController.getClient != '' ? widget.projectController.getClient! : 'No Client',
          clientController,
          onChanged: () {
            setState(() {
              widget.projectController.setClient(clientController.text);
            });
        }),
        const SizedBox(height: gap),

        buildEditableTextDetail(context, AppStrings.projectContractor, 
          widget.projectController.getContractor != '' ? widget.projectController.getContractor! : 'No Contractor',
          contractorController,
          onChanged: () {
            setState(() {
              widget.projectController.setContractor(contractorController.text);
            });
        }),
        const SizedBox(height: gap),

        buildEditableTextDetail(context, AppStrings.projectRef, 
          widget.projectController.getProjectRef != '' ? widget.projectController.getProjectRef! : 'No Project Reference',
          projectRefController,
          onChanged: () {
            setState(() {
              widget.projectController.setProjectRef(projectRefController.text);
            });
        }),
      ],
    );
  }

  Widget projectDetailNoEdit() {
    final projectDescription = widget.projectController.getDescription != '' ? widget.projectController.getDescription! : 'No Description';
    final projectLocation = widget.projectController.getLocation != '' ? widget.projectController.getLocation! : 'No Location';
    final projectClient = widget.projectController.getClient != '' ? widget.projectController.getClient! : 'No Client';
    final projectContractor = widget.projectController.getContractor != '' ? widget.projectController.getContractor! : 'No Contractor';
    final projectRef = widget.projectController.getProjectRef != '' ? widget.projectController.getProjectRef! : 'No Project Reference';

    const double gap = 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextDetail('Project Name', widget.projectController.getName!),
        const SizedBox(height: gap),
        buildTextDetail('Date Created', formatDate(widget.projectController.getDateCreated!)),
        const SizedBox(height: gap),
        buildJustifiedTextDetail(AppStrings.projectDescription, projectDescription),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectLocation, projectLocation),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectClient, projectClient),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectContractor, projectContractor),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectRef, projectRef),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.projectController.getMainImagePath;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding (
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                if (imagePath != null && imagePath != '' && File(imagePath).existsSync()) ... [
                  buildThumbnailImageShowcase(context, imagePath, onDelete: onDelete),
                  const SizedBox(height: 24.0),
                ] else ... [
                  // if there is no project image allow the user to add one
                  buildImageInput_V2(context, (v) => setState(() {widget.projectController.setMainImagePath(v);})),
                  const SizedBox(height: 24.0),
                ],

                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    if (isEditable) ... [
                      projectDetailEditable(context)
                    ] else ... [
                      projectDetailNoEdit()
                    ],
                
                
                  const Divider(height: 20, thickness: 0.5, color: Colors.grey),

                  const SizedBox(height: 28.0),
                  buildCustomSegmentedControl(label: 'Status', options: statusOptions, selectedNotifier: selectedStatusOption),
                  const SizedBox(height: 28.0),
                  ObjectSelector(
                    label: AppStrings.category,
                    pluralLabel: AppStrings.categories,
                    hint: AppStrings.categoryHint,
                    options: widget.projectController.getCategories ?? [],
                    getName: (cat) => cat.name,
                    getColor: (cat) => cat.color,
                    onCreate: (name, color) {
                      setState(() {
                        widget.projectController.addCategory(name, color);
                      });
                    }
                  ),
                  const SizedBox(height: 28.0),
                  ObjectSelector(
                    label: AppStrings.tag,
                    pluralLabel: AppStrings.tags,
                    hint: AppStrings.tagHint,
                    options: widget.projectController.getTags ?? [],
                    getName: (tag) => tag.name,
                    getColor: (tag) => tag.color,
                    onCreate: (name, color) {
                      setState(() {
                        widget.projectController.addTag(name, color);
                      });
                    }
                  ),

                ])
                ),
              ],
            )
          )
        ]
      )
    );
  }

}