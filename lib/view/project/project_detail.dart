import 'package:cii/models/project.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/project/export/project_export.dart';
import 'package:cii/view/project/project_detail_page.dart';
import 'package:cii/view/snag/snag_create.dart';
import 'package:cii/view/snag/snag_list.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectDetail extends ConsumerStatefulWidget {
  final String projectId;
  final int? index;

  const ProjectDetail({super.key, required this.projectId, this.index});

  @override
  ConsumerState<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends ConsumerState<ProjectDetail> {

  final GlobalKey<ProjectDetailPageState> _detailKey = GlobalKey<ProjectDetailPageState>();

  late List<Widget> pages;
  late List<String> titles;
  late int selectedIndex;
  late bool isInEditMode;

  @override
  void initState() {
    super.initState();
    isInEditMode = false;
    selectedIndex = widget.index ?? 0;
  }

  void buildPages(Project project) {
    pages = [
      // page for snag list
      SnagList(projectId: widget.projectId),
      // page for project details
      ProjectDetailPage(key: _detailKey, projectId: project.uuid, isInEditMode: isInEditMode),
      // page to create snag
      SnagCreate(projectId: widget.projectId),
    ];

    final projectName = project.name;
    titles = [
      AppStrings.snagsInProject(projectName),
      projectName,
      AppStrings.createInProject(projectName)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Project project = ProjectService.getProject(ref, widget.projectId);
    buildPages(project);

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        leading: isInEditMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    // check if there are any changes
                    if (_detailKey.currentState?.getChanges().isNotEmpty ?? false) {
                      // show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Discard Changes?'),
                            content: const Text('You have unsaved changes. Do you want to discard them?'),
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
                                  setState(() {
                                    isInEditMode = false;
                                    pages[1] = ProjectDetailPage(
                                      // key: _detailKey,
                                      projectId: project.uuid,
                                      isInEditMode: isInEditMode
                                    );
                                    selectedIndex = 1;
                                  });
                                },
                                child: const Text('Discard')
                              )
                            ],
                          );
                        }
                      );
                    } else {
                      isInEditMode = false;
                      pages[1] = ProjectDetailPage(
                        // key: _detailKey,
                        projectId: project.uuid,
                        isInEditMode: isInEditMode
                      );
                      selectedIndex = 1;
                    }

                  });
                },
              )
            : null,


        actions: [
          if (selectedIndex == 1) ... [
            if (!isInEditMode) ... [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: PopupMenuButton<String>(
                  onSelected: (String value) {
                    switch (value) {
                      case 'edit':
                        setState(() {
                          isInEditMode = !isInEditMode;
                          pages[1] = ProjectDetailPage(
                            // key: _detailKey,
                            projectId: project.uuid,
                            isInEditMode: isInEditMode
                          );
                          selectedIndex = 1;
                        });
                        break;
                      case 'export':
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ProjectExport(projectId: project.uuid))
                        );
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit Project')
                      ),
                      const PopupMenuItem<String>(
                        value: 'export',
                        child: Text('Export Project')
                      ),
                    ];
                  },
                )
              )
            ] else ... [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      // apply changes
                      final changes = _detailKey.currentState?.getChanges();
                      if (changes != null && changes.isNotEmpty) {

                        final updatedProject = project.copyWith(
                          name: changes["name"] ?? project.name,
                          description: changes["description"] ?? project.description,
                          location: changes["location"] ?? project.location,
                          client: changes["client"] ?? project.client,
                          contractor: changes["contractor"] ?? project.contractor,
                          projectRef: changes["projectRef"] ?? project.projectRef,
                          dueDate: parseDate(changes["dueDate"] ?? project.dueDate.toString()),
                        );
                        ProjectService.updateProject(ref, updatedProject);
                      }

                      isInEditMode = !isInEditMode;
                      pages[1] = ProjectDetailPage(
                        // key: _detailKey,
                        projectId: project.uuid,
                        isInEditMode: isInEditMode
                      );
                      selectedIndex = 1;
                    });
                  },
                  child: const Icon(Icons.check)
                )
              )
            ]
          ]
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        height: 60,
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) => setState(() => selectedIndex = index),
        destinations: [
          // page for snag list
          NavigationDestination(
            icon: const Icon(Icons.list),
            label: AppStrings.snags(),
          ),

          // page for project details
          const NavigationDestination(
            icon: Icon(Icons.info),
            label: AppStrings.projectDetails,
          ),

          // page to create snag
          const NavigationDestination(
            icon: Icon(Icons.add),
            label: AppStrings.add,
          ),
        ],
      ),
    );
  }
}