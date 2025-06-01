import 'package:cii/view/project/project_list_tab.dart';
import 'package:flutter/material.dart';

class ProjectListView extends StatefulWidget {
  const ProjectListView({super.key});

  @override
  State<ProjectListView> createState() => _ProjectListViewState();
}

class _ProjectListViewState extends State<ProjectListView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        leading: IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // Navigate to settings page
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ),
      body: const ProjectListTabWidget(),
      
    );
  }
}