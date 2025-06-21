import 'dart:io';

import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/project/project_analytics.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/selector.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';

class ProjectDetailPage extends StatefulWidget {
  final SingleProjectController projectController;
  final bool isInEditMode;
  const ProjectDetailPage({
    Key? key,
    required this.projectController,
    required this.isInEditMode,
    }) : super(key: key);

  @override
  State<ProjectDetailPage> createState() => ProjectDetailPageState();
}

class ProjectDetailPageState extends State<ProjectDetailPage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController clientController = TextEditingController();
  final TextEditingController contractorController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

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

    selectedStatusOption.addListener(() async {

      // Check if all snags in project are marked complete
      if (selectedStatusOption.value == Status.completed.name) {
        final int totalCompleteSnags = widget.projectController.getTotalSnagsByStatus(Status.completed);
        final int totalSnags = widget.projectController.getTotalSnags();
        if (totalSnags > totalCompleteSnags) { // some snags are not yet closed
          // show a dialog asking the user if they 
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Close Project'),
              content: Text('Some ${AppStrings.snags()} are not yet closed. Are you sure you want to close this project?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes, Close')
                )
              ],
            )
          );
          if (confirmed != true) {
            selectedStatusOption.value = widget.projectController.getStatus!;
            return;
          }
        }
      }

      widget.projectController.setStatus(selectedStatusOption.value);
      setState(() {});
    });
  }

  @override
  void dispose() {
    selectedStatusOption.dispose();
    super.dispose();
  }

  Map<String, String> getChanges() {
    final changes = <String, String>{};
    if (widget.projectController.getName != nameController.text) {
      changes['name'] = nameController.text;
    }
    if (widget.projectController.getDescription != descriptionController.text) {
      changes['description'] = descriptionController.text;
    }
    if (widget.projectController.getLocation != locationController.text) {
      changes['location'] = locationController.text;
    }
    if (widget.projectController.getClient != clientController.text) {
      changes['client'] = clientController.text;
    }
    if (widget.projectController.getContractor != contractorController.text) {
      changes['contractor'] = contractorController.text;
    }
    if (widget.projectController.getDueDateString != dueDateController.text && dueDateController.text.isNotEmpty) {
      changes['dueDate'] = dueDateController.text;
    }
    return changes;
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

  Widget projectDetailEditable(BuildContext context) {
    const double gap = 16;

    final projectName = widget.projectController.getName != '' ? widget.projectController.getName! : 'No Name';
    final projectDescription = widget.projectController.getDescription != '' ? widget.projectController.getDescription! : 'No Description';
    final projectLocation = widget.projectController.getLocation != '' ? widget.projectController.getLocation! :  'No Location';
    final projectClient = widget.projectController.getClient != '' ? widget.projectController.getClient! : 'No Client';
    final projectContractor = widget.projectController.getContractor != '' ? widget.projectController.getContractor! : 'No Contractor';
    final dueDate = widget.projectController.getDueDate != null ? widget.projectController.getDueDateString! : 'No Due Date';


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextInput("Project Name", projectName, nameController),
        const SizedBox(height: gap),
        buildLongTextInput(AppStrings.projectDescription, projectDescription, descriptionController),
        const SizedBox(height: gap),
        buildTextInput(AppStrings.projectLocation, projectLocation, locationController),
        const SizedBox(height: gap),
        buildTextInput(AppStrings.projectClient, projectClient, clientController),
        const SizedBox(height: gap),
        buildTextInput(AppStrings.projectContractor, projectContractor, contractorController),
        const SizedBox(height: gap),
        buildTextDetail('Date Created', formatDate(widget.projectController.getDateCreated!)), // date created is not editable
        const SizedBox(height: gap),
        buildDatePickerInput(context, 'Due Date', dueDate, dueDateController),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectRef, widget.projectController.getProjectRef!),
      ],
    );
  }

  Widget projectDetailNoEdit() {
    final projectDescription = widget.projectController.getDescription != '' ? widget.projectController.getDescription! : 'No Description';
    final projectLocation = widget.projectController.getLocation != '' ? widget.projectController.getLocation! : 'No Location';
    final projectClient = widget.projectController.getClient != '' ? widget.projectController.getClient! : 'No Client';
    final projectContractor = widget.projectController.getContractor != '' ? widget.projectController.getContractor! : 'No Contractor';
    final projectRef = widget.projectController.getProjectRef != '' ? widget.projectController.getProjectRef! : 'No Project Reference';
    final dueDate = widget.projectController.getDueDate != null ? widget.projectController.getDueDateString! : 'No Due Date';

    nameController.text = widget.projectController.getName ?? '';
    descriptionController.text = widget.projectController.getDescription ?? '';
    locationController.text = widget.projectController.getLocation ?? '';
    clientController.text = widget.projectController.getClient ?? '';
    contractorController.text = widget.projectController.getContractor ?? '';

    const double gap = 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextDetail('Project Name', widget.projectController.getName!),
        const SizedBox(height: gap),
        buildJustifiedTextDetail(AppStrings.projectDescription, projectDescription),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectLocation, projectLocation),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectClient, projectClient),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectContractor, projectContractor),
        const SizedBox(height: gap),
        buildTextDetail('Date Created', formatDate(widget.projectController.getDateCreated!)),
        const SizedBox(height: gap),
        buildTextDetail('Due Date', dueDate),
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
                    if (widget.isInEditMode) ... [
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
                    hint: AppStrings.categoryHint(),
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
                    hint: AppStrings.tagHint(),
                    options: widget.projectController.getTags ?? [],
                    getName: (tag) => tag.name,
                    getColor: (tag) => tag.color,
                    onCreate: (name, color) {
                      setState(() {
                        widget.projectController.addTag(name, color);
                      });
                    }
                  ),

                  // Project Analytics
                  const SizedBox(height: 28.0),
                  const Divider(height: 20, thickness: 0.5, color: Colors.grey),
                  const SizedBox(height: 32.0),
                  ProjectAnalytics(projectController: widget.projectController),
                  const SizedBox(height: 32.0),

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