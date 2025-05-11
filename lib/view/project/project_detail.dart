import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/project.dart';
import 'package:cii/view/project/project_detail_page.dart';
import 'package:flutter/material.dart';

class ProjectDetail extends StatefulWidget {
  final Project project;

  const ProjectDetail({super.key, required this.project});

  @override
  State<ProjectDetail> createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {

  int selectedIndex = 0;

  late List<Widget> pages;
  late SingleProjectController projectController;

  @override
  void initState() {
    super.initState();

    projectController = SingleProjectController(widget.project);

    pages = [
      // page for project details
      ProjectDetailPage(projectController: projectController)
      // page to create snag
      // page for snag list
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name)
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        height: 60,
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.info),
            label: 'Details',
          ),
          NavigationDestination(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Snags',
          ),
        ],
      ),
    );
  }
}