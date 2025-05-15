import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/selector.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class ProjectDetailPage extends StatefulWidget {
  final SingleProjectController projectController;
  const ProjectDetailPage({super.key, required this.projectController});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController clientController = TextEditingController();
  final TextEditingController contractorController = TextEditingController();
  final TextEditingController projectRefController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  late ValueNotifier<String> selectedStatusOption;
  final List<String> statusOptions = Status.values.map((e) => e.name).toList(); // get the name of each status

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

  // format dateCreated
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding (
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (widget.projectController.getMainImagePath != null && widget.projectController.getMainImagePath != '') ... [
                  buildSingleImageShowcaseBig(context, widget.projectController.getMainImagePath!, () {
                    // onDelete fn
                    setState(() {
                      // ask the user if they want to delete the image
                      showDialog(
                        context: context,
                        builder: (context) {
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
                      );
                    });
                  }),
                ] else ... [
                  // if there is no project image allow the user to add one
                  buildImageInputForSingleImage('Upload Project Thumbnail', context, (value) {
                    setState(() {
                      widget.projectController.setMainImagePath(value);
                    });
                  })
                ],
                const SizedBox(height: 28.0),

                buildTextDetail('Date Created', formatDate(widget.projectController.getDateCreated!)),
                const SizedBox(height: 28.0),
                buildEditableTextDetail(context, AppStrings.projectDescription, 
                  widget.projectController.getDescription != '' ? widget.projectController.getDescription! : 'Empty description',
                  descriptionController,
                  onChanged: () {
                    setState(() {
                      widget.projectController.setDescription(descriptionController.text);
                    });
                }),
                const SizedBox(height: 28.0),
                buildEditableTextDetail(context, AppStrings.projectLocation, 
                  widget.projectController.getLocation != '' ? widget.projectController.getLocation! : 'Empty Location',
                  locationController,
                  onChanged: () {
                    setState(() {
                      widget.projectController.setLocation(locationController.text);
                    });
                }),
                const SizedBox(height: 28.0),
                buildEditableTextDetail(context, AppStrings.projectClient, 
                  widget.projectController.getClient != '' ? widget.projectController.getClient! : 'No Client',
                  clientController,
                  onChanged: () {
                    setState(() {
                      widget.projectController.setClient(clientController.text);
                    });
                }),
                const SizedBox(height: 28.0),

                buildEditableTextDetail(context, AppStrings.projectContractor, 
                  widget.projectController.getContractor != '' ? widget.projectController.getContractor! : 'No Contractor',
                  contractorController,
                  onChanged: () {
                    setState(() {
                      widget.projectController.setContractor(contractorController.text);
                    });
                }),
                const SizedBox(height: 28.0),

                buildEditableTextDetail(context, AppStrings.projectRef, 
                  widget.projectController.getProjectRef != '' ? widget.projectController.getProjectRef! : 'No Project Reference',
                  projectRefController,
                  onChanged: () {
                    setState(() {
                      widget.projectController.setProjectRef(projectRefController.text);
                    });
                }),
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
              ],
            )
          )
        ]
      )
    );
  }

}