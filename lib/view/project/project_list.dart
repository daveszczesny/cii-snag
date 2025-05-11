import 'package:cii/controllers/project_controller.dart';
import 'package:cii/models/project.dart';
import 'package:cii/view/project/project_list_tab.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
    _controller = ProjectController(Hive.box<Project>('projects'));
  }

  @override
  Widget build(BuildContext context) {
    // If there are no projects
    if(_controller.projectBox.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Projects'),
        ),
        body: const Center(
          child: Text('No projects found.')
        )
      );
    } else { // if there are projects
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Projects'),
        ),
        body: const ProjectListTabWidget()
      );
    }
  }
}
