import 'package:cii/models/project.dart';
import 'package:cii/models/status.dart';
import 'package:cii/models/tag.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/project/project_analytics.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/image.dart';
import 'package:cii/view/utils/selector.dart';
import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cii/providers/providers.dart';
import 'package:cii/models/category.dart';

class ProjectDetailPage extends ConsumerStatefulWidget {
  final String projectId;

  final bool isInEditMode;
  const ProjectDetailPage({
    Key? key,
    required this.projectId,
    required this.isInEditMode,
    }) : super(key: key);

  @override
  ConsumerState<ProjectDetailPage> createState() => ProjectDetailPageState();
}

class ProjectDetailPageState extends ConsumerState<ProjectDetailPage> {

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
    selectedStatusOption = ValueNotifier<String>(statusOptions.first);

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Project project = ProjectService.getProject(ref, widget.projectId);
    final currentStatus = project.status.name;

    final initialStatus = statusOptions.firstWhere(
      (s) => s.toLowerCase() == currentStatus.toLowerCase(),
      orElse: () => statusOptions.first
    );
    selectedStatusOption.value = initialStatus;

    selectedStatusOption.addListener(() async {

      // Check if all snags in project are marked complete
      if (selectedStatusOption.value == Status.completed.name) {

        final int totalCompleteSnags = ProjectService.getSnagsByStatus(ref, widget.projectId, Status.completed).length;

        // Updated via project provider
        final int totalSnags = ProjectService.getSnagCount(ref, widget.projectId);

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
            selectedStatusOption.value = project.status.name;
            return;
          }
        }
      }

      Status newStatus = Status.getStatus(selectedStatusOption.value)!;
      final updatedProject = project.copyWith(status: newStatus);
      ProjectService.updateProject(ref, updatedProject);

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
    final Project project = ProjectService.getProject(ref, widget.projectId);


