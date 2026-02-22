import 'package:cii/models/project.dart';
import 'package:cii/providers/project_provider.dart';
import 'package:cii/services/project_service.dart';
import 'package:cii/view/project/project_card_widget.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:cii/view/utils/project/project_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectListTabWidget extends ConsumerStatefulWidget {

  const ProjectListTabWidget({super.key});

  @override
  ConsumerState<ProjectListTabWidget> createState() => _ProjectListTabWidgetState();
}

class _ProjectListTabWidgetState extends ConsumerState<ProjectListTabWidget> with SingleTickerProviderStateMixin {

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget buildProjectList(List<Project> projects, String status) {
    final filteredProjects = getProjectByStatus(projects, status);

    if (projects.isEmpty || filteredProjects.isEmpty) {
      return const Center(child: Text(AppStrings.noProjectsFound));
    }

    return ListView.builder(
      itemCount: filteredProjects.length,
      itemBuilder: (context, index) {
        final projectObject = filteredProjects[index];
        return ProjectCardWidget(projectId: projectObject.id!);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Project> projects = ProjectService.getProjects(ref);
    final int recentCount = getProjectByStatus(projects, "Recent").length;
    final int allCount = projects.length;
    final int closedCount = getProjectByStatus(projects, "Closed").length;

    final tabs = [
      Tab(text: "Recent ($recentCount)"),
      Tab(text: "All ($allCount)"),
      Tab(text: "Closed ($closedCount)"),
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
                    buildProjectList(projects, "Recent"),
                    buildProjectList(projects, "All"),
                    buildProjectList(projects, "Closed")
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
