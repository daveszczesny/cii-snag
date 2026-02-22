import 'package:cii/view/project/project_list_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectListView extends ConsumerStatefulWidget {
  const ProjectListView({super.key});

  @override
  ConsumerState<ProjectListView> createState() => _ProjectListViewState();
}

class _ProjectListViewState extends ConsumerState<ProjectListView> {

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