    if (project.name != nameController.text) {
      changes['name'] = nameController.text;
    }
    if (project.description != descriptionController.text) {
      changes['description'] = descriptionController.text;
    }
    if (project.location != locationController.text) {
      changes['location'] = locationController.text;
    }
    if (project.client != clientController.text) {
      changes['client'] = clientController.text;
    }
    if (project.contractor != contractorController.text) {
      changes['contractor'] = contractorController.text;
    }
    if (project.dueDate.toString() != dueDateController.text && dueDateController.text.isNotEmpty) {
      changes['dueDate'] = dueDateController.text;
    }
    return changes;
  }


  Widget onDelete(BuildContext context) {
    final Project project = ProjectService.getProject(ref, widget.projectId);
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

          // TODO! Delete the image from storage as well
          onPressed: () {
            Navigator.of(context).pop();
            // delete the image
            final updatedProject = project!.copyWith(
              mainImagePath: ''
            );
            ProjectService.updateProject(ref, updatedProject);
            setState(() {});
          },
          child: const Text('Delete')
        )
      ],
    );
  }

  Widget projectDetailEditable(BuildContext context) {
    const double gap = 16;

    final Project project = ProjectService.getProject(ref, widget.projectId);
    final String projectName = project.name != ""
      ? project.name
      : "No Name";
    final String projectDescription = project?.description != ""
      ? project!.description!
      : "No Description";
    final String projectLocation = project?.location != ""
      ? project!.location!
      : "No Location";
    final String projectClient = project?.client != ""
      ? project!.client!
      : "No Client";
    final String projectContractor = project?.contractor != ""
      ? project!.contractor!
      : "No Contractor";
    final dueDate = project?.dueDate.toString() ?? "No Due Date";
    final DateTime dateCreated = project!.dateCreated!;
    final String projectRef = project.projectRef!;

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
        buildTextDetail('Date Created', formatDate(dateCreated)), // date created is not editable
        const SizedBox(height: gap),
        buildDatePickerInput(context, 'Due Date', dueDate, dueDateController),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectRef, projectRef),
      ],
    );
  }

  Widget projectDetailNoEdit() {
    final Project project = ProjectService.getProject(ref, widget.projectId);

    final projectDescription = project?.description != ""
      ? project!.description!
      : "No Description";
    final projectLocation = project?.location != ""
      ? project!.location!
      : "No Location";
    final projectClient = project?.client != ""
      ? project!.client!
      : "No Client";
    final projectContractor = project?.contractor != ""
      ? project!.contractor!
      : "No Contractor";
    final projectRef = project!.projectRef!;
    final dueDate = project?.dueDate.toString() ?? "No Due Date";

    nameController.text = project.name;
    descriptionController.text = project.description ?? "";
    locationController.text = project.location ?? "";
    clientController.text = project.client ?? "";
    contractorController.text = project.contractor ?? "";

    const double gap = 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextDetail('Project Name', project.name),
        const SizedBox(height: gap),
        buildJustifiedTextDetail(AppStrings.projectDescription, projectDescription),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectLocation, projectLocation),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectClient, projectClient),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectContractor, projectContractor),
        const SizedBox(height: gap),
        buildTextDetail('Date Created', formatDate(project.dateCreated!)),
        const SizedBox(height: gap),
        buildTextDetail('Due Date', dueDate),
        const SizedBox(height: gap),
        buildTextDetail(AppStrings.projectRef, projectRef),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Project project = ProjectService.getProject(ref, widget.projectId);
    final imagePath = project.mainImagePath;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding (
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                if (imagePath != null && imagePath != '') ... [
                  buildThumbnailImageShowcase(context, imagePath, onDelete: onDelete),
                  const SizedBox(height: 24.0),
                ] else ... [
                  // if there is no project image allow the user to add one
                  buildImageInput_V2(
                    context,
                    (v) => setState(
                      () {
                          final updatedProject = project.copyWith(
                            mainImagePath: v
                          );
                          ProjectService.updateProject(ref, updatedProject);
                         }
                      ),
                      ignoreAspectRatio: true),
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
                    options: project.createdCategories ?? [],
                    getName: (cat) => cat.name,
                    getColor: (cat) => cat.color,
                    onCreate: (name, color) {
                      setState(() {
                        final updatedProject = project.copyWith(
                          createdCategories: [
                            Category(name: name, color: color),
                            ... project.createdCategories ?? []
                          ]
                        );
                        ProjectService.updateProject(ref, updatedProject);
                      });
                    },
                    onDelete: (cat) {
                      // Check if any snag is using this category
                      
                      bool categoryInUse = ProjectService.getSnags(ref, widget.projectId)
                        .where((s) =>
                          s.categories != null &&
                          s.categories!.isNotEmpty &&
                          s.categories!.first.name.toLowerCase() == cat.name.toLowerCase()
                        )
                        .toList()
                        .isNotEmpty;

                      if (categoryInUse) {
                        // block user from deleting category
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cannot Delete Category'),
                            content: Text('This category is being used by one or more ${AppStrings.snags()}. Please remove the category from the ${AppStrings.snag()} before deleting this category.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK')
                              )
                            ],
                          )
                        );
                      } else {
                        // delete the category
                        setState(() {
                          
                          final updatedProject = project.copyWith(
                            createdCategories: [
                              ...project.createdCategories!
                                .where((c) =>
                                  c.name.toLowerCase() != cat.name.toLowerCase()
                                )
                            ]
                          );
                          ProjectService.updateProject(ref, updatedProject);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 28.0),
                  ObjectSelector(
                    label: AppStrings.tag,
                    pluralLabel: AppStrings.tags,
                    hint: AppStrings.tagHint(),
                    options: project.createdTags ?? [],
                    getName: (tag) => tag.name,
                    getColor: (tag) => tag.color,
                    onCreate: (name, color) {
                      setState(() {
                        final updatedProject = project.copyWith(
                          createdTags: [
                            Tag(name: name, color: color),
                            ...project.createdTags ?? []
                          ]
                        );
                        ProjectService.updateProject(ref, updatedProject);
                      });
                    },
                    onDelete: (tag) {

                      bool tagInUse = ProjectService.getSnags(ref, widget.projectId)
                        .where((s) =>
                          s.tags != null &&
                          s.tags!.isNotEmpty &&
                          s.tags!.first.name.toLowerCase() == tag.name.toLowerCase()
                        )
                        .toList()
                        .isNotEmpty;

                      if (tagInUse) {
                        // block user from deleting tag
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cannot Delete Tag'),
                            content: Text('This tag is being used by one or more ${AppStrings.snags()}. Please remove the tag from the ${AppStrings.snag()} before deleting this tag.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK')
                              )
                            ],
                          )
                        );
                      } else {
                        // delete the tag
                        setState(() {
                          final updatedProject = project.copyWith(
                            createdTags: [
                              ...project.createdTags!
                                .where((t) =>
                                  t.name.toLowerCase() != tag.name.toLowerCase()
                                )
                            ]
                          );
                          ProjectService.updateProject(ref, updatedProject);
                        });
                      }
                    },
                  ),

                  // Project Analytics
                  const SizedBox(height: 28.0),
                  const Divider(height: 20, thickness: 0.5, color: Colors.grey),
                  const SizedBox(height: 32.0),
                  ProjectAnalytics(projectId: widget.projectId),
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
