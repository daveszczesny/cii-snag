import 'package:cii/controllers/project_controller.dart';
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/project.dart';
import 'package:cii/view/project/project_card_widget.dart';
import 'package:cii/view/project/project_list_tab.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProjectListView extends StatefulWidget {
  const ProjectListView({super.key});

  @override
  State<ProjectListView> createState() => _ProjectListViewState();
}

class _ProjectListViewState extends State<ProjectListView> {
  late ProjectController _controller;

  @override
  void initState() {
    super.initState();
    final box = Hive.box<Project>('projects');
    _controller = ProjectController(box);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myProjects)
      ),
      body: ProjectListTabWidget(),
      
      // ValueListenableBuilder(
      //   valueListenable: _controller.projectBox.listenable(),
      //   builder: (context, Box<Project> box, _) {
      //     if (box.isEmpty) {
      //     return const Center(child: Text(AppStrings.noProjectsFound));
      //     }
        
      //     return ListView.builder(
      //       itemCount: box.length,
      //       itemBuilder: (context, index) {
      //         final projectObject = box.getAt(index)!;
      //         final projectController = SingleProjectController(projectObject);
      //         return ProjectCardWidget(projectController: projectController);
      //       }
      //     );
      //   }
      // )
    );
  }
}