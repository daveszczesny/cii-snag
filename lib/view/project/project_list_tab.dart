import 'package:cii/controllers/project_controller.dart';
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/project.dart';
import 'package:cii/models/status.dart';
import 'package:cii/view/project/project_card_widget.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProjectListTabWidget extends StatefulWidget {

  const ProjectListTabWidget({super.key});

  @override
  State<ProjectListTabWidget> createState() => _ProjectListTabWidgetState();
}

class _ProjectListTabWidgetState extends State<ProjectListTabWidget> with SingleTickerProviderStateMixin {

  late TabController tabController;
  late ProjectController controller;

  @override
  void initState() {
    super.initState();
    controller = ProjectController(Hive.box<Project>('projects'));
    tabController = TabController(length: 3, vsync: this);

  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }


  Widget buildProjectList(String status) {
    return ValueListenableBuilder(
        valueListenable: controller.projectBox.listenable(),
        builder: (context, Box<Project> box, _) {
          if (box.isEmpty) {
          return const Center(child: Text(AppStrings.noProjectsFound));
          }

          List<Project>? projects = controller.getProjectsByStatus(status);
          if (projects == null || projects.isEmpty) {
            return const Center(child: Text('No projects found.'));
          }
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final projectObject = projects[index];
              final projectController = SingleProjectController(projectObject);
              return ProjectCardWidget(projectController: projectController);
            }
          );
        }
      );
  }

  @override
  Widget build(BuildContext context) {
    // final double screenWidth = MediaQuery.of(context).size.width;
    // final double tabWidth = screenWidth * 0.7;

    const List<Widget> tabs = [
      Tab(text: 'Recent'),
      Tab(text: 'All'),
      Tab(text: 'Closed'),
    ];

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            isScrollable: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            tabs: tabs,
          ),
          ValueListenableBuilder(
            valueListenable: AppTerminology.version,
            builder: (context, _, __) {
              return Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    buildProjectList('Recent'),
                    buildProjectList('All'),
                    buildProjectList('Closed'),
                  ]
                )
              );
            }
          )
        ]
      )
    );
  }
}