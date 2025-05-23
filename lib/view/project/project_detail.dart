import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/view/project/project_detail_page.dart';
import 'package:cii/view/snag/snag_create.dart';
import 'package:cii/view/snag/snag_list.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProjectDetail extends StatefulWidget {
  final SingleProjectController projectController;
  final int? index;

  const ProjectDetail({super.key, required this.projectController, this.index});

  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {

  late List<Widget> pages;
  late List<String> titles;
  late int selectedIndex;
  late bool isInEditMode;

  @override
  void initState() {
    super.initState();
    isInEditMode = false;
    pages = [
      // page for snag list
      SnagList(projectController: widget.projectController),
      // page for project details
      ProjectDetailPage(projectController: widget.projectController, isInEditMode: isInEditMode),
      // page to create snag
      SnagCreate(projectController: widget.projectController),
    ];

    final projectName = widget.projectController.getName!;
    titles = [
      'Snags in $projectName',
      projectName,
      'Create Snag in $projectName',
    ];

    selectedIndex = widget.index ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
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
                            projectController: widget.projectController,
                            isInEditMode: isInEditMode
                          );
                          selectedIndex = 1;
                        });
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
                        value: 'settings',
                        child: Text('Project Settings')
                      )
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
                      isInEditMode = !isInEditMode;
                      pages[1] = ProjectDetailPage(
                        projectController: widget.projectController,
                        isInEditMode: isInEditMode
                      );
                      selectedIndex = 1;
                    });
                  },
                  child: const Text("Confirm")
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
        destinations: const [
          // page for snag list
          NavigationDestination(
            icon: Icon(Icons.list),
            label: AppStrings.snags,
          ),

          // page for project details
          NavigationDestination(
            icon: Icon(Icons.info),
            label: AppStrings.projectDetails,
          ),

          // page to create snag
          NavigationDestination(
            icon: Icon(Icons.add),
            label: AppStrings.add,
          ),
        ],
      ),
    );
  }
}