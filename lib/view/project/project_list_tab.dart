import 'package:cii/controllers/project_controller.dart';
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/project.dart';
import 'package:cii/view/project/project_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
    return StreamBuilder<List<Project>>(
      stream: controller.filterProjects(status),
      builder: (context, snapshot) { 
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading projects.'));
        }

        final projects = snapshot.data;
        return ListView.builder(
          itemCount: projects?.length,
          itemBuilder: ((context, index) {
            return ProjectCardWidget(
              projectController: SingleProjectController(projects![index])
            );
          })
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
      Tab(text: 'Completed'),
    ];

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            isScrollable: true,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            tabs: tabs,
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                buildProjectList('Recent'),
                buildProjectList('All'),
                buildProjectList('Completed')
              ]
            )
          )
        ]
      )
    );
  }
}