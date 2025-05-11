import 'package:cii/controllers/project_controller.dart';
import 'package:cii/models/project.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  // temp clear all projects
  ProjectController controller = ProjectController(
    Hive.box<Project>('projects')
  );

  @override
  void initState() {
    super.initState();
    controller.deleteAllProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: const Center(
        child: Text('Notifications'),
      ),
    );
  }
}